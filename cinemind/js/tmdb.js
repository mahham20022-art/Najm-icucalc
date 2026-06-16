/* ============================================================
   CineMind — TMDB live data layer
   Pulls the full movie library (real posters, ratings, cast,
   trailers, streaming) from The Movie Database.

   The API key is supplied by the user and stored ONLY in
   localStorage on their device — it is never committed to the
   repo. When no key is set, the app falls back to the bundled
   demo catalogue so it always works.
   ============================================================ */

const TMDB = {
  base: "https://api.themoviedb.org/3",
  imgBase: "https://image.tmdb.org/t/p/",
  KEY_STORE: "cinemind_tmdb_key",

  // ---- Key management ----
  key() { try { return localStorage.getItem(this.KEY_STORE) || ""; } catch (e) { return ""; } },
  setKey(k) { try { localStorage.setItem(this.KEY_STORE, (k || "").trim()); } catch (e) {} },
  clearKey() { try { localStorage.removeItem(this.KEY_STORE); } catch (e) {} },
  enabled() { return !!this.key(); },

  // v4 read tokens are long JWTs containing dots; v3 keys are 32-char hex.
  _isV4(k) { return k.length > 40 && k.includes("."); },

  img(path, size = "w500") { return path ? this.imgBase + size + path : null; },

  // ---- Core request ----
  async req(path, params = {}) {
    const k = this.key();
    if (!k) throw new Error("No API key");
    const url = new URL(this.base + path);
    Object.entries(params).forEach(([key, v]) => {
      if (v !== null && v !== undefined && v !== "") url.searchParams.set(key, v);
    });
    const opts = { headers: { "Content-Type": "application/json;charset=utf-8" } };
    if (this._isV4(k)) opts.headers.Authorization = "Bearer " + k;
    else url.searchParams.set("api_key", k);

    const res = await fetch(url.toString(), opts);
    if (!res.ok) {
      const msg = res.status === 401 ? "Invalid API key" : "TMDB error " + res.status;
      throw new Error(msg);
    }
    return res.json();
  },

  // Quick validation used by the settings panel.
  async validate(k) {
    const prev = this.key();
    this.setKey(k);
    try { await this.req("/configuration"); this.setKey(k); return true; }
    catch (e) { if (prev) this.setKey(prev); else this.clearKey(); throw e; }
  },

  // ---- Genre maps ----
  // App genre label -> TMDB id
  GENRE_ID: {
    "Sci-Fi": 878, "Drama": 18, "Thriller": 53, "Mystery": 9648, "Crime": 80,
    "Fantasy": 14, "Documentary": 99, "Comedy": 35, "Romance": 10749, "History": 36
  },
  // Full TMDB id -> readable label (for displaying real genres)
  ID_GENRE: {
    28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy", 80: "Crime",
    99: "Documentary", 18: "Drama", 10751: "Family", 14: "Fantasy", 36: "History",
    27: "Horror", 10402: "Music", 9648: "Mystery", 10749: "Romance", 878: "Sci-Fi",
    10770: "TV Movie", 53: "Thriller", 10752: "War", 37: "Western"
  },

  // Survey signal -> TMDB genre id sets used to build rows.
  MOOD_GENRES: {
    Happy: [35, 10751], Curious: [9648, 878], Emotional: [18, 10749],
    Lonely: [18], Motivated: [12, 36], Stressed: [35, 12]
  },
  STORY_GENRES: {
    "Mind-bending": [878, 9648], "Emotional": [18, 10749], "Inspirational": [18, 36],
    "Action-packed": [28, 12], "Dark": [27, 53, 80], "Real-life stories": [99, 36]
  },
  ARCHETYPE_GENRES: {
    "The Thinker": [9648, 878], "The Dreamer": [14, 10749], "The Explorer": [12, 14],
    "The Rebel": [53, 80], "The Leader": [36, 18], "The Outsider": [18, 99]
  },

  // ---- Normalization to the app's movie shape ----
  normalize(m) {
    const ids = m.genre_ids || (m.genres ? m.genres.map((g) => g.id) : []);
    const genres = ids.map((id) => this.ID_GENRE[id]).filter(Boolean).slice(0, 4);
    return {
      id: "tmdb" + m.id,
      tmdbId: m.id,
      title: m.title || m.name || "Untitled",
      year: (m.release_date || "").slice(0, 4) || "—",
      rating: Math.round((m.vote_average || 0) * 10) / 10,
      runtime: m.runtime || null,
      genres: genres.length ? genres : ["Film"],
      poster: this.img(m.poster_path, "w500"),
      backdrop: this.img(m.backdrop_path, "w780"),
      synopsis: m.overview || "No synopsis available yet.",
      grad: gradFromString(m.title || m.name || String(m.id)),
      tmdb: true
    };
  },

  // ---- Discover wrapper ----
  async discover(params = {}) {
    const data = await this.req("/discover/movie", Object.assign({
      include_adult: "false",
      language: "en-US",
      page: 1
    }, params));
    return (data.results || []).map((m) => this.normalize(m));
  },

  // Full details for the modal (runtime, cast, director, providers, trailer).
  async details(tmdbId) {
    const m = await this.req("/movie/" + tmdbId, {
      append_to_response: "credits,videos,watch/providers",
      language: "en-US"
    });
    const movie = this.normalize(m);
    movie.runtime = m.runtime || null;
    const crew = (m.credits && m.credits.crew) || [];
    const cast = (m.credits && m.credits.cast) || [];
    movie.director = (crew.find((c) => c.job === "Director") || {}).name || "—";
    movie.cast = cast.slice(0, 4).map((c) => c.name);
    const vids = (m.videos && m.videos.results) || [];
    const trailer = vids.find((v) => v.site === "YouTube" && v.type === "Trailer") ||
                    vids.find((v) => v.site === "YouTube");
    movie.trailerKey = trailer ? trailer.key : null;
    // Streaming providers (US flatrate) -> names
    const prov = m["watch/providers"] && m["watch/providers"].results &&
                 m["watch/providers"].results.US;
    movie.streaming = prov && prov.flatrate ? prov.flatrate.slice(0, 5).map((p) => p.provider_name) : [];
    return movie;
  }
};

// Deterministic gradient from a string so each real poster has a themed
// fallback colour if its image is missing or slow to load.
function gradFromString(str) {
  const keys = Object.keys(GRADIENTS);
  let h = 0;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) >>> 0;
  return keys[h % keys.length]; // a gradient KEY, consistent with bundled movies
}

// A short, personalized "why" line for a TMDB movie based on the answers.
function tmdbWhy(movie, answers) {
  const picked = (answers.genres || []).filter((g) => movie.genres.includes(g));
  if (picked.length) {
    return `Recommended because you love ${picked.slice(0, 2).join(" & ")}${answers.mood ? ` and you're feeling ${answers.mood.toLowerCase()}` : ""}.`;
  }
  if (answers.story) return `Matched to your taste for ${answers.story.toLowerCase()} stories.`;
  return `A highly rated pick chosen to fit your profile.`;
}

// Synthesised match score for a TMDB movie (no static categories here).
function tmdbMatch(movie, answers) {
  let s = 64;
  const picked = answers.genres || [];
  s += movie.genres.filter((g) => picked.includes(g)).length * 11;
  if (answers.mood && (TMDB.MOOD_GENRES[answers.mood] || []).some((id) => movie.genres.includes(TMDB.ID_GENRE[id]))) s += 8;
  s += (movie.rating - 6.5) * 4;
  let h = 0;
  for (let i = 0; i < movie.id.length; i++) h = (h * 31 + movie.id.charCodeAt(i)) % 11;
  s += h - 5;
  return Math.max(62, Math.min(99, Math.round(s)));
}

// ---- Build personalized rows from live TMDB data ----
// Returns array of { title, hint, entries:[{movie, match}] }. Falls back to
// the local engine's rows on any failure so the screen is never empty.
async function tmdbBuildRows(answers, profile) {
  const orJoin = (ids) => ids.join("|");
  const pickedIds = (answers.genres || []).map((g) => TMDB.GENRE_ID[g]).filter(Boolean);
  const runtimeFilter = answers.pace === "Fast and intense" ? { "with_runtime.lte": 120 }
    : answers.pace === "Slow and deep" ? { "with_runtime.gte": 130 } : {};

  const arch = profile ? profile.archetype : "The Thinker";
  const archIds = TMDB.ARCHETYPE_GENRES[arch] || [];
  const moodIds = TMDB.MOOD_GENRES[answers.mood] || [];
  const storyIds = TMDB.STORY_GENRES[answers.story] || [];

  // Each spec is one discover query.
  const specs = [];
  specs.push({
    title: "Perfect Matches", hint: "Your highest AI match picks",
    params: Object.assign({
      with_genres: pickedIds.length ? orJoin(pickedIds) : orJoin(archIds),
      sort_by: "vote_average.desc", "vote_count.gte": 800
    }, runtimeFilter)
  });
  specs.push({
    title: `Because you're ${arch}`, hint: "Tuned to your character type",
    params: { with_genres: orJoin(archIds), sort_by: "popularity.desc", "vote_count.gte": 400 }
  });
  (answers.genres || []).slice(0, 2).forEach((g) => {
    specs.push({
      title: `Because you love ${g}`, hint: "From the genres you picked",
      params: { with_genres: TMDB.GENRE_ID[g], sort_by: "popularity.desc", "vote_count.gte": 300 }
    });
  });
  if (moodIds.length) specs.push({
    title: `For your ${(answers.mood || "").toLowerCase()} mood`, hint: "Matched to how you feel today",
    params: { with_genres: orJoin(moodIds), sort_by: "popularity.desc", "vote_count.gte": 300 }
  });
  if (storyIds.length) specs.push({
    title: STORY_ROW_TITLES[answers.story] || "Your Kind of Story", hint: "Your favourite kind of story",
    params: { with_genres: orJoin(storyIds), sort_by: "vote_average.desc", "vote_count.gte": 500 }
  });
  specs.push({
    title: "Hidden Gems", hint: "Underrated, matched to you",
    params: {
      with_genres: pickedIds.length ? orJoin(pickedIds) : orJoin(archIds),
      sort_by: "vote_average.desc", "vote_count.gte": 120, "vote_count.lte": 1200
    }
  });

  const results = await Promise.all(specs.map((s) =>
    TMDB.discover(s.params).catch(() => [])
  ));

  const featured = new Set();
  const rows = [];
  results.forEach((movies, i) => {
    // Cache for modal/watchlist lookups and attach match + why.
    let entries = movies
      .filter((m) => m.poster) // only show titles with artwork
      .map((m) => {
        cacheMovie(m);
        m.why = tmdbWhy(m, answers);
        return { movie: m, match: tmdbMatch(m, answers) };
      });
    // Freshness: drop already-featured titles; backfill if a row gets too thin.
    const fresh = entries.filter((e) => !featured.has(e.movie.id));
    entries = (fresh.length >= 4 ? fresh : entries).sort((a, b) => b.match - a.match).slice(0, 14);
    if (entries.length < 4) return;
    entries.slice(0, 8).forEach((e) => featured.add(e.movie.id));
    rows.push({ title: specs[i].title, hint: specs[i].hint, entries });
  });

  if (!rows.length) throw new Error("No TMDB results");
  return rows;
}
