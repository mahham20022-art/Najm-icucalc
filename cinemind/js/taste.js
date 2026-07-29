/* ============================================================
   CineMind — Taste engine
   A personal, continuously-evolving taste profile. Every Save,
   Skip and rating retrains it. Stored on-device (localStorage).

   Also holds:
     • Movie DNA — six-dimension fingerprint per film
     • Natural-language search parsing (mood + intent)
     • Mood-chip presets that drive discovery
   ============================================================ */

const Taste = {
  KEY: "cinemind_taste_v1",
  d: null,

  _default() {
    return {
      onboarded: false,
      likes: [], dislikes: [], skipped: [], seen: [],
      ratings: {},                 // movieId -> stars (1–5)
      genre: {}, director: {}, actor: {},   // learned affinity weights
      moods: [],                   // recent mood labels (most-recent first)
      days: [],                    // yyyy-mm-dd activity days (for streak)
      watched: 0, hits: 0, total: 0
    };
  },

  load() {
    try { this.d = Object.assign(this._default(), JSON.parse(localStorage.getItem(this.KEY) || "{}")); }
    catch (e) { this.d = this._default(); }
    return this.d;
  },
  save() { try { localStorage.setItem(this.KEY, JSON.stringify(this.d)); } catch (e) {} },
  reset() { this.d = this._default(); this.save(); },

  // ---- learning ----
  _bump(map, key, amt) { if (key) map[key] = (map[key] || 0) + amt; },
  learn(movie, amt) {
    (movie.genres || []).forEach((g) => this._bump(this.d.genre, g, amt));
    if (movie.director) this._bump(this.d.director, movie.director, amt * 1.5);
    (movie.cast || []).slice(0, 3).forEach((a) => this._bump(this.d.actor, a, amt));
  },
  _pull(list, id) { const i = this.d[list].indexOf(id); if (i > -1) this.d[list].splice(i, 1); },
  markSeen(id) { if (!this.d.seen.includes(id)) this.d.seen.push(id); },
  hasSeen(id) { return this.d.seen.includes(id); },

  like(movie) {
    if (!this.d.likes.includes(movie.id)) this.d.likes.push(movie.id);
    this._pull("dislikes", movie.id); this.markSeen(movie.id);
    this.learn(movie, 2.5); this.d.watched = this.d.likes.length;
    this._recordDay(); this.save();
  },
  dislike(movie) {
    if (!this.d.dislikes.includes(movie.id)) this.d.dislikes.push(movie.id);
    this._pull("likes", movie.id); this.markSeen(movie.id);
    this.learn(movie, -1.6); this._recordDay(); this.save();
  },
  skip(movie) {
    if (!this.d.skipped.includes(movie.id)) this.d.skipped.push(movie.id);
    this.markSeen(movie.id); this.learn(movie, -0.4); this._recordDay(); this.save();
  },
  rate(movie, stars) {
    this.d.ratings[movie.id] = stars;
    this.learn(movie, stars - 3);          // 4–5 reinforce, 1–2 penalize
    this.d.total += 1;
    if (stars >= 4) { this.d.hits += 1; if (!this.d.likes.includes(movie.id)) this.like(movie); }
    this._recordDay(); this.save();
  },
  addMood(label) {
    if (!label) return;
    this.d.moods.unshift(label);
    this.d.moods = this.d.moods.slice(0, 24);
    this._recordDay(); this.save();
  },
  _recordDay() {
    const t = new Date().toISOString().slice(0, 10);
    if (!this.d.days.includes(t)) { this.d.days.push(t); this.d.days = this.d.days.slice(-120); }
  },

  // ---- derived stats ----
  ranked(map, n) {
    return Object.entries(map).filter(([, v]) => v > 0).sort((a, b) => b[1] - a[1]).slice(0, n).map(([k]) => k);
  },
  topGenres(n = 4) { return this.ranked(this.d.genre, n); },
  topDirectors(n = 3) { return this.ranked(this.d.director, n); },
  topActors(n = 4) { return this.ranked(this.d.actor, n); },
  hasSignal() { return this.d.likes.length + this.d.total + Object.keys(this.d.genre).length > 0; },
  tasteScore() {
    const s = this.d.likes.length * 4 + this.d.total * 3 + Object.keys(this.d.genre).length * 2 + this.d.moods.length;
    return Math.max(5, Math.min(100, Math.round(20 + s)));
  },
  accuracy() { return this.d.total ? Math.round((this.d.hits / this.d.total) * 100) : null; },
  streak() {
    if (!this.d.days.length) return 0;
    const set = new Set(this.d.days);
    let n = 0; const day = new Date();
    for (;;) {
      const key = day.toISOString().slice(0, 10);
      if (set.has(key)) { n += 1; day.setDate(day.getDate() - 1); }
      else if (n === 0 && key === new Date().toISOString().slice(0, 10)) { day.setDate(day.getDate() - 1); }
      else break;
    }
    return n;
  },

  // Taste affinity contribution for a movie (used to blend into match score).
  affinity(movie) {
    let s = 0;
    (movie.genres || []).forEach((g) => { s += (this.d.genre[g] || 0); });
    if (movie.director) s += (this.d.director[movie.director] || 0) * 0.5;
    (movie.cast || []).slice(0, 3).forEach((a) => { s += (this.d.actor[a] || 0) * 0.4; });
    return s;
  }
};

// ---- Movie DNA ------------------------------------------------------
// Six-dimension fingerprint derived from genres, rating and runtime.
function movieDNA(movie) {
  const g = movie.genres || [];
  const has = (...names) => names.some((n) => g.includes(n));
  const c = (v) => Math.max(6, Math.min(100, Math.round(v)));
  const r = movie.rating || 6.5;
  const dims = {
    "Mind-Bending": c((has("Sci-Fi", "Mystery") ? 68 : 24) + (r - 6) * 8),
    "Emotion":      c((has("Drama", "Romance") ? 74 : 30) + (has("Family") ? 14 : 0)),
    "Action":       c(has("Action", "Adventure", "Thriller", "War") ? 82 : 22),
    "Science":      c(has("Sci-Fi") ? 92 : (has("Documentary") ? 60 : 14)),
    "Darkness":     c(has("Horror", "Crime", "Thriller", "War") ? 76 : (has("Comedy", "Family", "Animation") ? 16 : 42)),
    "Humor":        c(has("Comedy") ? 86 : (has("Family", "Animation") ? 52 : 14))
  };
  const pacing = has("Action", "Thriller", "Adventure", "Horror") ? "Fast"
    : (has("Drama", "History", "Documentary") || (movie.runtime && movie.runtime >= 145)) ? "Slow"
    : "Medium";
  return { dims, pacing };
}

// ---- Mood chips (Home) ----------------------------------------------
// Each chip is a discovery preset. `g` are TMDB genre ids; `not` exclude.
const MOOD_CHIPS = [
  { label: "Feel Good",     emoji: "😊", g: [35, 10751, 18], not: [27], sort: "vote_average.desc", minVotes: 800 },
  { label: "Mind Blowing",  emoji: "🤯", g: [878, 9648, 53], sort: "vote_average.desc", minVotes: 1500 },
  { label: "Comedy",        emoji: "😂", g: [35] },
  { label: "Horror",        emoji: "😱", g: [27] },
  { label: "Romance",       emoji: "❤️", g: [10749, 18], not: [27] },
  { label: "Psychological", emoji: "🧠", g: [53, 9648, 18], sort: "vote_average.desc", minVotes: 900 },
  { label: "Sci-Fi",        emoji: "🚀", g: [878] },
  { label: "Oscar Winners", emoji: "🎬", g: [18], sort: "vote_average.desc", minVotes: 4000 },
  { label: "Random",        emoji: "🎲", g: [], random: true },
  { label: "Friends",       emoji: "🍿", g: [35, 28, 12], not: [27] },
  { label: "Family",        emoji: "👨‍👩‍👧", g: [10751, 16], not: [27, 53] },
  { label: "Date Night",    emoji: "💑", g: [10749, 18], not: [27] }
];

// ---- Natural-language search ---------------------------------------
// Turns a free-text query into a structured discovery intent. The app
// layer executes it (TMDB when connected, local filter otherwise).
function parseQuery(q) {
  const s = " " + q.toLowerCase().trim() + " ";
  const intent = { text: q, likeTitle: null, include: [], exclude: [], maxRuntime: null, minVotes: 400, sort: "popularity.desc", note: [] };
  const G = TMDB.GENRE_ID;
  const add = (arr, id) => { if (id && !arr.includes(id)) arr.push(id); };

  // "like X" / "similar to X" (stop at a modifier word)
  const like = s.match(/(?:like|similar to|reminds me of)\s+(.+?)(?:\s+(?:but|without|no |that|under|with|for|,)|$)/);
  if (like) { intent.likeTitle = like[1].trim().replace(/["']/g, ""); intent.note.push(`similar to “${intent.likeTitle}”`); }

  // Genre keywords
  const genreWords = {
    "sci-fi": "Sci-Fi", "science fiction": "Sci-Fi", "space": "Sci-Fi",
    "comedy": "Comedy", "funny": "Comedy", "laugh": "Comedy", "hilarious": "Comedy",
    "horror": "Horror", "scary": "Horror", "terrifying": "Horror",
    "romance": "Romance", "romantic": "Romance", "love story": "Romance",
    "thriller": "Thriller", "suspense": "Thriller",
    "mystery": "Mystery", "whodunit": "Mystery",
    "crime": "Crime", "heist": "Crime", "gangster": "Crime",
    "drama": "Drama", "documentary": "Documentary", "true story": "History",
    "fantasy": "Fantasy", "animated": "Family", "animation": "Family", "cartoon": "Family"
  };
  Object.entries(genreWords).forEach(([w, label]) => { if (s.includes(w)) add(intent.include, G[label] || TMDB.GENRE_ID[label]); });
  // map some to full TMDB ids not in GENRE_ID
  if (/\b(action|explosions?)\b/.test(s)) add(intent.include, 28);
  if (/\badventure\b/.test(s)) add(intent.include, 12);

  // Exclusions: "without horror", "no scary", "not sad"
  const exWords = { horror: 27, scary: 27, comedy: 35, romance: 10749, "sci-fi": 878, action: 28 };
  Object.entries(exWords).forEach(([w, id]) => {
    if (new RegExp(`(?:without|no|not|minus)\\s+(?:the\\s+)?[a-z ]*${w}`).test(s)) { add(intent.exclude, id); intent.note.push(`no ${w}`); }
  });

  // Mood / tone modifiers
  if (/\b(happier|happy|feel[- ]?good|uplifting|cheer|light)\b/.test(s)) { add(intent.include, 35); add(intent.exclude, 27); intent.sort = "vote_average.desc"; intent.note.push("happier"); }
  if (/\b(sad|cry|tearjerker|emotional|moving)\b/.test(s)) { add(intent.include, 18); intent.note.push("emotional"); }
  if (/\b(dark|gritty|disturbing|bleak)\b/.test(s)) { add(intent.include, 80); add(intent.include, 53); intent.note.push("darker"); }

  // Quality / prestige
  if (/\b(masterpiece|best|greatest|change my life|life[- ]changing|brilliant|perfect)\b/.test(s)) {
    intent.sort = "vote_average.desc"; intent.minVotes = 3000; intent.note.push("critically acclaimed");
  }

  // Runtime
  if (/\b(under (?:two|2) hours?|less than (?:two|2) hours?|short|quick)\b/.test(s)) { intent.maxRuntime = 120; intent.note.push("under 2h"); }
  if (/\b(epic|long|marathon)\b/.test(s)) { intent.note.push("epic length"); }

  // Company / occasion
  if (/\b(wife|husband|partner|girlfriend|boyfriend|spouse|date|romantic evening)\b/.test(s)) { add(intent.include, 10749); add(intent.include, 18); add(intent.exclude, 27); intent.note.push("date night"); }
  if (/\b(kids?|children|family|whole family)\b/.test(s)) { add(intent.include, 10751); add(intent.exclude, 27); add(intent.exclude, 53); intent.note.push("family-friendly"); }
  if (/\b(friends|group|party)\b/.test(s)) { add(intent.include, 35); add(intent.include, 28); intent.note.push("group watch"); }

  return intent;
}
