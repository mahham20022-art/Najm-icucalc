# Najm-icucalc
Icu used drugs calculator 
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Najm ICUCalc v3</title>

<style>
body {
  margin: 0;
  font-family: Arial;
  background: #0b1220;
  color: #e5e7eb;
}

header {
  background: #0284c7;
  padding: 14px;
  text-align: center;
  font-weight: bold;
  font-size: 18px;
}

.container {
  max-width: 900px;
  margin: auto;
  padding: 16px;
}

input {
  width: 100%;
  padding: 14px;
  font-size: 18px;
  border-radius: 10px;
  border: none;
  margin-bottom: 10px;
}

.buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 15px;
}

button {
  flex: 1;
  padding: 10px;
  border: none;
  border-radius: 8px;
  background: #1f2937;
  color: white;
}

button:hover {
  background: #374151;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 12px;
}

.card {
  background: #111827;
  padding: 14px;
  border-radius: 12px;
  border: 1px solid #1f2937;
}

.card h3 {
  margin-top: 0;
  color: #38bdf8;
}

.dose {
  margin: 6px 0;
  font-size: 14px;
}

.low { color: #fbbf24; }
.mid { color: #34d399; }
.high { color: #ef4444; }

.footer {
  text-align: center;
  font-size: 11px;
  color: #6b7280;
  margin: 20px;
}
</style>
</head>

<body>

<header>Najm ICUCalc v3 — Critical Care Mode</header>

<div class="container">

<input type="number" id="weight" placeholder="Enter weight (kg)" oninput="calc()">

<div class="buttons">
  <button onclick="setWeight(60)">60kg</button>
  <button onclick="setWeight(70)">70kg</button>
  <button onclick="setWeight(80)">80kg</button>
  <button onclick="setWeight(90)">90kg</button>
</div>

<div class="grid">

<div class="card">
<h3>Sedation</h3>
<div class="dose">Fentanyl: <span id="fentanyl"></span></div>
<div class="dose">Propofol: <span id="propofol"></span></div>
<div class="dose">Midazolam: <span id="midazolam"></span></div>
<div class="dose">Dexmedetomidine: <span id="dex"></span></div>
</div>

<div class="card">
<h3>Inotropes</h3>
<div class="dose">Norepinephrine: <span id="norepi"></span></div>
<div class="dose">Epinephrine: <span id="epi"></span></div>
<div class="dose">Dopamine: <span id="dop"></span></div>
<div class="dose">Dobutamine: <span id="dob"></span></div>
</div>

<div class="card">
<h3>Antihypertensives</h3>
<div class="dose">Esmolol: <span id="esmo"></span></div>
<div class="dose">Nicardipine: 5–15 mg/hr</div>
<div class="dose">Labetalol: 2–8 mg/min</div>
</div>

</div>

<div class="footer">
For clinical reference only — always verify ICU protocols
</div>

</div>

<script>

const drugs = {
  fentanyl: [1, 5],
  propofol: [5, 50],
  midazolam: [0.02, 0.1],
  dex: [0.2, 0.7],

  norepi: [0.01, 1],
  epi: [0.01, 1],
  dop: [2, 20],
  dob: [2, 20],

  esmo: [50, 300]
};

function calc() {
  const w = parseFloat(document.getElementById("weight").value);
  if (!w || w <= 0) return clearAll();

  set("fentanyl", drugs.fentanyl, w);
  set("propofol", drugs.propofol, w);
  set("midazolam", drugs.midazolam, w);
  set("dex", drugs.dex, w);

  set("norepi", drugs.norepi, w);
  set("epi", drugs.epi, w);
  set("dop", drugs.dop, w);
  set("dob", drugs.dob, w);

  set("esmo", drugs.esmo, w);
}

function set(id, range, w) {
  const min = range[0] * w;
  const max = range[1] * w;

  const el = document.getElementById(id);

  let cls = "mid";
  if (max > min * 5) cls = "high";
  else if (max < min * 2) cls = "low";

  el.className = cls;
  el.innerText = `${min.toFixed(2)} – ${max.toFixed(2)} mcg/min`;
}

function clearAll() {
  document.querySelectorAll("span").forEach(s => s.innerText = "--");
}

function setWeight(w) {
  document.getElementById("weight").value = w;
  calc();
}

</script>

</body>
</html>