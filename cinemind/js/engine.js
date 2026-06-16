/* ============================================================
   CineMind — Engine
   App state, the "AI" matching/scoring model, and persistence.
   The recommendation engine is a transparent heuristic that scores
   each movie against the survey profile — no backend required.
   ============================================================ */

const STORE_KEY = "cinemind_state_v1";

const State = {
  answers: {},        // questionId -> value | [values]
  profile: null,      // { archetype, summary, tags, score }
  scores: {},         // movieId -> match percentage
  watchlist: [],      // [movieId]
  route: "hero",
  watchlistView: "grid",
  watchlistSort: "all",
  watchlistMood: "all"
};

// ---- Persistence -----------------------------------------------------
function saveState() {
  try {
    localStorage.setItem(STORE_KEY, JSON.stringify({
      answers: State.answers,
      profile: State.profile,
      scores: State.scores,
      watchlist: State.watchlist
    }));
  } catch (e) { /* storage may be unavailable; app still works in-session */ }
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (!raw) return false;
    const data = JSON.parse(raw);
    Object.assign(State, {
      answers: data.answers || {},
      profile: data.profile || null,
      scores: data.scores || {},
      watchlist: Array.isArray(data.watchlist) ? data.watchlist : []
    });
    return !!State.profile;
  } catch (e) { return false; }
}

function resetState() {
  State.answers = {};
  State.profile = null;
  State.scores = {};
  // keep watchlist intentionally
  saveState();
}

// ---- Lookups ---------------------------------------------------------
const movieById = (id) => MOVIES.find((m) => m.id === id);

// ---- The "AI" model --------------------------------------------------
// Scores a single movie 0–100 against the user's answers. Weighted so
// genres and mood carry the most signal, then story/character/pace.
function scoreMovie(movie, answers) {
  let score = 50; // baseline affinity

  const genres = answers.genres || [];
  const genreHits = movie.genres.filter((g) => genres.includes(g)).length;
  score += genreHits * 11;

  if (answers.mood && movie.moods.includes(answers.mood)) score += 14;
  if (answers.story && movie.tone.includes(answers.story)) score += 16;

  // Character archetype nudges toward thematically aligned tones.
  const charMap = {
    "The Thinker": ["Mind-bending"],
    "The Dreamer": ["Emotional", "Inspirational"],
    "The Explorer": ["Action-packed", "Inspirational"],
    "The Rebel": ["Dark", "Mind-bending"],
    "The Leader": ["Inspirational", "Action-packed"],
    "The Outsider": ["Emotional", "Real-life stories"]
  };
  const charTones = charMap[answers.character] || [];
  if (charTones.some((t) => movie.tone.includes(t))) score += 8;

  // Pace tilts on runtime as a light proxy.
  if (answers.pace === "Fast and intense" && movie.runtime <= 120) score += 5;
  if (answers.pace === "Slow and deep" && movie.runtime >= 130) score += 5;

  // Reward acclaim slightly so great films surface.
  score += (movie.rating - 7.5) * 4;

  // Deterministic jitter from id so ties feel organic, never random per render.
  let h = 0;
  for (let i = 0; i < movie.id.length; i++) h = (h * 31 + movie.id.charCodeAt(i)) % 13;
  score += h - 6;

  return Math.max(72, Math.min(99, Math.round(score)));
}

// Determines the archetype. Prefers the chosen character; otherwise infers.
function deriveArchetype(answers) {
  if (answers.character && ARCHETYPES[answers.character]) return answers.character;
  const storyToChar = {
    "Mind-bending": "The Thinker",
    "Emotional": "The Dreamer",
    "Inspirational": "The Leader",
    "Action-packed": "The Explorer",
    "Dark": "The Rebel",
    "Real-life stories": "The Outsider"
  };
  return storyToChar[answers.story] || "The Thinker";
}

// Runs the full analysis: builds the profile and scores every movie.
function runAnalysis() {
  const answers = State.answers;
  const archetype = deriveArchetype(answers);
  const base = ARCHETYPES[archetype];

  const scores = {};
  MOVIES.forEach((m) => { scores[m.id] = scoreMovie(m, answers); });
  State.scores = scores;

  // Top match score becomes the headline number.
  const top = Math.max(...Object.values(scores));

  // Mood/genre flavored tag set (dedup, max 4).
  const extra = [];
  if (answers.mood === "Curious") extra.push("Inquisitive");
  if (answers.story === "Mind-bending") extra.push("Cerebral");
  if ((answers.genres || []).includes("Documentary")) extra.push("Grounded");
  if (answers.pace === "Fast and intense") extra.push("Energetic");
  const tags = Array.from(new Set([...base.tags, ...extra])).slice(0, 5);

  State.profile = {
    archetype,
    summary: base.summary,
    tags,
    score: top
  };
  saveState();
  return State.profile;
}

// Returns the scored movie list for a category, sorted by match desc.
function moviesFor(categoryKey, limit) {
  const list = MOVIES
    .filter((m) => m.categories.includes(categoryKey))
    .map((m) => ({ movie: m, match: State.scores[m.id] || scoreMovie(m, State.answers) }))
    .sort((a, b) => b.match - a.match);
  return limit ? list.slice(0, limit) : list;
}

// Best single recommendation, optionally excluding ids (for Surprise Me).
function topPick(exclude = []) {
  const ranked = MOVIES
    .filter((m) => !exclude.includes(m.id))
    .map((m) => ({ movie: m, match: State.scores[m.id] || scoreMovie(m, State.answers) }))
    .sort((a, b) => b.match - a.match);
  return ranked[0];
}

// ---- Watchlist -------------------------------------------------------
function inWatchlist(id) { return State.watchlist.includes(id); }

function toggleWatchlist(id) {
  const idx = State.watchlist.indexOf(id);
  let added;
  if (idx === -1) { State.watchlist.push(id); added = true; }
  else { State.watchlist.splice(idx, 1); added = false; }
  saveState();
  updateWatchlistBadge();
  checkBadgeUnlocks();
  return added;
}

function updateWatchlistBadge() {
  const el = document.getElementById("watchlistCount");
  if (!el) return;
  const n = State.watchlist.length;
  el.textContent = n;
  el.hidden = n === 0;
}

// ---- Badges ----------------------------------------------------------
function badgeProgress(badge) {
  const wl = State.watchlist.map(movieById).filter(Boolean);
  let count;
  if (badge.any) count = wl.length;
  else if (badge.genre) count = wl.filter((m) => m.genres.includes(badge.genre)).length;
  else if (badge.category) count = wl.filter((m) => m.categories.includes(badge.category)).length;
  else count = 0;
  return { count: Math.min(count, badge.goal), goal: badge.goal, unlocked: count >= badge.goal };
}

let _knownUnlocked = new Set();
function checkBadgeUnlocks() {
  BADGES.forEach((b) => {
    const p = badgeProgress(b);
    if (p.unlocked && !_knownUnlocked.has(b.id)) {
      _knownUnlocked.add(b.id);
      if (_badgeInitDone) toast(`Badge unlocked: ${b.name}`, b.emoji);
    }
  });
}
let _badgeInitDone = false;
function initBadgeBaseline() {
  BADGES.forEach((b) => { if (badgeProgress(b).unlocked) _knownUnlocked.add(b.id); });
  _badgeInitDone = true;
}
