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
  scores: {},         // movieId -> match percentage (local catalogue)
  watchlist: [],      // [movie object] — full objects so TMDB titles persist
  cache: {},          // movieId -> movie object (session lookups for modal/surprise)
  route: "hero",
  mood: null,               // active Home mood chip
  onboardPool: [],          // onboarding candidate posters
  onboardPicked: [],        // onboarding selected ids
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
    // Migrate older saves where watchlist held ids (strings).
    const wl = (Array.isArray(data.watchlist) ? data.watchlist : [])
      .map((item) => typeof item === "string" ? movieById(item) : item)
      .filter(Boolean);
    Object.assign(State, {
      answers: data.answers || {},
      profile: data.profile || null,
      scores: data.scores || {},
      watchlist: wl
    });
    wl.forEach(cacheMovie);
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

// ---- Lookups & cache -------------------------------------------------
function cacheMovie(m) { if (m && m.id) State.cache[m.id] = m; }

// Resolves a movie id from the local catalogue, the session cache, or the
// watchlist — so both bundled and live TMDB titles are always findable.
function movieById(id) {
  return MOVIES.find((m) => m.id === id) ||
         State.cache[id] ||
         State.watchlist.find((m) => m.id === id) ||
         null;
}

// ---- The "AI" model --------------------------------------------------
// Scores a single movie 0–100 against the user's answers. Weighted so
// genres and mood carry the most signal, then story/character/pace.
function scoreMovie(movie, answers) {
  let score = 50; // baseline affinity

  const genres = answers.genres || [];
  const genreHits = movie.genres.filter((g) => genres.includes(g)).length;
  score += genreHits * 11;

  if (answers.mood && movie.moods.includes(answers.mood)) score += 16;
  if (answers.story && movie.tone.includes(answers.story)) score += 18;

  // Character archetype nudges toward thematically aligned tones.
  const charTones = ARCHETYPE_TONES[answers.character] || [];
  if (charTones.some((t) => movie.tone.includes(t))) score += 10;

  // Pace tilts on runtime as a light proxy.
  if (answers.pace === "Fast and intense" && movie.runtime <= 120) score += 6;
  if (answers.pace === "Slow and deep" && movie.runtime >= 130) score += 6;

  // Lifestyle adds a light, personality-consistent nudge.
  const lifeTone = LIFESTYLE_TONES[answers.lifestyle] || [];
  if (lifeTone.some((t) => movie.tone.includes(t))) score += 5;

  // Reward acclaim slightly so great films surface.
  score += (movie.rating - 7.5) * 4;

  // Deterministic jitter from id so ties feel organic, never random per render.
  let h = 0;
  for (let i = 0; i < movie.id.length; i++) h = (h * 31 + movie.id.charCodeAt(i)) % 13;
  score += h - 6;

  // Floor of 62 keeps weak matches presentable; strong matches separate clearly.
  return Math.max(62, Math.min(99, Math.round(score)));
}

// Archetype + lifestyle tone affinities (module-level so rows can reuse them).
const ARCHETYPE_TONES = {
  "The Thinker": ["Mind-bending"],
  "The Dreamer": ["Emotional", "Inspirational"],
  "The Explorer": ["Action-packed", "Inspirational"],
  "The Rebel": ["Dark", "Mind-bending"],
  "The Leader": ["Inspirational", "Action-packed"],
  "The Outsider": ["Emotional", "Real-life stories"]
};
const LIFESTYLE_TONES = {
  "Reading": ["Mind-bending", "Real-life stories"],
  "Gaming": ["Action-packed", "Mind-bending"],
  "Traveling": ["Inspirational", "Action-packed"],
  "Sports": ["Inspirational", "Action-packed"],
  "Family time": ["Emotional", "Inspirational"],
  "Learning": ["Mind-bending", "Real-life stories"]
};
const STORY_ROW_TITLES = {
  "Mind-bending": "Mind-Blowing Stories",
  "Emotional": "Emotional Journeys",
  "Inspirational": "Inspiring Watches",
  "Action-packed": "Edge-of-Your-Seat",
  "Dark": "Into the Dark",
  "Real-life stories": "Rooted in Reality"
};

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

// Match % for any movie — bundled or TMDB — blended with the learned taste
// profile so scores sharpen as the user Saves/Skips/rates.
function matchFor(movie) {
  let base = movie.tmdb ? tmdbMatch(movie, State.answers)
    : (State.scores[movie.id] || scoreMovie(movie, State.answers));
  if (typeof Taste !== "undefined" && Taste.d) {
    base += Math.max(-8, Math.min(13, Taste.affinity(movie) * 1.1));
  }
  return Math.max(62, Math.min(99, Math.round(base)));
}

// Derives the AI-personality profile from the learned taste (top genres),
// reusing the archetype copy. Called after onboarding / when taste changes.
function buildProfileFromTaste() {
  const genres = Taste.topGenres(3);
  const g2story = {
    "Sci-Fi": "Mind-bending", "Mystery": "Mind-bending",
    "Drama": "Emotional", "Romance": "Emotional",
    "Comedy": "Inspirational", "Family": "Inspirational",
    "Adventure": "Action-packed", "Action": "Action-packed", "Fantasy": "Action-packed",
    "Crime": "Dark", "Thriller": "Dark", "Horror": "Dark",
    "Documentary": "Real-life stories", "History": "Real-life stories"
  };
  const story = g2story[genres[0]] || "Mind-bending";
  const arch = deriveArchetype({ story });
  const base = ARCHETYPES[arch];
  const tags = base.tags.slice(0, 3).concat(genres.slice(0, 2));
  State.profile = {
    archetype: arch,
    summary: base.summary,
    tags: Array.from(new Set(tags)).slice(0, 5),
    score: Taste.tasteScore()
  };
  saveState();
  return State.profile;
}

// Full catalogue, scored against the current answers, ranked best-first.
function rankedMovies() {
  return MOVIES
    .map((m) => ({ movie: m, match: State.scores[m.id] || scoreMovie(m, State.answers) }))
    .sort((a, b) => b.match - a.match);
}

// Builds the recommendation rows DYNAMICALLY from the user's answers, so
// different personalities genuinely get different titles — not just a
// re-sort of the same static lists. Rows are tailored to the picked
// genres, mood, story preference and derived archetype.
function buildRecommendationRows() {
  const a = State.answers;
  const ranked = rankedMovies();
  const take = (arr, n = 10) => arr.slice(0, n);
  const rows = [];
  const featured = new Set();

  // Helper: builds a row from a candidate pool (already score-sorted). To stop
  // every row repeating the same headline picks, titles shown in an earlier
  // row are dropped here; if that leaves too few, we backfill with the best of
  // the rest. Each row stays cleanly sorted high→low by match score.
  const addRow = (title, hint, pool, keepAll) => {
    if (pool.length < 3) return;
    let entries;
    if (keepAll) {
      entries = pool;
    } else {
      entries = pool.filter((e) => !featured.has(e.movie.id));
      if (entries.length < 3) {
        entries = pool.slice().sort((x, y) => y.match - x.match);
      }
    }
    if (entries.length < 3) return;

    // Skip a row that's essentially a duplicate of one already shown
    // (>=80% of the visible top 5 overlapping) — keeps every row distinct.
    const topIds = entries.slice(0, 5).map((e) => e.movie.id);
    const isDup = rows.some((r) => {
      const prev = r.entries.slice(0, 5).map((e) => e.movie.id);
      const shared = topIds.filter((id) => prev.includes(id)).length;
      return shared >= Math.ceil(Math.min(topIds.length, prev.length) * 0.8);
    });
    if (isDup) return;

    entries.slice(0, 6).forEach((e) => featured.add(e.movie.id));
    rows.push({ title, hint, entries: take(entries, 10) });
  };

  // 1. Perfect Matches — the highest-scoring titles for THIS profile (kept in
  //    pure score order; this is the headline row).
  addRow("Perfect Matches", "Your highest AI match scores", ranked, true);

  // 2. Based on the user's character archetype.
  const arch = State.profile ? State.profile.archetype : deriveArchetype(a);
  const aTones = ARCHETYPE_TONES[arch] || [];
  addRow(`Because you're ${arch}`, "Tuned to your character type",
    ranked.filter((e) => e.movie.tone.some((t) => aTones.includes(t))));

  // 3. One row per favourite genre the user actually selected (max 2).
  (a.genres || [])
    .map((g) => ({ g, entries: ranked.filter((e) => e.movie.genres.includes(g)) }))
    .filter((x) => x.entries.length >= 3)
    .sort((x, y) => y.entries.length - x.entries.length)
    .slice(0, 2)
    .forEach(({ g, entries }) => addRow(`Because you love ${g}`, "From the genres you picked", entries));

  // 4. Mood-driven row for how they feel today.
  if (a.mood) {
    addRow(`For your ${a.mood.toLowerCase()} mood`, "Matched to how you feel today",
      ranked.filter((e) => e.movie.moods.includes(a.mood)));
  }

  // 5. Story-preference row (e.g. Mind-Blowing Stories).
  if (a.story && STORY_ROW_TITLES[a.story]) {
    addRow(STORY_ROW_TITLES[a.story], "Your favourite kind of story",
      ranked.filter((e) => e.movie.tone.includes(a.story)));
  }

  // 6. Hidden Gems — strong matches that didn't already headline a row,
  //    leaning to the less mainstream end of the catalogue.
  addRow("Hidden Gems", "Underrated picks, matched to you",
    ranked.filter((e) => !featured.has(e.movie.id) && e.movie.rating < 8.5));

  return rows;
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
function inWatchlist(id) { return State.watchlist.some((m) => m.id === id); }

function toggleWatchlist(id) {
  const idx = State.watchlist.findIndex((m) => m.id === id);
  let added;
  if (idx === -1) {
    const movie = movieById(id);
    if (!movie) return false;
    State.watchlist.push(movie);
    added = true;
  } else {
    State.watchlist.splice(idx, 1);
    added = false;
  }
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
  const wl = State.watchlist.slice();
  let count;
  if (badge.any) count = wl.length;
  else if (badge.genre) count = wl.filter((m) => (m.genres || []).includes(badge.genre)).length;
  else if (badge.category) count = wl.filter((m) => (m.categories || []).includes(badge.category)).length;
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
