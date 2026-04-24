"""Anthropic LLM wrapper producing strictly structured clinical JSON output."""
from __future__ import annotations

import json
import re
from typing import Any, Dict, List, Optional

from anthropic import AsyncAnthropic

from core.config import get_settings
from core.logging import get_logger

logger = get_logger("llm")
_settings = get_settings()
_client: Optional[AsyncAnthropic] = None


def _get_client() -> AsyncAnthropic:
    global _client
    if _client is None:
        if not _settings.ANTHROPIC_API_KEY:
            raise RuntimeError("ANTHROPIC_API_KEY is not configured.")
        _client = AsyncAnthropic(api_key=_settings.ANTHROPIC_API_KEY, timeout=45.0)
    return _client


MODE_PROMPTS: Dict[str, str] = {
    "general": (
        "You are a board-certified internist providing evidence-based clinical decision support. "
        "Balance breadth and depth. Prioritize patient safety and red-flag identification."
    ),
    "neurology": (
        "You are a board-certified neurologist. Emphasize localization, time-sensitive stroke / status / "
        "spine emergencies, and neuroimaging thresholds. Cite NIHSS, LVO criteria, and DAWN/DEFUSE-3 windows when relevant."
    ),
    "icu": (
        "You are an intensivist in a mixed medical-surgical ICU. Use Surviving Sepsis, ARDSnet, and "
        "PADIS frameworks. Give weight-based dosing, vasopressor ladders, ventilator settings, and "
        "hemodynamic endpoints. Assume a critically ill patient until proven otherwise."
    ),
    "emergency": (
        "You are an emergency medicine attending. Move fast. Lead with airway/breathing/circulation, "
        "time-critical diagnoses (STEMI, stroke, sepsis, AAA, PE, ectopic), and disposition. "
        "Prefer decision rules (HEART, PERC, Wells, NEXUS, Ottawa)."
    ),
}

BASE_SYSTEM = """You are MedEvidence, an evidence-grounded clinical decision-support assistant.
You MUST reply with one JSON object and nothing else. No prose before or after. No markdown fences.
The JSON object MUST contain exactly these keys:
  answer              string - concise clinical answer (<= 350 words)
  reasoning           string - stepwise clinical reasoning referencing the evidence
  differential        array of strings - ranked differential diagnoses with brief rationale
  red_flags           array of strings - must-not-miss findings for this case
  management_plan     array of strings - ordered concrete next steps with doses/thresholds
  references          array of objects with keys pmid (optional), title, url (optional), grade (optional)
  confidence_level    number between 0 and 1
  evidence_grade      one of "1a","1b","2a","2b","3a","3b","4","5" (Oxford CEBM)
  explainability      string - how the evidence bundle supports the answer

Rules:
- Only cite references present in the provided EVIDENCE block. Do not invent PMIDs or DOIs.
- If evidence is thin, lower confidence_level and say so in explainability.
- Never prescribe without dose, route, and frequency.
- Never fabricate guidelines; if uncertain, recommend escalation and cite the limitation.
- Output the JSON object only."""


def _system_for(mode: str) -> str:
    mode_line = MODE_PROMPTS.get(mode, MODE_PROMPTS["general"])
    return f"{BASE_SYSTEM}\n\nRole context: {mode_line}"


def _format_evidence(evidence: List[Dict[str, Any]]) -> str:
    lines: List[str] = []
    for idx, item in enumerate(evidence, start=1):
        pmid = item.get("pmid") or ""
        title = (item.get("title") or "")[:300]
        grade = item.get("grade") or ""
        year = item.get("year") or ""
        source = item.get("source") or ""
        url = item.get("url") or ""
        abstract = (item.get("abstract") or "")[:1200]
        lines.append(
            f"[{idx}] PMID={pmid} GRADE={grade} YEAR={year} SOURCE={source} URL={url}\n"
            f"TITLE: {title}\nABSTRACT: {abstract}"
        )
    return "\n\n".join(lines) if lines else "(no evidence retrieved)"


def _extract_json(text: str) -> Dict[str, Any]:
    text = text.strip()
    # strip possible fences even though we forbade them
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```$", "", text)
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # fallback: grab first {...} block
    match = re.search(r"\{.*\}", text, flags=re.DOTALL)
    if match:
        try:
            return json.loads(match.group(0))
        except json.JSONDecodeError:
            pass
    raise ValueError("LLM did not return valid JSON")


async def generate_clinical_response(
    *,
    query: str,
    mode: str,
    evidence: List[Dict[str, Any]],
    safety_banner: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    client = _get_client()
    system = _system_for(mode)
    evidence_block = _format_evidence(evidence)

    banner_note = ""
    if safety_banner:
        banner_note = (
            f"\n\nSAFETY BANNER (already shown to clinician; incorporate into reasoning and red_flags):\n"
            f"{json.dumps(safety_banner, ensure_ascii=False)}"
        )

    user_content = (
        f"CLINICAL QUESTION ({mode.upper()}):\n{query}\n\n"
        f"EVIDENCE:\n{evidence_block}{banner_note}\n\n"
        "Return the JSON object now."
    )

    response = await client.messages.create(
        model=_settings.ANTHROPIC_MODEL,
        max_tokens=_settings.LLM_MAX_TOKENS,
        temperature=_settings.LLM_TEMPERATURE,
        system=system,
        messages=[{"role": "user", "content": user_content}],
    )

    text_blocks = [block.text for block in response.content if getattr(block, "type", None) == "text"]
    raw_text = "\n".join(text_blocks).strip()
    if not raw_text:
        raise ValueError("Empty LLM response")

    payload = _extract_json(raw_text)
    payload["_model"] = _settings.ANTHROPIC_MODEL
    payload["_usage"] = {
        "input_tokens": getattr(response.usage, "input_tokens", None),
        "output_tokens": getattr(response.usage, "output_tokens", None),
    }
    return payload
