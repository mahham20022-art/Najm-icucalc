/* ============================================================
   CineMind — App controller
   Router, event delegation, transitions, and feature behaviors.
   ============================================================ */

const appEl = document.getElementById("app");
const tabbar = document.getElementById("tabbar");
const modalRoot = document.getElementById("modal-root");

let wizardStep = 0;

// ---- Particles -------------------------------------------------------
function spawnParticles() {
  const host = document.getElementById("particles");
  if (!host) return;
  host.innerHTML = "";
  const n = window.innerWidth < 760 ? 18 : 32;
  for (let i = 0; i < n; i++) {
    const p = document.createElement("span");
    p.className = "particle";
    p.style.left = Math.random() * 100 + "%";
    const dur = 9 + Math.random() * 12;
    p.style.animationDuration = dur + "s";
    p.style.animationDelay = -Math.random() * dur + "s";
    const s = 1 + Math.random() * 2.5;
    p.style.width = p.style.height = s + "px";
    p.style.opacity = 0.3 + Math.random() * 0.5;
    host.appendChild(p);
  }
}

// ---- Toasts ----------------------------------------------------------
function toast(msg, icon = "✨") {
  const root = document.getElementById("toast-root");
  const el = document.createElement("div");
  el.className = "toast";
  el.innerHTML = `<span class="ico">${icon}</span> ${msg}`;
  root.appendChild(el);
  setTimeout(() => {
    el.classList.add("out");
    el.addEventListener("animationend", () => el.remove(), { once: true });
  }, 2600);
}

// ---- Router ----------------------------------------------------------
const ROUTES_WITH_TABBAR = ["results", "watchlist", "features", "badges"];

function navigate(route, opts = {}) {
  State.route = route;
  render();
  if (!opts.noScroll) window.scrollTo({ top: 0, behavior: "instant" in window ? "instant" : "auto" });
}

function render() {
  let html = "";
  switch (State.route) {
    case "hero":      html = HeroScreen(); break;
    case "wizard":    html = WizardScreen(wizardStep); break;
    case "analysis":  html = AnalysisScreen(); break;
    case "results":   html = ResultsScreen(); break;
    case "watchlist": html = WatchlistScreen(); break;
    case "features":  html = FeaturesScreen(); break;
    case "badges":    html = BadgesScreen(); break;
    default:          html = HeroScreen();
  }
  appEl.innerHTML = html;

  // Tab bar visibility + active state.
  const showTab = ROUTES_WITH_TABBAR.includes(State.route);
  tabbar.hidden = !showTab;
  appEl.classList.toggle("has-tabbar", showTab);
  if (showTab) {
    tabbar.querySelectorAll(".tabbar__btn").forEach((b) => {
      b.classList.toggle("active", b.dataset.route === State.route);
    });
  }

  // Screen-specific kickoff.
  if (State.route === "analysis") startAnalysis();
  if (State.route === "results" && TMDB.enabled()) populateResults();
}

// ---- Live results population (TMDB) ----------------------------------
let _resultsToken = 0;
async function populateResults() {
  const token = ++_resultsToken;
  const host = document.getElementById("rowsHost");
  if (!host) return;
  try {
    const rows = await tmdbBuildRows(State.answers, State.profile);
    if (token !== _resultsToken) return;          // a newer render superseded us
    if (State.route !== "results") return;
    const liveHost = document.getElementById("rowsHost");
    if (liveHost) liveHost.innerHTML = renderRows(rows);
  } catch (err) {
    if (token !== _resultsToken) return;
    const liveHost = document.getElementById("rowsHost");
    if (liveHost) liveHost.innerHTML = renderRows(buildRecommendationRows());
    const msg = /key/i.test(err.message) ? "Couldn't reach TMDB — check your API key" : "Live library unavailable — showing demo picks";
    toast(msg, "⚠️");
  }
}

// ---- Wizard logic ----------------------------------------------------
function selectOption(value) {
  const q = QUESTIONS[wizardStep];
  if (q.type === "multi") {
    const arr = State.answers[q.id] ? [...State.answers[q.id]] : [];
    const i = arr.indexOf(value);
    if (i === -1) arr.push(value); else arr.splice(i, 1);
    State.answers[q.id] = arr;
    render();
  } else {
    State.answers[q.id] = value;
    // Auto-advance single-choice for a snappy feel.
    render();
    setTimeout(() => wizardNext(), 280);
  }
}

function wizardNext() {
  const q = QUESTIONS[wizardStep];
  const ans = State.answers[q.id];
  const ok = q.type === "multi" ? (ans && ans.length) : !!ans;
  if (!ok) return;

  if (wizardStep < QUESTIONS.length - 1) {
    const card = document.getElementById("qcard");
    if (card) card.classList.add("leaving");
    setTimeout(() => { wizardStep++; render(); }, 240);
  } else {
    navigate("analysis");
  }
}

function wizardBack() {
  if (wizardStep === 0) { navigate("hero"); return; }
  wizardStep--;
  render();
}

// ---- Analysis sequence -----------------------------------------------
let analysisRunning = false;
function startAnalysis() {
  if (analysisRunning) return;
  analysisRunning = true;

  const steps = [
    "Mapping your mood signature…",
    "Decoding narrative preferences…",
    "Cross-referencing 24 cinematic profiles…",
    "Calibrating emotional resonance…",
    "Finalizing your Entertainment DNA…"
  ];
  const statusEl = () => document.getElementById("analysisStatus");
  const barEl = () => document.getElementById("analysisBar");

  // Run the actual scoring up front so results are ready.
  runAnalysis();

  let i = 0;
  const total = steps.length;
  const tick = () => {
    const s = statusEl(), b = barEl();
    if (!s || !b) { analysisRunning = false; return; } // user navigated away
    s.style.opacity = "0";
    setTimeout(() => {
      s.textContent = steps[i];
      s.style.opacity = "1";
      b.style.width = Math.round(((i + 1) / total) * 100) + "%";
      i++;
      if (i < total) {
        setTimeout(tick, 620);
      } else {
        setTimeout(() => { analysisRunning = false; navigate("results"); }, 700);
      }
    }, 180);
  };
  tick();
}

// ---- Modal -----------------------------------------------------------
let _modalToken = 0;
function openMovie(id) {
  const movie = movieById(id);
  if (!movie) return;
  const token = ++_modalToken;

  // For TMDB titles we have list-level data instantly; fetch full details
  // (cast, runtime, trailer, streaming) and refresh the modal when ready.
  const needsDetails = movie.tmdb && !movie._full;
  modalRoot.innerHTML = MovieModal(movie, { loading: needsDetails });
  document.body.style.overflow = "hidden";

  if (needsDetails) {
    TMDB.details(movie.tmdbId).then((full) => {
      full._full = true;
      full.why = movie.why || tmdbWhy(full, State.answers);
      Object.assign(movie, full);  // keep cache/watchlist object enriched
      cacheMovie(movie);
      if (token === _modalToken && modalRoot.querySelector(".overlay")) {
        modalRoot.innerHTML = MovieModal(movie);
      }
    }).catch(() => { /* keep the basic modal; it's still usable */ });
  }
}

function closeModal() {
  const overlay = modalRoot.querySelector(".overlay");
  if (!overlay) return;
  overlay.style.animation = "fadeIn .25s var(--ease) reverse forwards";
  setTimeout(() => { modalRoot.innerHTML = ""; document.body.style.overflow = ""; }, 220);
}

// ---- Surprise Me -----------------------------------------------------
function surpriseMe() {
  if (!State.profile) { startFlow(); return; }
  const pick = topPickRandomized();
  if (!pick) return;
  const m = pick.movie;
  const art = m.poster
    ? `<img src="${esc(m.poster)}" alt="${esc(m.title)}" onerror="this.remove()" style="width:100%;height:100%;object-fit:cover;border-radius:inherit;position:absolute;inset:0"/>`
    : esc(m.title);
  const stage = document.createElement("div");
  stage.className = "reveal-stage";
  stage.innerHTML = `<div class="reveal-card">
    <div class="label">Your surprise pick · ${pick.match}% match</div>
    <button class="spotlight" data-movie="${esc(m.id)}" style="background:${gradFor(m.grad)}">${art}</button>
    <h2>${esc(m.title)}</h2>
    <p>${esc(m.why || "")}</p>
    <button class="btn btn--primary" data-movie="${esc(m.id)}">View Details</button>
    <div style="margin-top:12px"><button class="btn btn--ghost" data-action="surprise-again">Try again</button></div>
  </div>`;
  stage.addEventListener("click", (e) => {
    if (e.target === stage) stage.remove();
  });
  document.body.appendChild(stage);
  // Delegate clicks inside the stage.
  stage.addEventListener("click", (e) => {
    const mv = e.target.closest("[data-movie]");
    const again = e.target.closest('[data-action="surprise-again"]');
    if (again) { stage.remove(); surpriseMe(); return; }
    if (mv) { stage.remove(); openMovie(mv.dataset.movie); }
  });
}

// The candidate pool for AI tools: live TMDB titles fetched this session when
// connected, otherwise the bundled catalogue.
function recommendationPool() {
  if (TMDB.enabled()) {
    const cached = Object.values(State.cache).filter((m) => m.tmdb && m.poster);
    if (cached.length >= 5) return cached;
  }
  return MOVIES;
}

// Picks among the top handful so "again" feels fresh.
let _lastSurprise = [];
function topPickRandomized() {
  const pool = recommendationPool();
  const scored = pool.map((m) => ({ movie: m, match: matchFor(m) })).sort((a, b) => b.match - a.match);
  const fresh = scored.slice(0, 12).filter((e) => !_lastSurprise.includes(e.movie.id));
  const list = fresh.length ? fresh : scored;
  const pick = list[Math.floor(Math.random() * Math.min(list.length, 6))];
  _lastSurprise.push(pick.movie.id);
  if (_lastSurprise.length > 6) _lastSurprise.shift();
  return pick;
}

// ---- Movie Therapist -------------------------------------------------
function runTherapist(text) {
  const res = document.getElementById("therapistResponse");
  if (!res) return;
  const feeling = (text || "").toLowerCase();

  // Map feelings to tones/moods, then pick the best-scoring match.
  let wantTone = null, wantMood = null, intro = "Here's something to sink into";
  if (/burn|tired|exhaust|stress|overwhelm/.test(feeling)) { wantMood = "Stressed"; wantTone = "Inspirational"; intro = "You need a reset — try"; }
  else if (/heart|sad|cry|breakup|broke|lonel/.test(feeling)) { wantMood = "Lonely"; wantTone = "Emotional"; intro = "Be gentle with yourself and watch"; }
  else if (/motivat|inspir|focus|drive|goal/.test(feeling)) { wantMood = "Motivated"; wantTone = "Inspirational"; intro = "Channel that energy with"; }
  else if (/happy|good|great|excited/.test(feeling)) { wantMood = "Happy"; wantTone = null; intro = "Keep the good vibes going with"; }
  else if (/think|curious|bored|stuck/.test(feeling)) { wantMood = "Curious"; wantTone = "Mind-bending"; intro = "Feed your mind with"; }

  const moodGenres = (TMDB.MOOD_GENRES[wantMood] || []).map((id) => TMDB.ID_GENRE[id]);
  const storyGenres = (TMDB.STORY_GENRES[wantTone] || []).map((id) => TMDB.ID_GENRE[id]);
  const ranked = recommendationPool().map((m) => {
    let s = matchFor(m);
    if (wantMood && (m.moods || []).includes(wantMood)) s += 20;
    if (wantTone && (m.tone || []).includes(wantTone)) s += 15;
    if (moodGenres.some((g) => (m.genres || []).includes(g))) s += 16;
    if (storyGenres.some((g) => (m.genres || []).includes(g))) s += 12;
    return { m, s };
  }).sort((a, b) => b.s - a.s);

  const movie = ranked[0].m;
  const art = movie.poster
    ? `<img src="${esc(movie.poster)}" alt="${esc(movie.title)}" onerror="this.remove()" style="width:100%;height:100%;object-fit:cover;border-radius:inherit"/>`
    : esc(movie.title);
  res.innerHTML = `
    <div class="mini-poster" data-movie="${esc(movie.id)}" style="background:${gradFor(movie.grad)}">${art}</div>
    <div class="r-text"><b>${esc(intro)} "${esc(movie.title)}."</b><br>${esc(movie.why || tmdbWhy(movie, State.answers))}</div>`;
  res.classList.add("show");
}

// ---- Family / Couple (lightweight demos) -----------------------------
function showFamilyPicks() {
  // Family-friendly = no dark/horror/thriller, prefer highly rated.
  const pool = recommendationPool();
  const safe = pool.filter((m) =>
    !(m.tone || []).includes("Dark") &&
    !(m.genres || []).includes("Horror") &&
    !(m.genres || []).includes("Thriller"));
  const pick = (safe.length ? safe : pool).slice().sort((a, b) => b.rating - a.rating)[0];
  if (!pick) return;
  toast(`Family pick: "${pick.title}" — wholesome & crowd-pleasing`, "👨‍👩‍👧");
  openMovie(pick.id);
}

// ---- Flow helpers ----------------------------------------------------
function startFlow() {
  if (State.profile) { navigate("results"); return; }
  wizardStep = 0;
  navigate("wizard");
}

function retake() {
  resetState();
  wizardStep = 0;
  navigate("wizard");
}

// ---- Global event delegation -----------------------------------------
document.addEventListener("click", (e) => {
  const t = e.target;

  // Tab bar / route buttons
  const routeBtn = t.closest("[data-route]");
  if (routeBtn) { navigate(routeBtn.dataset.route); return; }

  const actionEl = t.closest("[data-action]");
  const action = actionEl && actionEl.dataset.action;

  // Movie poster / details (but not when clicking the remove button)
  const movieEl = t.closest("[data-movie]");
  if (movieEl && !t.closest("[data-remove]") && !action && !t.closest("[data-overlay] [data-action]")) {
    // toggle-watchlist inside modal carries data-movie + data-action; handled below
    if (!actionEl) { openMovie(movieEl.dataset.movie); return; }
  }

  // Remove from watchlist
  const removeBtn = t.closest("[data-remove]");
  if (removeBtn) {
    e.stopPropagation();
    const id = removeBtn.dataset.remove;
    toggleWatchlist(id);
    toast("Removed from watchlist", "🗑️");
    render();
    return;
  }

  // Wizard option
  const opt = t.closest("[data-opt]");
  if (opt) { selectOption(opt.dataset.opt); return; }

  // Watchlist view toggle
  const viewBtn = t.closest("[data-view]");
  if (viewBtn) { State.watchlistView = viewBtn.dataset.view; render(); return; }

  // Mood chip
  const moodBtn = t.closest("[data-mood]");
  if (moodBtn) { State.watchlistMood = moodBtn.dataset.mood; render(); return; }

  // Therapist quick feelings
  const feel = t.closest("[data-feeling]");
  if (feel) {
    const input = document.getElementById("therapistInput");
    if (input) input.value = feel.dataset.feeling;
    runTherapist(feel.dataset.feeling);
    return;
  }

  // Modal close
  if (t.closest("[data-close]")) { closeModal(); return; }
  if (t.matches("[data-overlay]")) { closeModal(); return; }

  if (!action) return;

  switch (action) {
    case "start": startFlow(); break;
    case "retake": retake(); break;
    case "wizard-next": wizardNext(); break;
    case "wizard-back": wizardBack(); break;
    case "surprise": surpriseMe(); break;
    case "toggle-watchlist": {
      const id = actionEl.dataset.movie;
      const added = toggleWatchlist(id);
      actionEl.innerHTML = added ? watchlistRemoveLabel() : watchlistAddLabel();
      toast(added ? "Added to watchlist" : "Removed from watchlist", added ? "✅" : "🗑️");
      break;
    }
    case "trailer": toast("Trailer playback is a demo placeholder", "🎬"); break;
    case "therapist": {
      const input = document.getElementById("therapistInput");
      runTherapist(input ? input.value : "");
      break;
    }
    case "couple": toast("Couple Mode: invite a partner to blend tastes (demo)", "💑"); break;
    case "family": showFamilyPicks(); break;
    case "sort": break;
    case "clear-filters":
      State.watchlistSort = "all"; State.watchlistMood = "all"; render(); break;
    case "open-settings": openSettings(); break;
    case "save-key": saveKey(); break;
    case "disconnect-key": disconnectKey(); break;
    default: break;
  }
});

// ---- Settings / TMDB key ---------------------------------------------
function openSettings() {
  modalRoot.innerHTML = SettingsModal();
  document.body.style.overflow = "hidden";
  const input = document.getElementById("tmdbKeyInput");
  if (input) setTimeout(() => input.focus(), 60);
}

async function saveKey() {
  const input = document.getElementById("tmdbKeyInput");
  const status = document.getElementById("keyStatus");
  if (!input) return;
  const key = input.value.trim();
  if (!key) { if (status) status.innerHTML = '<span class="err">Please paste your API key.</span>'; return; }
  if (status) status.innerHTML = '<span class="muted">Verifying key…</span>';
  try {
    await TMDB.validate(key);
    State.cache = {};               // drop any stale demo/previous-session cache
    if (status) status.innerHTML = '<span class="ok">✓ Connected! Loading the full library…</span>';
    toast("Connected to the full movie library", "🎬");
    setTimeout(() => { closeModal(); navigate("results"); }, 700);
  } catch (err) {
    if (status) status.innerHTML = `<span class="err">${esc(err.message || "Could not verify key")}. Double-check it and try again.</span>`;
  }
}

function disconnectKey() {
  TMDB.clearKey();
  State.cache = {};
  toast("Switched back to the demo library", "📦");
  closeModal();
  if (State.profile) navigate("results"); else navigate("hero");
}

// Select dropdown change (sort)
document.addEventListener("change", (e) => {
  const sel = e.target.closest('[data-action="sort"]');
  if (sel) { State.watchlistSort = sel.value; render(); }
});

// Enter key in therapist input / settings key field
document.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && e.target.id === "therapistInput") {
    runTherapist(e.target.value);
  }
  if (e.key === "Enter" && e.target.id === "tmdbKeyInput") {
    e.preventDefault(); saveKey();
  }
  if (e.key === "Escape") closeModal();
});

// ---- Boot ------------------------------------------------------------
function boot() {
  loadState();
  initBadgeBaseline();
  updateWatchlistBadge();
  spawnParticles();
  // Always land on the hero; returning users get a "continue" CTA.
  navigate("hero");
}

window.addEventListener("resize", () => {
  // keep particle field proportional on big viewport changes
  clearTimeout(window.__pt);
  window.__pt = setTimeout(spawnParticles, 400);
});

boot();
