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
const ROUTES_WITH_TABBAR = ["home", "search", "watchlist", "profile"];

function navigate(route, opts = {}) {
  State.route = route;
  render();
  if (!opts.noScroll) window.scrollTo({ top: 0, behavior: "instant" in window ? "instant" : "auto" });
}

function render() {
  let html = "";
  switch (State.route) {
    case "hero":       html = HeroScreen(); break;
    case "onboarding": html = OnboardingScreen(State.onboardPool, State.onboardPicked); break;
    case "home":       html = HomeScreen(); break;
    case "search":     html = SearchScreen(); break;
    case "watchlist":  html = WatchlistScreen(); break;
    case "profile":    html = ProfileScreen(); break;
    default:           html = HeroScreen();
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
  if (State.route === "home") fillDeck();
  if (State.route === "search") restoreSearch();
}

// ---- Discovery deck (Home) -------------------------------------------
// A queue of scored, unseen movies for the Save/Skip card. Refills from the
// active mood (or overall taste) via TMDB, falling back to the local library.
let _deck = [];
let _deckToken = 0;
let _deckPage = 1;

function renderDeck() {
  const host = document.getElementById("deckHost");
  if (!host) return;
  host.innerHTML = _deck.length ? deckCard(_deck[0]) : deckCard(null);
  const label = document.getElementById("deckLabel");
  if (label) label.textContent = State.mood || "Tonight's pick for you";
}

// Fetches one page of candidates for the active mood (or taste default).
async function fetchDeckPage() {
  try {
    if (!TMDB.enabled()) return MOVIES.slice();
    const chip = MOOD_CHIPS.find((c) => c.label === State.mood);
    const params = { page: chip && chip.random ? 1 + Math.floor(Math.random() * 40) : _deckPage };
    if (chip) {
      params.sort_by = chip.sort || "popularity.desc";
      params["vote_count.gte"] = chip.minVotes || 300;
      if (chip.g && chip.g.length) params.with_genres = chip.g.join("|");
      if (chip.not) params.without_genres = chip.not.join(",");
    } else {
      const gids = Taste.topGenres(3).map((g) => TMDB.GENRE_ID[g]).filter(Boolean);
      params.with_genres = gids.length ? gids.join("|") : "18|878|53|12|35|10749";
      params.sort_by = "vote_average.desc";
      params["vote_count.gte"] = 500;
    }
    return await TMDB.discover(params);
  } catch (e) { return MOVIES.slice(); }
}

// Endless deck: keeps paging TMDB until it has a healthy buffer of unseen
// cards, so you never run out (the old version refetched page 1 and dried up).
async function fillDeck(reset) {
  const host = document.getElementById("deckHost");
  if (!host) return;
  if (reset) { _deck = []; _deckPage = 1; host.innerHTML = deckSkeleton(); }
  else if (_deck.length > 2) { renderDeck(); return; }

  const token = ++_deckToken;
  let tries = 0;
  while (_deck.length < 6 && tries < 4) {
    const pool = await fetchDeckPage();
    if (token !== _deckToken) return;
    const seen = new Set(Taste.d.seen);
    const have = new Set(_deck.map((e) => e.movie.id));
    const add = pool
      .filter((m) => (m.poster || !m.tmdb) && !seen.has(m.id) && !have.has(m.id))
      .map((m) => { cacheMovie(m); m.why = m.why || tmdbWhy(m, State.answers); return { movie: m, match: matchFor(m) }; })
      .sort((a, b) => b.match - a.match);
    _deck = _deck.concat(add);
    _deckPage += 1;
    tries += 1;
    if (!TMDB.enabled()) break;   // demo library is a single pool
  }
  if (token !== _deckToken) return;
  renderDeck();
}

function advanceDeck() {
  _deck.shift();
  renderDeck();
  if (_deck.length <= 2) fillDeck(false); // prefetch the next batch
}

function deckSave() {
  if (!_deck.length) return;
  const m = _deck[0].movie;
  Taste.like(m);
  if (!inWatchlist(m.id)) toggleWatchlist(m.id);
  buildProfileFromTaste();
  toast(`Saved “${m.title}” — taste updated`, "❤️");
  advanceDeck();
}

function deckSkip() {
  if (!_deck.length) return;
  Taste.skip(_deck[0].movie);
  advanceDeck();
}

// ---- Smart natural-language search -----------------------------------
let _lastSearch = null;
function restoreSearch() {
  if (_lastSearch) {
    const host = document.getElementById("searchHost");
    const input = document.getElementById("aiSearch");
    if (input) input.value = _lastSearch.query;
    if (host) host.innerHTML = _lastSearch.html;
  }
}

async function runSearch(query) {
  query = (query || "").trim();
  if (!query) return;
  if (State.route !== "search") { navigate("search"); }
  const input = document.getElementById("aiSearch");
  if (input) input.value = query;
  const host = document.getElementById("searchHost");
  if (host) host.innerHTML = `<div class="row"><div class="carousel">${skeletonRows(1)}</div></div>`;

  const intent = parseQuery(query);
  const token = ++_deckToken;
  let results = [];
  try {
    if (TMDB.enabled()) {
      if (intent.likeTitle) {
        const found = await TMDB.search(intent.likeTitle);
        if (found[0]) {
          results = await TMDB.recommendations(found[0].tmdbId);
          // apply exclusions/runtime from the modifiers
          if (intent.exclude.length) {
            const exNames = intent.exclude.map((id) => TMDB.ID_GENRE[id]);
            results = results.filter((m) => !m.genres.some((g) => exNames.includes(g)));
          }
        }
      }
      if (!results.length) results = await TMDB.discoverByIntent(intent);
    } else {
      results = localSearch(query, intent);
    }
  } catch (e) {
    results = localSearch(query, intent);
  }
  if (token !== _deckToken) return;

  results = results.filter((m) => m.poster || !m.tmdb).slice(0, 18)
    .map((m) => { cacheMovie(m); m.why = m.why || tmdbWhy(m, State.answers); return { movie: m, match: matchFor(m) }; })
    .sort((a, b) => b.match - a.match);

  const note = intent.note.length ? `<div class="search-note">Understood: ${esc(intent.note.join(" · "))}</div>` : "";
  const rowsHtml = results.length
    ? note + `<div class="row"><div class="row__head"><h3 class="row__title">Results<em>${results.length} matches</em></h3></div><div class="carousel">${results.map((e) => posterCard(e)).join("")}</div></div>`
    : `<div class="empty" style="margin-top:24px"><div class="empty__art">🔍</div><h3>No matches</h3><p>Try describing it differently.</p></div>`;

  const liveHost = document.getElementById("searchHost");
  if (liveHost) liveHost.innerHTML = rowsHtml;
  _lastSearch = { query, html: rowsHtml };
}

// Local (no-key) natural-language search over the bundled catalogue.
function localSearch(query, intent) {
  const q = query.toLowerCase();
  const incNames = intent.include.map((id) => TMDB.ID_GENRE[id]).filter(Boolean);
  const exNames = intent.exclude.map((id) => TMDB.ID_GENRE[id]).filter(Boolean);
  return MOVIES.filter((m) => {
    if (exNames.some((g) => m.genres.includes(g))) return false;
    if (intent.maxRuntime && m.runtime > intent.maxRuntime) return false;
    if (incNames.length && !incNames.some((g) => m.genres.includes(g))) {
      // also allow title/keyword text match
      if (!(m.title.toLowerCase().includes(q) || (m.tone || []).some((t) => q.includes(t.toLowerCase())))) return false;
    }
    return true;
  });
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
  if (!Taste.d.onboarded) { startFlow(); return; }
  const pick = topPickRandomized();
  if (!pick) return;
  Taste.markSeen(pick.movie.id); Taste.save();
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
  // Never repeat: skip anything already seen (Save/Skip/Surprise) this profile.
  const unseen = scored.filter((e) => !Taste.hasSeen(e.movie.id) && !_lastSurprise.includes(e.movie.id));
  const fresh = (unseen.length ? unseen : scored.filter((e) => !_lastSurprise.includes(e.movie.id)));
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

// ---- Onboarding ------------------------------------------------------
let _onboardPage = 1;
async function startFlow() {
  State.onboardPicked = [];
  State.onboardPool = [];
  _onboardPage = 1;
  navigate("onboarding");
  await loadOnboardingPool(true);
}

async function loadOnboardingPool(reset) {
  const grid = document.getElementById("obGrid");
  try {
    let batch;
    if (TMDB.enabled()) batch = await TMDB.popular(_onboardPage);
    else batch = MOVIES.slice();
    batch = batch.filter((m) => m.poster || !m.tmdb);
    batch.forEach(cacheMovie);
    const existing = new Set(State.onboardPool.map((m) => m.id));
    State.onboardPool = reset ? batch : State.onboardPool.concat(batch.filter((m) => !existing.has(m.id)));
  } catch (e) {
    if (!State.onboardPool.length) State.onboardPool = MOVIES.slice();
  }
  if (State.route === "onboarding") render();
}

function toggleOnboardPick(id) {
  const i = State.onboardPicked.indexOf(id);
  if (i === -1) State.onboardPicked.push(id); else State.onboardPicked.splice(i, 1);
  render();
}

function finishOnboarding() {
  State.onboardPicked.forEach((id) => { const m = movieById(id); if (m) Taste.like(m); });
  Taste.d.onboarded = true; Taste.save();
  buildProfileFromTaste();
  navigate("home");
  toast("Taste profile created — welcome to CineMind", "✨");
}

function retake() { startFlow(); }

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

  // Watchlist mood filter chip
  const moodBtn = t.closest("[data-mood]");
  if (moodBtn) { State.watchlistMood = moodBtn.dataset.mood; render(); return; }

  // Home mood chip -> set mood + refill deck
  const moodChip = t.closest("[data-moodchip]");
  if (moodChip) {
    const label = moodChip.dataset.moodchip;
    State.mood = (State.mood === label) ? null : label;
    Taste.addMood(State.mood || label);
    document.querySelectorAll("[data-moodchip]").forEach((el) =>
      el.classList.toggle("active", el.dataset.moodchip === State.mood));
    fillDeck(true);
    return;
  }

  // Onboarding poster pick
  const obBtn = t.closest("[data-onboard]");
  if (obBtn) { toggleOnboardPick(obBtn.dataset.onboard); return; }

  // Search suggestion chip
  const sug = t.closest("[data-suggest]");
  if (sug) { runSearch(sug.dataset.suggest); return; }

  // Star rating
  const star = t.closest("[data-rate]");
  if (star) {
    const m = movieById(star.dataset.movie);
    if (m) { Taste.rate(m, parseInt(star.dataset.rate, 10)); buildProfileFromTaste();
      const wrap = star.closest(".stars");
      if (wrap) wrap.querySelectorAll(".star").forEach((s, i) => s.classList.toggle("on", i < parseInt(star.dataset.rate, 10)));
      toast("Thanks — tuning your recommendations", "⭐");
    }
    return;
  }

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
    case "go-home": navigate("home"); break;
    case "retake": retake(); break;
    case "onboard-more": _onboardPage += 1; loadOnboardingPool(false); break;
    case "onboard-done": finishOnboarding(); break;
    case "deck-save": deckSave(); break;
    case "deck-skip": deckSkip(); break;
    case "reset-taste":
      Taste.reset(); State.profile = null; State.cache = {}; _deck = [];
      toast("Taste profile reset", "♻️"); navigate("hero"); break;
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
    State.cache = {}; _deck = [];   // drop any stale demo/previous-session cache
    if (status) status.innerHTML = '<span class="ok">✓ Connected! Loading the full library…</span>';
    toast("Connected to the full movie library", "🎬");
    setTimeout(() => { closeModal(); navigate(Taste.d.onboarded ? "home" : "hero"); }, 700);
  } catch (err) {
    if (status) status.innerHTML = `<span class="err">${esc(err.message || "Could not verify key")}. Double-check it and try again.</span>`;
  }
}

function disconnectKey() {
  TMDB.clearKey();
  State.cache = {}; _deck = [];
  toast("Switched back to the demo library", "📦");
  closeModal();
  navigate(Taste.d.onboarded ? "home" : "hero");
}

// Select dropdown change (sort)
document.addEventListener("change", (e) => {
  const sel = e.target.closest('[data-action="sort"]');
  if (sel) { State.watchlistSort = sel.value; render(); }
});

// AI search form submit (Home + Search)
document.addEventListener("submit", (e) => {
  if (e.target.closest('[data-action="ai-search-form"]')) {
    e.preventDefault();
    const input = document.getElementById("aiSearch");
    if (input && input.value.trim()) runSearch(input.value);
  }
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
  Taste.load();
  loadState();
  initBadgeBaseline();
  updateWatchlistBadge();
  spawnParticles();
  // Returning (onboarded) users go straight to Home; newcomers see the hero.
  if (Taste.d.onboarded) { if (!State.profile) buildProfileFromTaste(); navigate("home"); }
  else navigate("hero");
}

window.addEventListener("resize", () => {
  // keep particle field proportional on big viewport changes
  clearTimeout(window.__pt);
  window.__pt = setTimeout(spawnParticles, 400);
});

boot();
