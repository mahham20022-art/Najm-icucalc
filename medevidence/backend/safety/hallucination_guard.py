"""Post-LLM hallucination / grounding guard.

Validates that the LLM output is (a) valid JSON shape we asked for, (b) every
reference cited appears in the evidence bundle we passed in, and (c) numeric
confidence is within policy bounds. Returns a possibly-modified payload plus
a list of warnings.
"""
from __future__ import annotations

import re
from typing import Any, Dict, List, Tuple

REQUIRED_FIELDS = (
    "answer",
    "reasoning",
    "differential",
    "red_flags",
    "management_plan",
    "references",
    "confidence_level",
    "evidence_grade",
    "explainability",
)

VALID_GRADES = {"1a", "1b", "2a", "2b", "3a", "3b", "4", "5"}


def _iter_reference_ids(refs: List[Any]) -> List[str]:
    ids: List[str] = []
    for ref in refs or []:
        if isinstance(ref, dict):
            for key in ("pmid", "id", "doi", "url", "title"):
                value = ref.get(key)
                if value:
                    ids.append(str(value).strip().lower())
        elif isinstance(ref, str):
            ids.append(ref.strip().lower())
    return ids


def _evidence_corpus(evidence: List[Dict[str, Any]]) -> str:
    parts: List[str] = []
    for item in evidence or []:
        for key in ("pmid", "doi", "url", "title", "abstract", "source"):
            value = item.get(key)
            if value:
                parts.append(str(value).lower())
    return "\n".join(parts)


def validate(
    payload: Dict[str, Any],
    evidence: List[Dict[str, Any]],
) -> Tuple[Dict[str, Any], List[str]]:
    warnings: List[str] = []

    for field in REQUIRED_FIELDS:
        if field not in payload:
            warnings.append(f"missing_field:{field}")
            payload[field] = _default_for(field)

    # coerce lists
    for field in ("differential", "red_flags", "management_plan", "references"):
        value = payload.get(field)
        if value is None:
            payload[field] = []
        elif not isinstance(value, list):
            payload[field] = [value]
            warnings.append(f"coerced_to_list:{field}")

    # confidence bounds
    try:
        conf = float(payload.get("confidence_level", 0.0))
    except (TypeError, ValueError):
        conf = 0.0
        warnings.append("invalid_confidence")
    conf = max(0.0, min(1.0, conf))
    payload["confidence_level"] = round(conf, 3)

    # evidence grade
    grade = str(payload.get("evidence_grade", "")).lower().strip()
    if grade not in VALID_GRADES:
        warnings.append("invalid_evidence_grade")
        grade = "5"
    payload["evidence_grade"] = grade

    # reference grounding: references cited must be present in the evidence bundle
    corpus = _evidence_corpus(evidence)
    unsupported = []
    for ref in list(payload.get("references", [])):
        ref_id = ""
        if isinstance(ref, dict):
            ref_id = str(ref.get("pmid") or ref.get("doi") or ref.get("url") or ref.get("title") or "").lower()
        else:
            ref_id = str(ref).lower()
        if not ref_id:
            continue
        if ref_id and ref_id not in corpus:
            unsupported.append(ref_id[:120])
    if unsupported:
        warnings.append(f"unsupported_references:{len(unsupported)}")

    # inline citation sanity: if answer cites [PMID:xxxxx] that isn't in evidence, flag
    pmid_pattern = re.compile(r"pmid[:\s]*([0-9]{5,9})", re.IGNORECASE)
    cited = {m.group(1) for m in pmid_pattern.finditer(str(payload.get("answer", "")))}
    provided = {m.group(1) for m in pmid_pattern.finditer(corpus)}
    dangling = cited - provided
    if dangling:
        warnings.append(f"dangling_pmids:{len(dangling)}")

    # never exceed confidence 0.85 if there are warnings
    if warnings and payload["confidence_level"] > 0.85:
        payload["confidence_level"] = 0.85
        warnings.append("confidence_capped_due_to_warnings")

    payload["grounding_warnings"] = warnings
    return payload, warnings


def _default_for(field: str) -> Any:
    if field in ("differential", "red_flags", "management_plan", "references"):
        return []
    if field == "confidence_level":
        return 0.0
    if field == "evidence_grade":
        return "5"
    return ""
