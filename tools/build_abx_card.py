"""ICU Antibiotic Dosing Card (A4 PDF) from the ABX and CRRT_ABX tables in index.html.
The card carries exactly what the app shows, so the two never disagree; rebuild after any dose change.
Run: python3 tools/build_abx_card.py [fonts_dir]   (needs node, playwright and Chrome; fonts from the-tract/assets/fonts).
Body text is kept at 10 px (7.5 pt) or larger; rows never split across pages; header and footer repeat on every page."""
import re, json, subprocess, html, sys, pathlib, asyncio
ROOT = pathlib.Path(__file__).resolve().parent.parent
FONTS = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ROOT.parent / "the-tract/assets/fonts")
TITLE, VERSION, REVIEWED, APPV = "ICU Antibiotic Dosing Card", "1.1", "27 November 2026", "1.7.1"

s = (ROOT / "index.html").read_text(encoding="utf-8")
a, b = s.index("const ABX = ["), s.index("const ABX_CLASSES")
c = s.index("const CRRT_ABX = {"); d = s.index("\n};", c) + 3
js = s[a:b].replace("const ABX", "globalThis.ABX") + s[c:d].replace("const CRRT_ABX", "globalThis.CRRT_ABX") + \
     "\nprocess.stdout.write(JSON.stringify({ABX, CRRT_ABX}));"
data = json.loads(subprocess.run(["node", "-e", js], capture_output=True, text=True, check=True).stdout)

def raw(t): return t.replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&").replace("<b>", "").replace("</b>", "")
def E(t): return html.escape(raw(t), quote=False)

def band(lo, hi):
    if hi >= 1e9: return f"≥ {lo}"
    if lo == 0: return f"&lt; {hi}"
    return f"{lo}–{hi - 1}"

def row(x):
    bands = x["crcl"]
    if len(bands) == 1 and bands[0][0] == 0:
        ren = f'<span class="na">{E(bands[0][2])}</span>'
    else:
        ren = "".join(f'<div class="b"><span class="k">{band(lo, hi)}</span><span>{E(t)}</span></div>' for lo, hi, t in bands)
    note = f'<div class="note">{E(x["notes"])}</div>' if x.get("notes") else ""
    return (f'<tr><td class="drug"><b>{E(x["name"])}</b><small>{E(x["cls"])}</small></td>'
            f'<td class="std">{E(x["std"])}<div class="ind">{E(x.get("ind", ""))}</div>{note}</td><td class="ren">{ren}</td></tr>')

FUNG = ("Antifungal", "Antiviral")
LAST = ("colistin", "tigecycline", "fosfomycin")
bact = [x for x in data["ABX"] if not x["cls"].startswith(FUNG) and not x["id"].lower().startswith(LAST)]
last = [x for x in data["ABX"] if x["id"].lower().startswith(LAST)]
fung = [x for x in data["ABX"] if x["cls"].startswith(FUNG)]
HEAD = '<thead><tr><th style="width:20%">Drug</th><th style="width:44%">Standard adult dose · use · notes</th><th>Renal adjustment by CrCl (mL/min)</th></tr></thead>'

# Drugs listed only on the CRRT page: say so where a reader would look for them first.
names = {raw(x["name"]).split(" (")[0].split(" —")[0].lower() for x in data["ABX"]}
crrt_only = []
crrt = ""
for g in data["CRRT_ABX"].values():
    crrt += f'<tr class="grp"><td colspan="3">{E(g["label"])}</td></tr>'
    for r in g["rows"]:
        nm = raw(r["drug"])
        base = re.sub(r"\s*\(.*?\)", "", nm).replace(" IV", "")
        miss = [p.strip() for p in base.split("/") if p.strip().lower().split(" —")[0] not in names]
        only = bool(miss)
        crrt_only += miss
        mark = '<sup title="CRRT dose only">†</sup>' if only else ""
        crrt += f'<tr><td class="drug"><b>{E(nm)}{mark}</b></td><td>{E(r["base"])}</td><td class="nt">{E(r.get("note", ""))}</td></tr>'
ONLY = (f'<p class="xref">† CRRT doses only, on the CRRT pages; this card gives no non-CRRT renal dose for them: {E(", ".join(crrt_only))}.</p>'
        if crrt_only else "")

LEGEND = ('<div class="box legend"><h3>Abbreviations</h3><p><b>CrCl</b> creatinine clearance (Cockcroft–Gault) · <b>LD</b> loading dose · '
          '<b>CBA</b> colistin base activity (1 MIU ≈ 33 mg CBA) · <b>MIU</b> million international units · <b>AUC₂₄</b> 24-h area under the curve · '
          '<b>TDM</b> therapeutic drug monitoring · <b>FPIA / HPLC</b> assay methods for teicoplanin levels · <b>IHD</b> intermittent haemodialysis · '
          '<b>CRRT</b> continuous renal replacement therapy: <b>CVVH</b> haemofiltration, <b>CVVHD</b> haemodialysis, <b>CVVHDF</b> haemodiafiltration, '
          '<b>SCUF</b> slow continuous ultrafiltration · <b>cIAI / cSSTI / cUTI</b> complicated intra-abdominal / skin and soft tissue / urinary tract infection · '
          '<b>CRAB / CRE</b> carbapenem-resistant <i>A. baumannii</i> / Enterobacterales.</p></div>')

body = f'''
<h1>{TITLE}</h1>
<p class="lede">Adult doses with renal adjustment, last-line agents, antifungals and antivirals, and doses on CRRT. Taken from Najm ICUCalc v{APPV}; each table there names its sources.</p>
<h2>Antibacterials</h2>
<table class="t">{HEAD}<tbody>{"".join(row(x) for x in bact)}</tbody></table>
<h2>Last-line Gram-negative agents</h2>
<table class="t">{HEAD}<tbody>{"".join(row(x) for x in last)}</tbody></table>
<h2>Antifungals and antivirals</h2>
<table class="t">{HEAD}<tbody>{"".join(row(x) for x in fung)}</tbody></table>
{ONLY}
<div class="boxes">
<div class="box"><h3>Before you adjust</h3><ul>
<li>Give the <b>full first dose</b> whatever the kidney: adjust the maintenance dose or interval, not the load.</li>
<li>CrCl by Cockcroft–Gault. In AKI the creatinine lags; in augmented renal clearance (young, septic, trauma) standard doses can fail.</li>
<li>Extended or continuous β-lactam infusion where your unit uses it.</li></ul></div>
<div class="box"><h3>Levels</h3><ul>
<li><b>Vancomycin:</b> AUC₂₄ 400–600 mg·h/L (ASHP/IDSA 2020); trough-only monitoring is no longer recommended.</li>
<li><b>Aminoglycosides:</b> extended interval, undetectable trough; local nomogram or pharmacy levels.</li>
<li><b>Teicoplanin, voriconazole:</b> targets in their rows.</li></ul></div></div>
<h2>On CRRT (CVVHDF, effluent 25–30 mL/kg/h)</h2>
<table class="t crrt"><thead><tr><th style="width:20%">Drug</th><th style="width:46%">Dose on CRRT</th><th>Note</th></tr></thead><tbody>{crrt}</tbody></table>
<div class="boxes"><div class="box"><h3>Mode and dose</h3><ul>
<li><b>CVVH:</b> same doses as CVVHDF. <b>CVVHD:</b> vancomycin and teicoplanin cleared ~10% less.</li>
<li><b>High effluent (35–45 mL/kg/h):</b> 25–40% more clearance: shorten the interval or raise the dose; levels strongly advised.</li>
<li><b>SCUF</b> removes fluid, not drug: dose by the patient's CrCl.</li></ul></div>
<div class="box"><h3>Sources</h3><p>Sanford Guide 2024 · product labels (FDA; EMA SmPC incl. Targocid, Fomicyt) · IDSA/ATS HAP/VAP 2016 · IDSA AMR guidance 2024 · Rybak, ASHP/IDSA vancomycin 2020 · Tsuji, polymyxin consensus, Pharmacotherapy 2019 · Nation, Clin Infect Dis 2017 · Heintz, Pharmacotherapy 2009 · Jamal, Crit Care 2015 · Roberts, Lancet Infect Dis 2014 · Jarvis, AMBITION, NEJM 2022 · KDIGO AKI 2012.</p></div></div>
{LEGEND}'''

CSS = f'''@font-face{{font-family:SS;src:url("file://{FONTS}/SourceSans3-VF.woff2");font-weight:200 900}}
@font-face{{font-family:BM;src:url("file://{FONTS}/BodoniModa-VF.woff2");font-weight:400 900}}
*{{box-sizing:border-box}}body{{margin:0;font-family:SS,sans-serif;color:#14212E;-webkit-print-color-adjust:exact;print-color-adjust:exact;font-size:10.5px}}
h1{{font-family:BM,serif;font-weight:600;font-size:26px;margin:0 0 4px}}.lede{{margin:0 0 6px;color:#44525E;font-size:11px}}
h2{{font-family:BM,serif;font-weight:600;font-size:17px;margin:12px 0 5px;break-after:avoid}}h2.newpage{{break-before:page;margin-top:0}}
.t{{width:100%;border-collapse:collapse;font-size:10px;line-height:1.32}}.t thead{{display:table-header-group}}.t tr{{break-inside:avoid}}
.t th{{text-align:left;font-size:8.6px;letter-spacing:.12em;text-transform:uppercase;color:#fff;background:#1F6F68;padding:4px 6px}}
.t td{{padding:4px 6px;border-bottom:.6px solid #d5dbd8;vertical-align:top}}.t tbody tr:nth-child(even) td{{background:#F5F6F3}}
.drug b{{display:block;font-size:10.6px}}.drug small{{color:#1F6F68;font-weight:600;font-size:9px}}.drug sup{{color:#B66C4E;font-weight:800;margin-left:2px}}
.ind{{color:#44525E;font-size:9.4px;margin-top:1px}}.note{{margin-top:2px;font-size:9.4px;color:#7a3e27}}
.b{{display:flex;gap:6px}}.b .k{{flex:none;width:42px;font-weight:700;color:#1F6F68}}.na{{color:#44525E;font-style:italic}}
.crrt .grp td{{background:#e6efed!important;font-weight:700;font-size:9.4px;letter-spacing:.05em;color:#17554F}}.nt{{color:#44525E;font-size:9.4px}}
.xref{{font-size:9.6px;color:#44525E;margin:6px 0 0}}
.boxes{{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:10px;break-inside:avoid}}.box{{border:1px solid #c9d3d0;border-left:3px solid #1F6F68;border-radius:4px;padding:6px 9px;font-size:10px;line-height:1.4;break-inside:avoid}}
.box h3{{margin:0 0 3px;font-size:8.8px;letter-spacing:.14em;text-transform:uppercase;color:#1F6F68}}.box ul{{margin:0;padding-left:13px}}.box p{{margin:0}}.legend{{margin-top:8px}}'''

LOGO = '<svg viewBox="0 0 100 100" width="16" height="16" style="vertical-align:-3px;margin-right:6px"><rect width="100" height="100" rx="14" fill="#14212E"/><path d="M18 27H82M44 27V64a14 14 0 0 0 14 14H70" stroke="#F5F6F3" stroke-width="8" fill="none"/><circle cx="75" cy="78" r="6" fill="#B66C4E"/></svg>'
HDR = (f'<div style="width:100%;margin:0 11mm;padding-bottom:4px;border-bottom:1.5px solid #14212E;display:flex;justify-content:space-between;'
       f'font-family:sans-serif;font-size:8px;color:#14212E"><span style="font-weight:800;letter-spacing:.14em;text-transform:uppercase">{LOGO}{TITLE}</span>'
       f'<span style="color:#44525E">Najm ICUCalc · card v{VERSION} · reviewed {REVIEWED} · page <span class="pageNumber"></span> of <span class="totalPages"></span></span></div>')
FTR = ('<div style="width:100%;margin:0 11mm;padding-top:4px;border-top:.8px solid #c9d3d0;font-family:sans-serif;font-size:7.6px;color:#44525E;line-height:1.35">'
       'Adult doses. A reference, not an order set: check the product label, your hospital protocol and antibiogram, and involve your pharmacist. '
       'Live version with sources: icucalc.thetract.org · © The Tract · thetract.org</div>')

doc = f'<!doctype html><meta charset="utf-8"><title>{TITLE}</title><style>{CSS}</style>{body}'
tmp = pathlib.Path("/tmp/abx_card.html"); tmp.write_text(doc, encoding="utf-8")

async def render():
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        br = await p.chromium.launch(executable_path="/usr/bin/google-chrome")
        pg = await br.new_page(); await pg.goto(tmp.as_uri()); await pg.wait_for_timeout(400)
        await pg.pdf(path=str(ROOT / "abx-card.pdf"), format="A4", print_background=True, display_header_footer=True,
                     header_template=HDR, footer_template=FTR, margin={"top": "17mm", "bottom": "16mm", "left": "11mm", "right": "11mm"})
        await br.close()
asyncio.run(render())
print("CRRT-only drugs:", crrt_only)
