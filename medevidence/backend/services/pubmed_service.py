"""Live PubMed E-utilities client.

Two calls:
    esearch -> list of PMIDs for the query
    efetch  -> XML with title, abstract, pub year, journal

Results are returned as a list of evidence dicts shaped for the RAG pipeline.
"""
from __future__ import annotations

import asyncio
import re
from typing import Any, Dict, List, Optional
from xml.etree import ElementTree as ET

import httpx

from core.config import get_settings
from core.logging import get_logger

logger = get_logger("pubmed")
_settings = get_settings()

ESEARCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
EFETCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

_PUB_TYPE_GRADE = {
    "meta-analysis": "1a",
    "systematic review": "1a",
    "randomized controlled trial": "1b",
    "clinical trial": "2b",
    "cohort study": "2b",
    "case-control study": "3b",
    "case reports": "4",
    "review": "3a",
    "editorial": "5",
    "comment": "5",
}


def _infer_grade(pub_types: List[str]) -> str:
    for pub in pub_types:
        key = pub.lower()
        if key in _PUB_TYPE_GRADE:
            return _PUB_TYPE_GRADE[key]
    return "3a"


async def search(query: str, retmax: Optional[int] = None) -> List[Dict[str, Any]]:
    retmax = retmax or _settings.RAG_PUBMED_K
    if not query or not query.strip():
        return []

    params = {
        "db": "pubmed",
        "term": query,
        "retmax": str(retmax),
        "retmode": "json",
        "sort": "relevance",
        "tool": "medevidence",
        "email": _settings.PUBMED_EMAIL,
    }
    if _settings.PUBMED_API_KEY:
        params["api_key"] = _settings.PUBMED_API_KEY

    try:
        async with httpx.AsyncClient(timeout=_settings.PUBMED_TIMEOUT) as http:
            search_resp = await http.get(ESEARCH_URL, params=params)
            search_resp.raise_for_status()
            ids = (
                search_resp.json()
                .get("esearchresult", {})
                .get("idlist", [])
            )
            if not ids:
                return []
            return await _fetch_details(http, ids)
    except httpx.HTTPError as exc:
        logger.warning("pubmed_http_error", extra={"error": str(exc)})
        return []
    except Exception as exc:  # pragma: no cover
        logger.warning("pubmed_error", extra={"error": str(exc)})
        return []


async def _fetch_details(http: httpx.AsyncClient, pmids: List[str]) -> List[Dict[str, Any]]:
    params = {
        "db": "pubmed",
        "id": ",".join(pmids),
        "retmode": "xml",
        "tool": "medevidence",
        "email": _settings.PUBMED_EMAIL,
    }
    if _settings.PUBMED_API_KEY:
        params["api_key"] = _settings.PUBMED_API_KEY
    resp = await http.get(EFETCH_URL, params=params)
    resp.raise_for_status()
    return _parse_pubmed_xml(resp.text)


def _parse_pubmed_xml(xml_text: str) -> List[Dict[str, Any]]:
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError as exc:
        logger.warning("pubmed_xml_parse_error", extra={"error": str(exc)})
        return []

    results: List[Dict[str, Any]] = []
    for article in root.iter("PubmedArticle"):
        pmid_el = article.find(".//PMID")
        pmid = pmid_el.text.strip() if pmid_el is not None and pmid_el.text else None
        title_el = article.find(".//ArticleTitle")
        title = _text(title_el)
        abstract_parts = [
            _text(el) for el in article.findall(".//Abstract/AbstractText")
        ]
        abstract = " ".join(part for part in abstract_parts if part).strip()
        journal = _text(article.find(".//Journal/Title"))
        year = _first_int(
            _text(article.find(".//JournalIssue/PubDate/Year"))
            or _text(article.find(".//PubDate/Year"))
        )
        pub_types = [
            _text(el) for el in article.findall(".//PublicationTypeList/PublicationType") if _text(el)
        ]
        doi = None
        for el in article.findall(".//ArticleIdList/ArticleId"):
            if el.attrib.get("IdType", "").lower() == "doi":
                doi = _text(el)
                break

        if not pmid or not title:
            continue

        results.append({
            "pmid": pmid,
            "title": title,
            "abstract": abstract,
            "journal": journal,
            "year": year,
            "doi": doi,
            "pub_types": pub_types,
            "grade": _infer_grade(pub_types),
            "url": f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/",
            "source": "pubmed",
        })
    return results


def _text(el: Optional[ET.Element]) -> str:
    if el is None:
        return ""
    return re.sub(r"\s+", " ", "".join(el.itertext())).strip()


def _first_int(value: str) -> Optional[int]:
    if not value:
        return None
    m = re.search(r"\d{4}", value)
    return int(m.group(0)) if m else None


async def ping() -> bool:
    try:
        async with httpx.AsyncClient(timeout=3.0) as http:
            r = await http.get(ESEARCH_URL, params={"db": "pubmed", "term": "test", "retmax": "1", "retmode": "json"})
            return r.status_code == 200
    except Exception:
        return False


if __name__ == "__main__":  # pragma: no cover
    async def _demo() -> None:
        hits = await search("acute ischemic stroke thrombolysis window")
        for h in hits[:3]:
            print(h["pmid"], h["title"])

    asyncio.run(_demo())
