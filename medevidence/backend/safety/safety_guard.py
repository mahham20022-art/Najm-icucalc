"""Pre-LLM safety guard. Runs before every clinical LLM call.

Levels:
    EMERGENCY: deterministic protocol is returned immediately, LLM is skipped.
    ESCALATE : banner is added, LLM is still invoked.
    SAFE     : no safety action.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from enum import Enum
from typing import List, Optional, Tuple


class SafetyLevel(str, Enum):
    SAFE = "SAFE"
    ESCALATE = "ESCALATE"
    EMERGENCY = "EMERGENCY"


@dataclass
class SafetyResult:
    level: SafetyLevel
    category: Optional[str]
    message: Optional[str]
    protocol: Optional[dict]
    matched_terms: List[str]

    def as_banner(self) -> Optional[dict]:
        if self.level == SafetyLevel.SAFE:
            return None
        return {
            "level": self.level.value,
            "category": self.category,
            "message": self.message,
            "matched_terms": self.matched_terms,
        }


EMERGENCY_PROTOCOLS: dict[str, dict] = {
    "cardiac_arrest": {
        "title": "Adult Cardiac Arrest (ACLS)",
        "immediate_actions": [
            "Call code/activate emergency response and start CPR: 30:2, depth >=5 cm, rate 100-120/min.",
            "Attach defibrillator/AED as soon as available; analyze rhythm every 2 minutes.",
            "If shockable (VF/pVT): defibrillate (biphasic 120-200 J), resume CPR immediately.",
            "Epinephrine 1 mg IV/IO every 3-5 minutes.",
            "Consider amiodarone 300 mg IV after 3rd shock (or lidocaine 1-1.5 mg/kg).",
            "Treat reversible causes: Hs (hypoxia, hypovolemia, H+, hypo/hyperkalemia, hypothermia) and Ts (tension pneumothorax, tamponade, toxins, thrombosis).",
        ],
        "references": ["AHA 2020 ACLS Guidelines"],
    },
    "airway_emergency": {
        "title": "Airway Emergency / Can't Intubate, Can't Oxygenate",
        "immediate_actions": [
            "Call for airway help; position patient, jaw thrust, 100% O2 via BVM.",
            "Place oral/nasal airway; attempt two-person bag-mask ventilation.",
            "Prepare for rapid sequence intubation (ketamine 1-2 mg/kg + rocuronium 1.2 mg/kg).",
            "If failed intubation: supraglottic airway (LMA).",
            "If CICO: front-of-neck access (scalpel-bougie-tube cricothyroidotomy).",
        ],
        "references": ["DAS 2015 Difficult Airway Guidelines"],
    },
    "status_epilepticus": {
        "title": "Convulsive Status Epilepticus",
        "immediate_actions": [
            "Secure airway, O2, IV access, check glucose.",
            "0-5 min: Lorazepam 0.1 mg/kg IV (max 4 mg) or midazolam 10 mg IM if no IV.",
            "5-10 min: repeat benzodiazepine dose if seizing.",
            "20 min: levetiracetam 60 mg/kg IV (max 4500 mg) OR fosphenytoin 20 mg PE/kg OR valproate 40 mg/kg.",
            "40 min: anesthetic infusion (midazolam/propofol/ketamine) and intubate; continuous EEG.",
        ],
        "references": ["Neurocritical Care Society 2016 Status Epilepticus Guidelines"],
    },
    "overdose": {
        "title": "Suspected Overdose / Toxic Ingestion",
        "immediate_actions": [
            "ABCs, O2, continuous monitoring, IV access, bedside glucose.",
            "Naloxone 0.04-0.4 mg IV titrated for opioid toxidrome (respiratory depression).",
            "Flumazenil is generally AVOIDED empirically.",
            "Activated charcoal 1 g/kg within 1 h of ingestion (if airway protected, no contraindication).",
            "Specific antidotes: N-acetylcysteine (APAP), sodium bicarbonate (TCA QRS >100 ms), calcium + glucagon + high-dose insulin (CCB/BB), hydroxocobalamin (cyanide).",
            "Contact Poison Control (US 1-800-222-1222) / local toxicology service.",
        ],
        "references": ["Goldfrank's Toxicologic Emergencies"],
    },
    "pediatric_emergency": {
        "title": "Pediatric Emergency (PALS)",
        "immediate_actions": [
            "Use length-based tape (Broselow) for weight-based dosing.",
            "Airway/breathing: 100% O2, BVM at 20-30/min for infants, 15/min older children.",
            "Compressions 15:2 (two-rescuer), depth 1/3 AP chest, rate 100-120/min.",
            "Epinephrine 0.01 mg/kg IV/IO (0.1 mL/kg of 1:10,000) every 3-5 minutes.",
            "Fluid bolus 20 mL/kg isotonic crystalloid for shock; reassess.",
            "Glucose: D10W 5 mL/kg IV for hypoglycemia.",
        ],
        "references": ["AHA 2020 PALS Guidelines"],
    },
    "psychiatric_emergency": {
        "title": "Acute Psychiatric Emergency / Suicide Risk",
        "immediate_actions": [
            "Ensure patient and staff safety; remove means of harm; continuous observation.",
            "Perform structured suicide risk assessment (Columbia-Suicide Severity Rating Scale).",
            "Engage psychiatry / crisis team immediately.",
            "Treat reversible medical causes (hypoxia, hypoglycemia, intoxication, delirium).",
            "Consider chemical restraint only if imminent danger: haloperidol 5 mg + lorazepam 2 mg IM (avoid in delirium of unclear etiology, elderly).",
            "US: 988 Suicide and Crisis Lifeline. Never leave patient alone.",
        ],
        "references": ["APA Practice Guideline for Assessment of Suicidal Behaviors"],
    },
    "obstetric_emergency": {
        "title": "Obstetric Emergency",
        "immediate_actions": [
            "Left lateral tilt (>20 weeks); large-bore IV access x2; type & cross.",
            "Postpartum hemorrhage: bimanual uterine massage, oxytocin 10 U IM/40 U in 1L NS, tranexamic acid 1 g IV, carboprost 250 mcg IM (avoid asthma), methylergonovine 0.2 mg IM (avoid HTN), misoprostol 800-1000 mcg PR.",
            "Eclampsia: magnesium sulfate 4-6 g IV load then 1-2 g/h; control BP (labetalol/hydralazine); delivery is definitive.",
            "Amniotic fluid embolism / cord prolapse / shoulder dystocia: activate OB emergency team and prepare for operative delivery.",
        ],
        "references": ["ACOG Practice Bulletins"],
    },
}


_EMERGENCY_PATTERNS: List[Tuple[str, List[str]]] = [
    ("cardiac_arrest", [
        r"\bcardiac arrest\b", r"\bvfib\b", r"\bv[- ]?fib\b", r"\bventricular fibrillation\b",
        r"\bpulseless\b", r"\basystole\b", r"\bpea\b", r"\bcode blue\b",
        r"\bno pulse\b", r"\bunresponsive and not breathing\b",
    ]),
    ("airway_emergency", [
        r"\bcannot intubate\b", r"\bcan't intubate\b", r"\bcan't ventilate\b",
        r"\bcannot ventilate\b", r"\bairway obstruct(ion|ed)\b", r"\bstridor\b",
        r"\banaphylaxis\b", r"\bangio(edema|oedema)\b", r"\bfailed airway\b",
    ]),
    ("status_epilepticus", [
        r"\bstatus epilepticus\b", r"\bcontinuous seizure\b", r"\bseizing for\b",
        r"\brefractory seizure\b", r"\bconvulsing for\b",
    ]),
    ("overdose", [
        r"\boverdose\b", r"\bingested\b.*\b(pills|bottle|medication)\b",
        r"\btoxic ingestion\b", r"\bpoisoning\b", r"\bsuicidal ingestion\b",
        r"\bopioid overdose\b", r"\btylenol overdose\b", r"\bacetaminophen overdose\b",
    ]),
    ("pediatric_emergency", [
        r"\b(infant|neonate|newborn|child|pediatric)\b.*\b(arrest|unresponsive|apnea|not breathing|blue|cyanotic)\b",
        r"\bpediatric code\b",
    ]),
    ("psychiatric_emergency", [
        r"\bsuicid(e|al)\b", r"\bkilling myself\b", r"\bhomicidal\b",
        r"\bself[- ]?harm\b", r"\bintent to harm\b",
    ]),
    ("obstetric_emergency", [
        r"\bpostpartum h(a)?emorrhage\b", r"\bpph\b", r"\beclampsia\b",
        r"\bcord prolapse\b", r"\bshoulder dystocia\b", r"\bamniotic fluid embolism\b",
        r"\bplacental abruption\b",
    ]),
]

_ESCALATE_PATTERNS: List[Tuple[str, List[str]]] = [
    ("sepsis", [r"\bsepsis\b", r"\bseptic shock\b", r"\blactate\s*>\s*4\b"]),
    ("stroke", [r"\bstroke\b", r"\bacute cva\b", r"\blvo\b", r"\blarge vessel occlusion\b"]),
    ("stemi", [r"\bstemi\b", r"\bst[- ]elevation\b"]),
    ("dka", [r"\bdka\b", r"\bdiabetic ketoacidosis\b"]),
    ("pe", [r"\bpulmonary embolism\b", r"\bmassive pe\b"]),
    ("gi_bleed", [r"\bgi bleed\b", r"\bhemorrhagic shock\b", r"\bmelena with hypotension\b"]),
    ("chest_pain", [r"\bchest pain\b"]),
    ("pregnancy", [r"\bpregnan(t|cy)\b", r"\bgestation(al)?\b", r"\btrimester\b"]),
]


def _match(patterns: List[Tuple[str, List[str]]], text: str) -> Tuple[Optional[str], List[str]]:
    found: List[str] = []
    category: Optional[str] = None
    for cat, regexes in patterns:
        for regex in regexes:
            match = re.search(regex, text, flags=re.IGNORECASE)
            if match:
                found.append(match.group(0).lower())
                if category is None:
                    category = cat
    return category, found


def evaluate(query: str) -> SafetyResult:
    text = (query or "").strip()
    if not text:
        return SafetyResult(SafetyLevel.SAFE, None, None, None, [])

    category, matches = _match(_EMERGENCY_PATTERNS, text)
    if category:
        protocol = EMERGENCY_PROTOCOLS.get(category)
        return SafetyResult(
            level=SafetyLevel.EMERGENCY,
            category=category,
            message=(
                "Emergency pattern detected. A deterministic protocol is shown. "
                "This is decision support only; activate your local emergency response immediately."
            ),
            protocol=protocol,
            matched_terms=matches,
        )

    category, matches = _match(_ESCALATE_PATTERNS, text)
    if category:
        return SafetyResult(
            level=SafetyLevel.ESCALATE,
            category=category,
            message="Time-sensitive condition suspected. Proceed with urgent evaluation and escalation.",
            protocol=None,
            matched_terms=matches,
        )

    return SafetyResult(SafetyLevel.SAFE, None, None, None, [])


def emergency_payload(result: SafetyResult, query: str) -> dict:
    """Return a fully-formed clinical response for EMERGENCY cases, bypassing the LLM."""
    protocol = result.protocol or {}
    answer = (
        f"EMERGENCY PROTOCOL: {protocol.get('title', result.category or 'Emergency')}. "
        "Activate your local emergency response now. This deterministic protocol is decision support only."
    )
    return {
        "answer": answer,
        "reasoning": "Emergency keyword match bypassed LLM per safety policy.",
        "differential": [],
        "red_flags": protocol.get("immediate_actions", [])[:3],
        "management_plan": protocol.get("immediate_actions", []),
        "references": [{"title": ref, "source": "guideline"} for ref in protocol.get("references", [])],
        "confidence_level": 1.0,
        "evidence_grade": "1a",
        "explainability": (
            f"Deterministic emergency pathway triggered by terms: {', '.join(result.matched_terms) or result.category}. "
            "No generative model was invoked for this response."
        ),
        "safety": result.as_banner(),
        "query": query,
    }
