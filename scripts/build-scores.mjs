// Crawlable score pages for search: one working calculator page per score
// (scores/<slug>/), an index (scores/) and sitemap.xml. Everything is read
// from the app itself (SCORES in index.html and each card's title, summary
// and source), so the pages can never disagree with the calculator.
//   node scripts/build-scores.mjs
import { readFileSync, writeFileSync, mkdirSync, rmSync } from 'node:fs';

const BASE = 'https://icucalc.thetract.org';
const html = readFileSync('index.html', 'utf8');

// 1) SCORES object
const start = html.indexOf('const SCORES = {');
let depth = 0, end = -1;
for (let i = html.indexOf('{', start); i < html.length; i++) {
  if (html[i] === '{') depth++;
  else if (html[i] === '}') { depth--; if (depth === 0) { end = i + 1; break; } }
}
const SCORES = new Function(`return (${html.slice(html.indexOf('{', start), end)});`)();

// 2) card text per score
const strip = (s) => s.replace(/<[^>]+>/g, '').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/\s+/g, ' ').trim();
const cards = {};
for (const m of html.matchAll(/<div class="card"><h3>(.*?)<\/h3><div class="sub">(.*?)<\/div><div id="score-(\w+)"><\/div><div class="src">(.*?)<\/div><\/div>/g)) {
  cards[m[3]] = { title: strip(m[1]), sub: strip(m[2]), src: strip(m[4]) };
}

const E = (s) => String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const slugify = (s) => s.toLowerCase().normalize('NFKD').replace(/[₀-₉]/g, (c) => String(c.charCodeAt(0) - 8320)).replace(/[^\w\s-]/g, ' ').trim().replace(/[\s_-]+/g, '-');

// What each score is for, in the words people search with.
const ABOUT = {
  gcs: 'Glasgow Coma Scale', qsofa: 'quick SOFA (qSOFA)', sofa: 'SOFA score', chads: 'CHA₂DS₂-VASc score', hasbled: 'HAS-BLED score',
  wells: 'Wells score for pulmonary embolism', rass: 'Richmond Agitation–Sedation Scale (RASS)', duke: 'Duke-ISCVID 2023 criteria for infective endocarditis',
  apache2: 'APACHE II score', heart: 'HEART score for chest pain', timi: 'TIMI risk score for UA/NSTEMI', curb65: 'CURB-65 score for pneumonia',
  ich: 'ICH score for intracerebral haemorrhage', nihss: 'NIH Stroke Scale (NIHSS)', hunthess: 'Hunt and Hess grade for subarachnoid haemorrhage',
  fisher: 'modified Fisher scale for subarachnoid haemorrhage', childpugh: 'Child-Pugh score for cirrhosis', camicu: 'CAM-ICU delirium assessment',
  candida: 'Candida score (León)', padua: 'Padua prediction score for VTE', murray: 'Murray Lung Injury Score',
};

// Interpretation bands: run the app's own interpreter over every possible
// total and merge runs that say the same thing.
const NO_BANDS = new Set(['duke', 'camicu', 'murray']);  // interpretation depends on which items, not only the sum
const rng = (a, b) => a === b ? String(a) : (a < 0 || b < 0) ? `${a} to ${b}` : `${a}–${b}`;
function bands(sc) {
  const lo = sc.items.reduce((a, it) => a + Math.min(...it.opts.map((o) => o[1])), 0);
  const hi = sc.items.reduce((a, it) => a + Math.max(...it.opts.map((o) => o[1])), 0);
  if (!Number.isFinite(lo) || !Number.isFinite(hi) || hi - lo > 80) return null;
  const rows = [];
  for (let t = lo; t <= hi; t++) {
    let r; try { r = sc.i(t, {}, sc.items); } catch { return null; }
    if (!r) return null;
    // drop a leading total ("7 pts →", "Total 7 ·", "Grade 3 —"): the table's first column shows it
    const msg = String(r[0]).replace(new RegExp(`^(Total\\s+|Grade\\s+)?${t}(\\s*pts?)?\\s*(→|·|—|-|:)?\\s*`), '');
    const last = rows[rows.length - 1];
    if (last && last.msg === msg && last.level === r[1]) last.to = t; else rows.push({ from: t, to: t, msg, level: r[1] });
  }
  return rows;
}

const CSS = `*{box-sizing:border-box}body{margin:0;background:#060d19;color:#eaf1fb;font:16.5px/1.6 Inter,system-ui,-apple-system,Segoe UI,sans-serif}
a{color:#38bdf8}header,main,footer{max-width:760px;margin:0 auto;padding:0 18px}
header{display:flex;align-items:center;gap:10px;padding-top:16px;padding-bottom:16px;border-bottom:1px solid #1a2942}
.brand{color:#eaf1fb;text-decoration:none;font-weight:700;letter-spacing:-.01em}.brand b{color:#22d3ee}
.cta{margin-left:auto;background:#22d3ee;color:#001018;text-decoration:none;font-weight:700;padding:8px 14px;border-radius:999px;font-size:14px}
.k{margin:28px 0 6px;font:700 11.5px ui-monospace,Menlo,monospace;letter-spacing:.14em;text-transform:uppercase;color:#22d3ee}
h1{margin:0 0 10px;font-size:clamp(28px,6vw,40px);line-height:1.12;letter-spacing:-.02em}h2{margin:30px 0 10px;font-size:20px}
.lead{color:#b8c6dc}.calc{background:#0a1424;border:1px solid #1a2942;border-radius:16px;padding:16px;margin:18px 0}
.item{padding:10px 0;border-bottom:1px solid #1a2942}.item:last-of-type{border-bottom:0}.item>b{display:block;margin-bottom:6px;font-size:15px}
.opts{display:flex;flex-wrap:wrap;gap:6px}.opts label{display:inline-flex;align-items:center;gap:6px;padding:6px 10px;border:1px solid #26406b;border-radius:10px;font-size:14px;cursor:pointer}
.opts input{accent-color:#22d3ee}.opts label:has(input:checked){border-color:#22d3ee;background:rgba(34,211,238,.1)}
.total{position:sticky;bottom:10px;margin-top:12px;padding:12px 14px;border-radius:12px;background:#0f1e35;border:1px solid #26406b;font-weight:600}
.total.ok{border-color:#34d399}.total.warn{border-color:#fbbf24}.total.bad{border-color:#f87171}
table{width:100%;border-collapse:collapse;font-size:15px}td,th{padding:8px 10px;border-bottom:1px solid #1a2942;text-align:left;vertical-align:top}th{color:#7f92ae;font-weight:600}
td.n{white-space:nowrap;font-weight:700}.ok{color:#34d399}.warn{color:#fbbf24}.bad{color:#f87171}
.src{color:#b8c6dc;font-size:14.5px}.note{color:#7f92ae;font-size:14px}.list a{display:block;padding:9px 0;border-bottom:1px solid #1a2942;text-decoration:none}
footer{padding-top:24px;padding-bottom:40px;color:#7f92ae;font-size:13.5px;border-top:1px solid #1a2942;margin-top:36px}`;

const GC = `<script>window.goatcounter={path:function(p){return 'icucalc'+p}}</script><script data-goatcounter="https://naaajm.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script>`;
const head = (title, desc, path, ld) => `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${E(title)}</title><meta name="description" content="${E(desc)}"><link rel="canonical" href="${BASE}/${path}">
<meta property="og:title" content="${E(title)}"><meta property="og:description" content="${E(desc)}"><meta property="og:url" content="${BASE}/${path}"><meta property="og:site_name" content="Najm ICUCalc">
<meta name="theme-color" content="#060d19"><link rel="icon" href="/icons/icon-192.png"><style>${CSS}</style>
<script type="application/ld+json">${JSON.stringify(ld)}</script>${GC}</head><body>
<header><a class="brand" href="/scores/">Najm <b>ICUCalc</b></a><a class="cta" href="/#scores">Open the full app</a></header><main>`;
const foot = `</main><footer>Najm ICUCalc is a free bedside calculator by Dr Mohamed Najm, published by <a href="https://thetract.org/">The Tract</a> and listed in the LITFL App Store. Decision support only: check every result against the patient and your local protocols.</footer></body></html>`;

// Quiet pointer to the ICU practice questions that moved to Med100 (one line, no banner).
const M100 = 'https://med100.thetract.org/?ref=icucalc#/icu';
const ICU_TOPIC = { gcs: 'neurology', nihss: 'neurology', 'hunt-hess': 'neurology', 'ich-score': 'neurology', 'modified-fisher': 'neurology',
  'cam-icu': 'delirium-sedation', rass: 'delirium-sedation', 'heart-score': 'cardiac', timi: 'cardiac', 'cha2ds2-vasc': 'cardiac',
  'murray-lung-injury-score': 'ards', 'curb-65': 'antibiotics', 'duke-iscvid-2023': 'antibiotics', 'candida-score': 'antibiotics' };
rmSync('scores', { recursive: true, force: true });
const pages = [];
for (const [key, sc] of Object.entries(SCORES)) {
  const card = cards[key]; if (!card) continue;
  const name = ABOUT[key] || card.title;
  const slug = slugify(card.title.replace(/\(.*?\)/g, '').trim()) || key;
  const b = NO_BANDS.has(key) ? null : bands(sc);
  const items = sc.items.map((it, i) => `<div class="item"><b>${E(it.k)}</b><div class="opts">${it.opts.map((o) =>
    `<label><input type="radio" name="i${i}" value="${o[1]}">${E(o[0])}</label>`).join('')}</div></div>`).join('');
  const table = b ? `<h2>How to read the total</h2><table><tr><th>Total</th><th>Interpretation in ICUCalc</th></tr>${b.map((r) =>
    `<tr><td class="n">${rng(r.from, r.to)}</td><td class="${E(r.level)}">${E(r.msg)}</td></tr>`).join('')}</table>` : '';
  const pts = `<h2>Items and points</h2><table><tr><th>Item</th><th>Options (points)</th></tr>${sc.items.map((it) =>
    `<tr><td>${E(it.k)}</td><td>${it.opts.map((o) => `${E(o[0].replace(/\s*\(\d+\)$/, ''))} (${o[1]})`).join(' · ')}</td></tr>`).join('')}</table>`;
  const title = `${card.title} calculator — items, points and interpretation | Najm ICUCalc`;
  const desc = `Free ${name} calculator. ${card.sub}`.slice(0, 300);
  const ld = { '@context': 'https://schema.org', '@type': 'MedicalWebPage', name: `${card.title} calculator`, description: desc, url: `${BASE}/scores/${slug}/`,
    about: { '@type': 'MedicalScholarlyArticle', name }, audience: { '@type': 'MedicalAudience', audienceType: 'Clinician' },
    publisher: { '@type': 'Organization', name: 'The Tract', url: 'https://thetract.org/' }, isPartOf: { '@type': 'WebApplication', name: 'Najm ICUCalc', url: `${BASE}/` } };
  // The page runs the app's own interpreter (same function source) on the chosen items.
  const interp = `const ITEMS=${JSON.stringify(sc.items)};const I=${sc.i.toString()};`;
  const body = `<div class="k">Score · ICU</div><h1>${E(card.title)} calculator</h1><p class="lead">${E(card.sub)}</p>
<form class="calc" id="f">${items}<div class="total" id="tot">Choose an option for each item.</div></form>
${table}${pts}
<h2>Source</h2><p class="src">${E(card.src)}</p>
<p class="note">Scores support judgement; they do not replace it. <a href="/#scores">All ICUCalc scores</a> · <a href="/">Drip rates, ventilation, ABG and protocols</a></p>
<p class="note">Test yourself: <a href="${M100}/${ICU_TOPIC[slug] || 'scores'}">ICU practice questions on Med100</a>, free.</p>
<script>${interp}const f=document.getElementById('f'),out=document.getElementById('tot'),n=${sc.items.length};
f.addEventListener('change',()=>{let t=0,c=0;const vals={};for(let i=0;i<n;i++){const v=f.querySelector('input[name=i'+i+']:checked');if(v){t+=+v.value;c++;vals[i]=+v.value}else vals[i]=''}
let r=null;try{r=I(t,vals,ITEMS)}catch(e){}const done=c===n;out.className='total '+(r&&(done||${NO_BANDS.has(key) ? 'true' : 'false'})?r[1]:'');
out.textContent=r&&(done||${NO_BANDS.has(key) ? 'true' : 'false'})?(${key === 'duke' || NO_BANDS.has(key) ? "r[0]" : "/^(Total\\s+|Grade\\s+)?\\d/.test(r[0])?r[0]:('Total '+t+' · '+r[0])"}):('Total so far: '+t+' ('+c+' of '+n+' items)');});</script>`;
  mkdirSync(`scores/${slug}`, { recursive: true });
  writeFileSync(`scores/${slug}/index.html`, head(title, desc, `scores/${slug}/`, ld) + body + foot);
  pages.push({ slug, title: card.title, sub: card.sub });
}

const idx = `<div class="k">Najm ICUCalc</div><h1>ICU and emergency scores</h1><p class="lead">${pages.length} bedside scores, each with its items, points, interpretation and source, from the same engine as the app. Free, no sign-up, works on a phone.</p>
<div class="list">${pages.map((p) => `<a href="${p.slug}/"><b>${E(p.title)}</b><br><span class="note">${E(p.sub)}</span></a>`).join('')}</div>`;
mkdirSync('scores', { recursive: true });
writeFileSync('scores/index.html', head('ICU scores: APACHE II, SOFA, GCS, HEART, NIHSS and more | Najm ICUCalc', `Free ICU and emergency score calculators: ${pages.map((p) => p.title).join(', ')}.`.slice(0, 300), 'scores/',
  { '@context': 'https://schema.org', '@type': 'CollectionPage', name: 'ICU scores', url: `${BASE}/scores/` }) + idx + foot);

const today = new Date().toISOString().slice(0, 10);
const urls = [`${BASE}/`, `${BASE}/scores/`, ...pages.map((p) => `${BASE}/scores/${p.slug}/`), `${BASE}/privacy-policy.html`];
writeFileSync('sitemap.xml', `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls.map((u) => `  <url><loc>${u}</loc><lastmod>${today}</lastmod></url>`).join('\n')}\n</urlset>\n`);
console.log(`scores: ${pages.length} pages; sitemap ${urls.length} URLs; skipped: ${Object.keys(SCORES).filter((k) => !cards[k]).join(',') || 'none'}`);
