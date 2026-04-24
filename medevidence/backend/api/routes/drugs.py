"""Drug interaction / check route.

Combines a small curated knowledge base of serious pharmacodynamic/kinetic
interactions with a live RxNav interaction search. The LLM is not invoked here
- answers must be deterministic for drug safety.
"""
from __future__ import annotations

import asyncio
from typing import Any, Dict, List, Optional

import httpx
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from core.audit import record_audit
from core.logging import get_logger
from core.security import get_current_user
from db.database import get_db
from models.user import User

logger = get_logger("drugs")
router = APIRouter(prefix="/drugs", tags=["drugs"])


CURATED: Dict[tuple, Dict[str, Any]] = {
    ("warfarin", "nsaid"): {
        "severity": "major",
        "mechanism": "Additive bleeding risk via platelet inhibition plus displacement from albumin.",
        "action": "Avoid combination. Prefer acetaminophen. If unavoidable, monitor INR twice weekly and for GI bleeding.",
    },
    ("ssri", "tramadol"): {
        "severity": "major",
        "mechanism": "Serotonergic excess -> serotonin syndrome and seizure threshold lowering.",
        "action": "Avoid co-administration. Consider non-serotonergic analgesic.",
    },
    ("maoi", "ssri"): {
        "severity": "contraindicated",
        "mechanism": "Serotonin syndrome risk.",
        "action": "Contraindicated. Require 14-day washout between MAOI and SSRI (5 weeks for fluoxetine).",
    },
    ("clarithromycin", "simvastatin"): {
        "severity": "major",
        "mechanism": "CYP3A4 inhibition raises simvastatin AUC -> rhabdomyolysis risk.",
        "action": "Hold statin during macrolide course or switch to azithromycin / pravastatin.",
    },
    ("amiodarone", "warfarin"): {
        "severity": "major",
        "mechanism": "Amiodarone inhibits CYP2C9 and CYP3A4 -> warfarin potentiation.",
        "action": "Reduce warfarin dose 30-50% and monitor INR weekly for 6-8 weeks.",
    },
    ("qt_prolonger", "qt_prolonger"): {
        "severity": "major",
        "mechanism": "Additive QTc prolongation -> torsades.",
        "action": "Minimize concurrent QT-prolonging agents. Check baseline QTc, replete K+/Mg2+.",
    },
}

QT_PROLONGERS = {
    "ondansetron", "haloperidol", "citalopram", "escitalopram", "methadone",
    "levofloxacin", "ciprofloxacin", "moxifloxacin", "azithromycin",
    "erythromycin", "clarithromycin", "amiodarone", "sotalol", "quetiapine",
}
NSAIDS = {"ibuprofen", "naproxen", "ketorolac", "diclofenac", "indomethacin", "celecoxib"}
SSRIS = {"fluoxetine", "sertraline", "paroxetine", "citalopram", "escitalopram", "fluvoxamine"}
MAOIS = {"phenelzine", "tranylcypromine", "selegiline", "isocarboxazid", "linezolid"}

RXNORM_FIND = "https://rxnav.nlm.nih.gov/REST/rxcui.json"
RXNORM_INTERACT = "https://rxnav.nlm.nih.gov/REST/interaction/interaction.json"


def _normalize(drug: str) -> str:
    return drug.strip().lower()


def _tag(drug: str) -> Optional[str]:
    d = _normalize(drug)
    if d in NSAIDS:
        return "nsaid"
    if d in SSRIS:
        return "ssri"
    if d in MAOIS:
        return "maoi"
    if d in QT_PROLONGERS:
        return "qt_prolonger"
    return d


def _check_curated(a: str, b: str) -> Optional[Dict[str, Any]]:
    for pair in ({(_tag(a), _tag(b)), (_tag(b), _tag(a)), (_normalize(a), _normalize(b)), (_normalize(b), _normalize(a))}):
        if pair in CURATED:
            hit = dict(CURATED[pair])
            hit["source"] = "curated"
            hit["drug_a"] = a
            hit["drug_b"] = b
            return hit
    if _tag(a) == "qt_prolonger" and _tag(b) == "qt_prolonger":
        hit = dict(CURATED[("qt_prolonger", "qt_prolonger")])
        hit["source"] = "curated"
        hit["drug_a"] = a
        hit["drug_b"] = b
        return hit
    return None


async def _resolve_rxcui(http: httpx.AsyncClient, drug: str) -> Optional[str]:
    try:
        r = await http.get(RXNORM_FIND, params={"name": drug})
        r.raise_for_status()
        ids = r.json().get("idGroup", {}).get("rxnormId", [])
        return ids[0] if ids else None
    except Exception:
        return None


async def _rxnav_interactions(http: httpx.AsyncClient, drug: str) -> List[Dict[str, Any]]:
    rxcui = await _resolve_rxcui(http, drug)
    if not rxcui:
        return []
    try:
        r = await http.get(RXNORM_INTERACT, params={"rxcui": rxcui})
        r.raise_for_status()
        data = r.json().get("interactionTypeGroup", [])
    except Exception:
        return []
    out: List[Dict[str, Any]] = []
    for group in data:
        for itype in group.get("interactionType", []):
            for pair in itype.get("interactionPair", []):
                desc = pair.get("description")
                severity = pair.get("severity", "n/a")
                concepts = pair.get("interactionConcept", [])
                other = None
                for concept in concepts:
                    name = concept.get("minConceptItem", {}).get("name")
                    if name and name.lower() != drug.lower():
                        other = name
                if desc:
                    out.append({
                        "drug_a": drug,
                        "drug_b": other or "",
                        "severity": severity,
                        "description": desc,
                        "source": group.get("sourceName", "RxNav"),
                    })
    return out


class InteractionRequest(BaseModel):
    drugs: List[str] = Field(min_length=2, max_length=20)


class InteractionResponse(BaseModel):
    input: List[str]
    pairs_checked: int
    curated: List[Dict[str, Any]]
    external: List[Dict[str, Any]]
    highest_severity: str


SEV_ORDER = {"contraindicated": 4, "major": 3, "moderate": 2, "minor": 1, "n/a": 0}


@router.post("/interactions", response_model=InteractionResponse)
async def interactions(
    body: InteractionRequest,
    request: Request,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
) -> InteractionResponse:
    drugs = [d.strip() for d in body.drugs if d and d.strip()]
    if len(drugs) < 2:
        raise HTTPException(status_code=400, detail="Need at least 2 drugs")

    curated_hits: List[Dict[str, Any]] = []
    checked = 0
    for i in range(len(drugs)):
        for j in range(i + 1, len(drugs)):
            checked += 1
            hit = _check_curated(drugs[i], drugs[j])
            if hit:
                curated_hits.append(hit)

    external: List[Dict[str, Any]] = []
    async with httpx.AsyncClient(timeout=6.0) as http:
        tasks = [_rxnav_interactions(http, d) for d in drugs]
        results = await asyncio.gather(*tasks, return_exceptions=False)
    seen: set[tuple] = set()
    for batch in results:
        for item in batch:
            key = (item.get("drug_a", "").lower(), item.get("drug_b", "").lower())
            if key in seen:
                continue
            seen.add(key)
            external.append(item)

    severity_pool = [h.get("severity", "n/a") for h in curated_hits] + [h.get("severity", "n/a") for h in external]
    highest = "n/a"
    for s in severity_pool:
        if SEV_ORDER.get(str(s).lower(), 0) > SEV_ORDER.get(highest, 0):
            highest = str(s).lower()

    client_ip = request.headers.get("x-forwarded-for", request.client.host if request.client else "unknown")
    record_audit(
        user_id=current.id,
        query=", ".join(drugs),
        mode="drugs",
        response_summary=f"{len(curated_hits) + len(external)} interaction(s) found (max severity: {highest})",
        safety_triggered=highest in {"major", "contraindicated"},
        safety_level=highest,
        confidence=None,
        evidence_grade=None,
        client_ip=client_ip,
        details={"curated": curated_hits, "external_count": len(external)},
        db=db,
    )

    return InteractionResponse(
        input=drugs,
        pairs_checked=checked,
        curated=curated_hits,
        external=external,
        highest_severity=highest,
    )
