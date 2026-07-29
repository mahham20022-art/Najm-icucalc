/* ============================================================
   CineMind — Screens
   Each function returns an HTML string for a screen/component.
   Behavior is wired up in app.js after mount.
   ============================================================ */

// ---- Small shared bits ----------------------------------------------
const SPARK_SVG = '<svg class="spark" viewBox="0 0 24 24" fill="none"><path d="M12 2 9.5 8.5 3 11l6.5 2.5L12 20l2.5-6.5L21 11l-6.5-2.5z" fill="currentColor"/></svg>';

// Escape user/API-provided text before injecting into HTML.
function esc(s) {
  return String(s == null ? "" : s)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}

function posterArt(movie, extra = "") {
  const bg = gradFor(movie.grad);
  // Real TMDB artwork when available, with the themed gradient as a fallback
  // layer behind it (and on image error).
  const inner = movie.poster
    ? `<img class="poster__img" src="${esc(movie.poster)}" alt="${esc(movie.title)}" loading="lazy"
         onerror="this.remove()" />`
    : `<div class="poster__logo">${esc(movie.title)}</div>`;
  return `<div class="poster__art" style="background:${bg}">${extra}${inner}</div>`;
}

function posterCard(entry, opts = {}) {
  const m = entry.movie;
  const match = entry.match;
  const removeBtn = opts.removable
    ? `<button class="wl-remove" data-remove="${m.id}" aria-label="Remove from watchlist">✕</button>` : "";
  const matchBadge = `<span class="poster__match"><b>${match}%</b> Match</span>`;
  const rating = m.rating ? `★ ${m.rating.toFixed(1)}` : "NR";
  const rt = m.runtime ? `<span>${formatRuntime(m.runtime)}</span>` : "";
  return `<button class="poster" data-movie="${esc(m.id)}">
    ${posterArt(m, matchBadge + removeBtn)}
    <div class="poster__body">
      <h4 class="poster__name">${esc(m.title)}</h4>
      <div class="poster__meta">
        <span class="imdb">${rating}</span>
        <span>${esc(m.year)}</span>
        ${rt}
      </div>
      <p class="poster__why">${esc(m.why || "")}</p>
    </div>
  </button>`;
}

function formatRuntime(min) {
  if (!min) return "";
  const h = Math.floor(min / 60), m = min % 60;
  return h ? `${h}h ${m}m` : `${m}m`;
}

// ---- 1. Hero ---------------------------------------------------------
function HeroScreen() {
  // Build a blurred collage from the movie gradients.
  const tiles = MOVIES.slice(0, 18).map((m, i) =>
    `<div class="hero__poster" style="background:${gradFor(m.grad)};animation-delay:${(i % 6) * -1.2}s"></div>`
  ).join("");

  const returning = Taste.d && Taste.d.onboarded;
  return `<section class="page hero">
    <div class="hero__collage">${tiles}</div>
    <div class="hero__inner">
      <span class="hero__badge"><span class="dot"></span> Your personal AI movie companion</span>
      <h1>Stop scrolling.<br><span class="accent">Start watching.</span></h1>
      <p class="hero__sub">CineMind learns your taste and finds the perfect movie in 30 seconds — not another endless database.</p>
      <div class="hero__cta">
        <button class="btn btn--primary btn--lg" data-action="${returning ? "go-home" : "start"}">
          ${returning ? "Continue" : "Build My Taste Profile"}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </button>
      </div>
      <div class="hero__trust">
        <span><b>30s</b> to your first pick</span>
        <span><b>∞</b> movie library</span>
        <span><b>Learns</b> every tap</span>
      </div>
    </div>
  </section>`;
}

// ---- Onboarding: choose movies you love -----------------------------
function OnboardingScreen(pool, picked) {
  const min = 4;
  const grid = pool.map((m) => {
    const on = picked.includes(m.id);
    const art = m.poster
      ? `<img src="${esc(m.poster)}" alt="${esc(m.title)}" loading="lazy" onerror="this.remove()"/>`
      : `<span class="ob-title">${esc(m.title)}</span>`;
    return `<button class="ob-poster ${on ? "on" : ""}" data-onboard="${esc(m.id)}" style="background:${gradFor(m.grad)}">
      ${art}
      <span class="ob-check">✓</span>
      <span class="ob-name">${esc(m.title)}</span>
    </button>`;
  }).join("");

  const enough = picked.length >= min;
  return `<section class="page container ob">
    <div class="ob__head">
      <div class="page-eyebrow">Step 1 · Build your taste</div>
      <h1>Pick movies you love</h1>
      <p>Tap everything you'd happily rewatch. The more you choose, the smarter CineMind gets.</p>
    </div>
    <div class="ob-grid" id="obGrid">${grid}</div>
    <div class="ob__foot">
      <button class="btn btn--ghost" data-action="onboard-more">Show more</button>
      <button class="btn btn--primary btn--lg" data-action="onboard-done" ${enough ? "" : "disabled"}>
        ${enough ? `Continue with ${picked.length}` : `Pick ${min - picked.length} more`}
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
    </div>
  </section>`;
}

// ---- Home: mood-first discovery -------------------------------------
function greeting() {
  const h = new Date().getHours();
  if (h < 5) return "Still up?";
  if (h < 12) return "Good morning";
  if (h < 18) return "Good afternoon";
  return "Good evening";
}

function HomeScreen() {
  const chips = MOOD_CHIPS.map((c) =>
    `<button class="mood-tile ${State.mood === c.label ? "active" : ""}" data-moodchip="${esc(c.label)}">
      <span class="mt-emoji">${c.emoji}</span><span>${esc(c.label)}</span>
    </button>`).join("");

  return `<section class="page container home page-pad">
    <div class="home__top">
      <div>
        <div class="home__hello">${greeting()} 👋</div>
        <h1 class="home__q">What are you in the mood for tonight?</h1>
      </div>
      <button class="icon-btn" data-action="open-settings" aria-label="Settings" title="Settings">
        <svg viewBox="0 0 24 24" fill="none" width="20" height="20"><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z" stroke="currentColor" stroke-width="1.6"/><path d="M19.4 13a7.8 7.8 0 0 0 0-2l2-1.5-2-3.5-2.4 1a7.6 7.6 0 0 0-1.7-1l-.4-2.5h-4l-.4 2.5a7.6 7.6 0 0 0-1.7 1l-2.4-1-2 3.5L4.6 11a7.8 7.8 0 0 0 0 2l-2 1.5 2 3.5 2.4-1a7.6 7.6 0 0 0 1.7 1l.4 2.5h4l.4-2.5a7.6 7.6 0 0 0 1.7-1l2.4 1 2-3.5z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
      </button>
    </div>

    <div class="mood-scroll">${chips}</div>

    <form class="ai-search" data-action="ai-search-form">
      <span class="ai-search__spark">${SPARK_SVG}</span>
      <input id="aiSearch" type="text" autocomplete="off"
        placeholder="Try: a movie like Interstellar but happier" aria-label="Describe what you want to watch" />
      <button class="ai-search__go" type="submit" aria-label="Search">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
    </form>

    <div class="deck-wrap">
      <div class="deck__label" id="deckLabel">${State.mood ? esc(State.mood) : "Tonight's pick for you"}</div>
      <div id="deckHost">${deckSkeleton()}</div>
    </div>
  </section>`;
}

function deckSkeleton() {
  return `<div class="deck-card skeleton-card">
    <div class="deck-card__art skeleton"></div>
    <div class="deck-card__body">
      <div class="skeleton" style="height:22px;width:60%;border-radius:8px;margin-bottom:12px"></div>
      <div class="skeleton" style="height:12px;width:90%;border-radius:6px;margin-bottom:8px"></div>
      <div class="skeleton" style="height:12px;width:70%;border-radius:6px"></div>
    </div>
  </div>`;
}

// The swipeable Save/Skip discovery card.
function deckCard(entry) {
  if (!entry) {
    return `<div class="deck-empty">
      <div class="empty__art">🎉</div>
      <h3>That's a wrap for now</h3>
      <p>Pick another mood above, or hit Surprise Me.</p>
    </div>`;
  }
  const m = entry.movie;
  const dna = movieDNA(m);
  const because = tasteBecause(m);
  const art = m.poster
    ? `<img src="${esc(m.poster)}" alt="${esc(m.title)}" onerror="this.remove()"/>`
    : `<div class="poster__logo">${esc(m.title)}</div>`;

  return `<article class="deck-card" data-deck-card>
    <div class="deck-card__art" style="background:${gradFor(m.grad)}">
      ${art}
      <span class="deck-card__score"><b>${entry.match}%</b> match</span>
      <div class="deck-card__pacing">${dnaBadges(dna)}</div>
    </div>
    <div class="deck-card__body">
      <h2 class="deck-card__title">${esc(m.title)} <span>${esc(m.year)}</span></h2>
      <div class="deck-card__meta">
        ${m.rating ? `<span class="imdb">★ ${m.rating.toFixed(1)}</span>` : ""}
        ${m.runtime ? `<span>${formatRuntime(m.runtime)}</span>` : ""}
        <span>${esc((m.genres || []).slice(0, 3).join(" · "))}</span>
      </div>
      ${because ? `<p class="deck-card__because">${because}</p>` : ""}
      <p class="deck-card__why">${esc(m.why || tmdbWhy(m, State.answers))}</p>
      <div class="deck-actions">
        <button class="deck-btn deck-btn--skip" data-action="deck-skip" aria-label="Skip">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>
        </button>
        <button class="deck-btn deck-btn--info" data-movie="${esc(m.id)}" aria-label="Details">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 8h.01M11 12h1v4h1" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.6"/></svg>
        </button>
        <button class="deck-btn deck-btn--save" data-action="deck-save" aria-label="Save">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none"><path d="M12 21s-7-4.5-9.5-9C1 9 2.5 5 6 5c2 0 3.2 1.1 4 2 .8-.9 2-2 4-2 3.5 0 5 4 3.5 7C19 16.5 12 21 12 21z" fill="currentColor"/></svg>
        </button>
      </div>
    </div>
  </article>`;
}

// Small "because you liked…" line from the taste profile.
function tasteBecause(m) {
  const g = Taste.topGenres(2).filter((x) => (m.genres || []).includes(x));
  if (g.length) return `Because you like <b>${esc(g.join(" & "))}</b>`;
  const dir = Taste.topDirectors(2).find((d) => d === m.director);
  if (dir) return `Because you like <b>${esc(dir)}</b>`;
  return "";
}

function dnaBadges(dna) {
  const top = Object.entries(dna.dims).sort((a, b) => b[1] - a[1]).slice(0, 2).map(([k]) => k);
  return top.map((t) => `<span class="pace-badge">${esc(t)}</span>`).join("") +
    `<span class="pace-badge">${esc(dna.pacing)} pace</span>`;
}

// Movie DNA visualisation (bars) for the detail modal.
function dnaBlock(movie) {
  const dna = movieDNA(movie);
  const bars = Object.entries(dna.dims).map(([k, v]) =>
    `<div class="dna-row">
      <span class="dna-label">${esc(k)}</span>
      <span class="dna-track"><span class="dna-fill" style="width:${v}%"></span></span>
      <span class="dna-val">${v}%</span>
    </div>`).join("");
  return `<div class="dna">
    <div class="dna__head">🧬 Movie DNA <span>Pacing · ${esc(dna.pacing)}</span></div>
    ${bars}
  </div>`;
}

// "Did we get it right?" star rating.
function ratingBlock(movie) {
  const current = Taste.d.ratings[movie.id] || 0;
  const stars = [1, 2, 3, 4, 5].map((n) =>
    `<button class="star ${n <= current ? "on" : ""}" data-rate="${n}" data-movie="${esc(movie.id)}" aria-label="${n} stars">★</button>`).join("");
  return `<div class="rate-block">
    <div class="rate-block__q">Watched it? Did we get it right?</div>
    <div class="stars">${stars}</div>
  </div>`;
}

// ---- Profile ---------------------------------------------------------
function ProfileScreen() {
  const p = State.profile || buildProfileFromTaste();
  const topG = Taste.topGenres(5);
  const topD = Taste.topDirectors(3);
  const acc = Taste.accuracy();
  const genreBars = (topG.length ? topG : ["—"]).map((g, i) => {
    const w = 100 - i * 15;
    return `<div class="dna-row"><span class="dna-label">${esc(g)}</span><span class="dna-track"><span class="dna-fill" style="width:${w}%"></span></span></div>`;
  }).join("");

  const badgeCards = BADGES.map((b) => {
    const pr = badgeProgress(b);
    return `<div class="mini-badge ${pr.unlocked ? "on" : ""}" title="${esc(b.desc)}">
      <span class="mb-emoji">${b.emoji}</span><span class="mb-name">${esc(b.name)}</span>
      <span class="mb-prog">${pr.unlocked ? "Unlocked" : pr.count + "/" + pr.goal}</span>
    </div>`;
  }).join("");

  return `<section class="page container page-pad">
    <div class="section-head"><h1>Your Taste</h1>
      <button class="btn btn--ghost" data-action="reset-taste" style="padding:10px 18px;font-size:13px">Reset</button>
    </div>

    <div class="profile-card reveal">
      <div class="score-ring" style="--val:${p.score}">
        <div><b>${p.score}</b><small>Taste Score</small></div>
      </div>
      <div>
        <div class="profile-card__title">AI Personality · ${esc(p.archetype)}</div>
        <h2>You are ${archetypeArticle(p.archetype)} ${esc(p.archetype.replace("The ", ""))}</h2>
        <p>${esc(p.summary)}</p>
        <div class="tags">${p.tags.map((t) => `<span class="tag">${esc(t)}</span>`).join("")}</div>
      </div>
    </div>

    <div class="stat-strip" style="margin-top:22px">
      <div class="stat"><b>${Taste.d.watched}</b><small>Movies loved</small></div>
      <div class="stat"><b>${Taste.d.total}</b><small>Rated</small></div>
      <div class="stat"><b>${Taste.streak()}🔥</b><small>Day streak</small></div>
      <div class="stat"><b>${acc == null ? "—" : acc + "%"}</b><small>Accuracy</small></div>
    </div>

    <div class="row"><div class="row__head"><h3 class="row__title">Favourite Genres</h3></div>
      <div class="dna" style="margin-top:0">${genreBars}</div>
    </div>

    ${topD.length ? `<div class="row"><div class="row__head"><h3 class="row__title">Favourite Directors</h3></div>
      <div class="chips-wrap">${topD.map((d) => `<span class="chip">${esc(d)}</span>`).join("")}</div></div>` : ""}

    <div class="row"><div class="row__head"><h3 class="row__title">Achievements</h3></div>
      <div class="mini-badges">${badgeCards}</div>
    </div>
  </section>`;
}

// ---- Search ----------------------------------------------------------
function SearchScreen() {
  return `<section class="page container page-pad">
    <div class="page-eyebrow">Smart Search</div>
    <div class="section-head"><h1>Ask for anything</h1></div>
    <form class="ai-search ai-search--lg" data-action="ai-search-form">
      <span class="ai-search__spark">${SPARK_SVG}</span>
      <input id="aiSearch" type="text" autocomplete="off"
        placeholder="A masterpiece under two hours…" aria-label="Describe what you want to watch" />
      <button class="ai-search__go" type="submit" aria-label="Search">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
    </form>
    <div class="search-suggestions">
      ${["A movie that will change my life", "Something like Se7en without horror", "A beautiful film to watch with my wife", "Mind-blowing sci-fi under 2 hours"]
        .map((s) => `<button class="mood-chip" data-suggest="${esc(s)}">${esc(s)}</button>`).join("")}
    </div>
    <div id="searchHost"></div>
  </section>`;
}

// ---- 2. Survey wizard ------------------------------------------------
function WizardScreen(stepIndex) {
  const q = QUESTIONS[stepIndex];
  const total = QUESTIONS.length;
  const pct = Math.round(((stepIndex) / total) * 100);
  const current = State.answers[q.id];
  const isMulti = q.type === "multi";

  const optsHtml = q.options.map((o) => {
    const selected = isMulti ? (current || []).includes(o.v) : current === o.v;
    return `<button class="opt ${q.layout === 'pills' ? 'opt--pill' : ''} ${selected ? 'is-selected' : ''}"
      data-opt="${o.v}">
      <span class="emoji">${o.emoji}</span><span>${o.v}</span>
    </button>`;
  }).join("");

  const canNext = isMulti ? (current && current.length > 0) : !!current;
  const lastStep = stepIndex === total - 1;

  return `<section class="page wizard container">
    <div class="wizard__top">
      <button class="wizard__back" data-action="wizard-back" aria-label="Back">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
      <div class="progress"><div class="progress__fill" style="width:${pct}%"></div></div>
      <span class="wizard__step-label">${stepIndex + 1} / ${total}</span>
    </div>
    <div class="wizard__body">
      <div class="qcard" id="qcard">
        <div class="qcard__eyebrow">${q.eyebrow}</div>
        <h2 class="qcard__q">${q.q}</h2>
        <p class="qcard__hint">${q.hint}</p>
        <div class="options ${q.layout === 'pills' ? 'options--pills' : ''}" id="options">${optsHtml}</div>
        <div class="wizard__foot">
          <button class="btn btn--primary btn--lg" data-action="wizard-next" ${canNext ? "" : "disabled"}>
            ${lastStep ? "Analyze My Taste" : "Continue"}
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </button>
        </div>
      </div>
    </div>
  </section>`;
}

// ---- 3. Analysis -----------------------------------------------------
function AnalysisScreen() {
  return `<section class="page analysis container">
    <div>
      <div class="scanner">
        <div class="scanner__ring r1"></div>
        <div class="scanner__ring r2"></div>
        <div class="scanner__ring r3"></div>
        <div class="scanner__sweep"></div>
        <div class="scanner__dot"></div>
        <div class="scanner__core">🧬</div>
      </div>
      <h2>Analyzing Your Entertainment DNA…</h2>
      <p class="analysis__status" id="analysisStatus">Mapping your mood signature…</p>
      <div class="analysis__bar"><i id="analysisBar"></i></div>
    </div>
  </section>`;
}

// ---- 4 & 5. Results dashboard + recommendation rows ------------------
function ResultsScreen() {
  const p = State.profile;
  const tags = p.tags.map((t) => `<span class="tag">${t}</span>`).join("");

  // When TMDB is connected we render skeletons and fill them in asynchronously
  // (app.js -> populateResults). Otherwise render the bundled library now.
  let rowsHtml;
  if (TMDB.enabled()) {
    rowsHtml = `<div id="rowsHost">${skeletonRows(4)}</div>`;
  } else {
    rowsHtml = `<div id="rowsHost">${renderRows(buildRecommendationRows())}</div>`;
  }

  const banner = TMDB.enabled()
    ? `<div class="data-banner data-banner--live">
        <span><span class="live-dot"></span> Live library · The Movie Database</span>
        <button class="data-banner__btn" data-action="open-settings">Manage</button>
      </div>`
    : `<div class="data-banner">
        <span>🎬 You're viewing a demo library of ${MOVIES.length} films. Connect TMDB for the full catalogue with real posters.</span>
        <button class="data-banner__btn data-banner__btn--cta" data-action="open-settings">Connect full library</button>
      </div>`;

  return `<section class="page results container page-pad">
    <div class="topbar">
      <div class="brand">
        <span class="brand__logo">${SPARK_SVG_LOGO()}</span> CineMind
      </div>
      <div style="display:flex;gap:10px;align-items:center">
        <button class="icon-btn" data-action="open-settings" aria-label="Settings" title="Settings">
          <svg viewBox="0 0 24 24" fill="none" width="20" height="20"><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z" stroke="currentColor" stroke-width="1.6"/><path d="M19.4 13a7.8 7.8 0 0 0 0-2l2-1.5-2-3.5-2.4 1a7.6 7.6 0 0 0-1.7-1l-.4-2.5h-4l-.4 2.5a7.6 7.6 0 0 0-1.7 1l-2.4-1-2 3.5L4.6 11a7.8 7.8 0 0 0 0 2l-2 1.5 2 3.5 2.4-1a7.6 7.6 0 0 0 1.7 1l.4 2.5h4l.4-2.5a7.6 7.6 0 0 0 1.7-1l2.4 1 2-3.5z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
        </button>
        <button class="btn btn--ghost" data-action="retake" style="padding:11px 20px;font-size:14px">Retake quiz</button>
      </div>
    </div>

    <div class="profile-card reveal" style="animation-delay:.05s">
      <div class="score-ring" style="--val:${p.score}">
        <div><b>${p.score}%</b><small>Match</small></div>
      </div>
      <div>
        <div class="profile-card__title">Your Entertainment DNA · ${p.archetype}</div>
        <h2>You are ${archetypeArticle(p.archetype)} ${p.archetype.replace("The ", "")}</h2>
        <p>${p.summary}</p>
        <div class="tags">${tags}</div>
      </div>
    </div>

    ${banner}
    ${rowsHtml}
  </section>`;
}

// Renders an array of row defs to HTML (shared by local + TMDB paths).
function renderRows(rows) {
  if (!rows.length) return `<div class="empty" style="margin-top:30px"><div class="empty__art">🎭</div><h3>No matches found</h3><p>Try retaking the quiz with different answers.</p></div>`;
  return rows.map((def) => {
    const cards = def.entries.map((e) => posterCard(e)).join("");
    return `<div class="row">
      <div class="row__head">
        <h3 class="row__title">${esc(def.title)}<em>${esc(def.hint)}</em></h3>
      </div>
      <div class="carousel">${cards}</div>
    </div>`;
  }).join("");
}

function skeletonRows(n) {
  return Array.from({ length: n }).map(() => skeletonRow()).join("");
}

function archetypeArticle(name) {
  const word = name.replace("The ", "");
  return /^[AEIOU]/i.test(word) ? "an" : "a";
}

function SPARK_SVG_LOGO() {
  return '<svg viewBox="0 0 24 24" fill="none"><path d="M12 2 9.5 8.5 3 11l6.5 2.5L12 20l2.5-6.5L21 11l-6.5-2.5z" fill="#fff"/></svg>';
}

// ---- 6. Movie details modal -----------------------------------------
function MovieModal(movie, opts = {}) {
  const match = matchFor(movie);
  const inList = inWatchlist(movie.id);
  const chips = (movie.genres || []).map((g) => `<span class="chip">${esc(g)}</span>`).join("");

  // Hero: real backdrop/poster image when present, gradient fallback behind.
  const heroImg = (movie.backdrop || movie.poster)
    ? `<img class="sheet__img" src="${esc(movie.backdrop || movie.poster)}" alt="${esc(movie.title)}" onerror="this.remove()"/>`
    : `<div class="poster__logo">${esc(movie.title)}</div>`;

  const trailerBtn = movie.trailerKey
    ? `<a class="sheet__trailer" href="https://www.youtube.com/watch?v=${esc(movie.trailerKey)}" target="_blank" rel="noopener">
         <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M8 5v14l11-7z" fill="currentColor"/></svg> Watch Trailer</a>`
    : `<button class="sheet__trailer" data-action="trailer">
         <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M8 5v14l11-7z" fill="currentColor"/></svg> Play Trailer</button>`;

  const loading = opts.loading ? `<span class="sheet__loading">Loading details…</span>` : "";
  const facts = [];
  if (movie.director) facts.push(`<div class="fact"><small>Director</small><span>${esc(movie.director)}</span></div>`);
  if (movie.cast && movie.cast.length) facts.push(`<div class="fact"><small>Cast</small><span>${esc(movie.cast.join(", "))}</span></div>`);
  if (movie.runtime) facts.push(`<div class="fact"><small>Runtime</small><span>${formatRuntime(movie.runtime)}</span></div>`);
  facts.push(`<div class="fact"><small>Genres</small><span>${esc((movie.genres || []).join(", "))}</span></div>`);

  let streamingBlock = "";
  if (movie.streaming && movie.streaming.length) {
    const streaming = movie.streaming.map((s) => {
      const c = STREAM_COLORS[s] || "#5b5b66";
      return `<span class="stream-pill"><span class="ico" style="background:${c}">${esc(s[0])}</span>${esc(s)}</span>`;
    }).join("");
    streamingBlock = `<small class="sheet__label">Where to watch</small><div class="streaming">${streaming}</div>`;
  }

  const ratingStr = movie.rating ? `★ ${movie.rating.toFixed(1)}` : "Not rated";

  return `<div class="overlay" data-overlay>
    <div class="sheet" role="dialog" aria-modal="true" aria-label="${esc(movie.title)} details">
      <button class="sheet__close" data-close aria-label="Close">✕</button>
      <div class="sheet__hero" style="background:${gradFor(movie.grad)}">
        ${heroImg}
        ${trailerBtn}
      </div>
      <div class="sheet__body">
        <h2 class="sheet__title">${esc(movie.title)} ${loading}</h2>
        <div class="sheet__meta">
          <span class="imdb">${ratingStr}</span>
          <span>${esc(movie.year)}</span>
          ${movie.runtime ? `<span>${formatRuntime(movie.runtime)}</span>` : ""}
          <span class="match">${match}% Match</span>
        </div>
        <div class="genre-chips">${chips}</div>
        <p class="sheet__synopsis">${esc(movie.synopsis)}</p>

        <div class="ai-block">
          <div class="ai-block__head">${SPARK_SVG} Why CineMind picked this for you</div>
          <p>${esc(movie.why || tmdbWhy(movie, State.answers))}</p>
        </div>

        ${dnaBlock(movie)}

        ${ratingBlock(movie)}

        <div class="facts">${facts.join("")}</div>

        ${streamingBlock}

        <div class="sheet__actions">
          <button class="btn btn--primary" data-action="toggle-watchlist" data-movie="${esc(movie.id)}">
            ${inList ? watchlistRemoveLabel() : watchlistAddLabel()}
          </button>
          <button class="btn btn--ghost" data-close>Close</button>
        </div>
      </div>
    </div>
  </div>`;
}

// ---- Settings / TMDB connection modal -------------------------------
function SettingsModal() {
  const connected = TMDB.enabled();
  return `<div class="overlay" data-overlay>
    <div class="sheet sheet--narrow" role="dialog" aria-modal="true" aria-label="Settings">
      <button class="sheet__close" data-close aria-label="Close">✕</button>
      <div class="sheet__body" style="margin-top:0;padding-top:30px">
        <h2 class="sheet__title" style="font-size:26px">Connect the full library</h2>
        <p class="sheet__synopsis" style="margin-bottom:18px">
          CineMind can stream the entire ${`<b>TMDB</b>`} movie catalogue — real posters, ratings, cast and trailers.
          Add a free API key (it's stored only on this device, never uploaded).
        </p>
        <ol class="howto">
          <li>Create a free account at <a href="https://www.themoviedb.org/signup" target="_blank" rel="noopener">themoviedb.org</a></li>
          <li>Open <a href="https://www.themoviedb.org/settings/api" target="_blank" rel="noopener">Settings → API</a> and request a key (choose “Developer”)</li>
          <li>Copy your <b>API Key (v3 auth)</b> and paste it below</li>
        </ol>
        <div class="key-field">
          <input id="tmdbKeyInput" type="text" inputmode="text" autocomplete="off" spellcheck="false"
            placeholder="Paste TMDB API key…" value="${esc(TMDB.key())}" />
          <button class="btn btn--primary" data-action="save-key">${connected ? "Update" : "Connect"}</button>
        </div>
        <div id="keyStatus" class="key-status">${connected ? '<span class="ok">✓ Connected to live library</span>' : ""}</div>
        ${connected ? `<button class="btn btn--ghost btn--block" data-action="disconnect-key" style="margin-top:14px">Disconnect &amp; use demo library</button>` : ""}
        <p class="key-note">No key? No problem — the app keeps working with a built-in demo library.</p>
      </div>
    </div>
  </div>`;
}

function watchlistAddLabel() {
  return `<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 5v14m-7-7h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg> Add to Watchlist`;
}
function watchlistRemoveLabel() {
  return `<svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg> In Watchlist`;
}

// ---- 7. Watchlist ----------------------------------------------------
function WatchlistScreen() {
  let entries = State.watchlist.slice();

  // Filters
  if (State.watchlistSort !== "all") {
    entries = entries.filter((m) => m.genres.includes(State.watchlistSort));
  }
  if (State.watchlistMood !== "all") {
    entries = entries.filter((m) => (m.moods || []).includes(State.watchlistMood));
  }

  const genresPresent = Array.from(new Set(State.watchlist.slice().flatMap((m) => m.genres))).sort();
  const sortOptions = ['<option value="all">All genres</option>']
    .concat(genresPresent.map((g) => `<option value="${g}" ${State.watchlistSort === g ? "selected" : ""}>${g}</option>`))
    .join("");

  const moods = ["all", "Happy", "Curious", "Emotional", "Lonely", "Motivated", "Stressed"];
  const moodChips = moods.map((m) =>
    `<button class="mood-chip ${State.watchlistMood === m ? "active" : ""}" data-mood="${m}">${m === "all" ? "All moods" : m}</button>`
  ).join("");

  let body;
  if (State.watchlist.length === 0) {
    body = `<div class="empty">
      <div class="empty__art">🍿</div>
      <h3>Your watchlist is empty</h3>
      <p>Save films you love and we'll keep them right here.</p>
      <button class="btn btn--primary" data-route="results">Discover Movies</button>
    </div>`;
  } else if (entries.length === 0) {
    body = `<div class="empty">
      <div class="empty__art">🔍</div>
      <h3>No matches for this filter</h3>
      <p>Try a different genre or mood.</p>
      <button class="btn btn--ghost" data-action="clear-filters">Clear filters</button>
    </div>`;
  } else {
    const cards = entries.map((m) => posterCard({ movie: m, match: matchFor(m) }, { removable: true })).join("");
    body = `<div class="grid-list ${State.watchlistView === "list" ? "list-view" : ""}">${cards}</div>`;
  }

  return `<section class="page container page-pad">
    <div class="page-eyebrow">Your Collection</div>
    <div class="section-head">
      <h1>Watchlist <span style="color:var(--text-dim);font-weight:600;font-size:.6em">${State.watchlist.length}</span></h1>
      <div class="toolbar">
        <select class="select" data-action="sort">${sortOptions}</select>
        <div class="view-toggle">
          <button class="${State.watchlistView === "grid" ? "active" : ""}" data-view="grid" aria-label="Grid view">
            <svg viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.8"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.8"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.8"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.8"/></svg>
          </button>
          <button class="${State.watchlistView === "list" ? "active" : ""}" data-view="list" aria-label="List view">
            <svg viewBox="0 0 24 24" fill="none"><path d="M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
          </button>
        </div>
      </div>
    </div>
    ${State.watchlist.length ? `<div class="mood-chips">${moodChips}</div>` : ""}
    ${body}
  </section>`;
}

// ---- 8. AI Features panel --------------------------------------------
function FeaturesScreen() {
  return `<section class="page container page-pad">
    <div class="page-eyebrow">Powered by AI</div>
    <div class="section-head"><h1>AI Tools</h1></div>
    <div class="feature-grid">

      <div class="feature-card surprise-card">
        <div class="feature-card__icon">🎲</div>
        <h3>Surprise Me</h3>
        <p>One tap. One perfect pick. Let the AI take a leap of faith for you.</p>
        <button class="surprise-btn" data-action="surprise"><span class="ico">✨</span> Reveal My Movie</button>
      </div>

      <div class="feature-card">
        <div class="feature-card__icon">🧠</div>
        <h3>Movie Therapist</h3>
        <p>Tell us how you feel and we'll prescribe exactly the right film.</p>
        <div class="therapist-input">
          <input id="therapistInput" type="text" placeholder="I feel burned out…" aria-label="How do you feel?" />
          <button data-action="therapist" aria-label="Get recommendation">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </button>
        </div>
        <div class="therapist-quick">
          <button data-feeling="I feel burned out">Burned out</button>
          <button data-feeling="I feel heartbroken">Heartbroken</button>
          <button data-feeling="I need motivation">Need motivation</button>
          <button data-feeling="I feel lonely tonight">Lonely</button>
        </div>
        <div class="therapist-response" id="therapistResponse"></div>
      </div>

      <div class="feature-card">
        <div class="feature-card__icon">💑</div>
        <h3>Couple Mode</h3>
        <p>Blend two tastes into one shared watchlist. No more arguing over the remote.</p>
        <div class="avatars">
          <div class="avatar">🧑</div>
          <div class="avatar">👩</div>
          <div class="avatar avatar--plus">+</div>
        </div>
        <button class="btn btn--ghost btn--block" data-action="couple">Start Couple Survey</button>
      </div>

      <div class="feature-card">
        <div class="feature-card__icon">👨‍👩‍👧</div>
        <h3>Family Mode</h3>
        <p>Filter to wholesome, group-friendly picks everyone can enjoy.</p>
        <div class="toggle-row">
          <span>Kid-friendly filter</span>
          <label class="switch"><input type="checkbox" id="familyToggle"><span></span></label>
        </div>
        <button class="btn btn--ghost btn--block" data-action="family">See Family Picks</button>
      </div>

    </div>
  </section>`;
}

// ---- 9. Badges -------------------------------------------------------
function BadgesScreen() {
  const wl = State.watchlist.slice();
  const unlockedCount = BADGES.filter((b) => badgeProgress(b).unlocked).length;
  const genresExplored = new Set(wl.flatMap((m) => m.genres)).size;

  const cards = BADGES.map((b) => {
    const p = badgeProgress(b);
    const ringVal = Math.round((p.count / p.goal) * 100);
    return `<div class="badge-card ${p.unlocked ? "unlocked" : "locked"}">
      ${p.unlocked ? "" : `<span class="lock-ico">🔒</span>`}
      <div class="badge-medal" style="--val:${ringVal}"><span class="emoji">${b.emoji}</span></div>
      <h3>${b.name}</h3>
      <p>${b.desc}</p>
      ${p.unlocked
        ? `<span class="unlocked-pill">Unlocked</span>`
        : `<div class="badge-progress">${p.count} / ${p.goal}</div>`}
    </div>`;
  }).join("");

  return `<section class="page container page-pad">
    <div class="page-eyebrow">Achievements</div>
    <div class="section-head"><h1>Your Badges</h1></div>
    <div class="stat-strip">
      <div class="stat"><b>${unlockedCount}</b><small>Badges unlocked</small></div>
      <div class="stat"><b>${wl.length}</b><small>Films saved</small></div>
      <div class="stat"><b>${genresExplored}</b><small>Genres explored</small></div>
      <div class="stat"><b>${State.profile ? State.profile.score + "%" : "—"}</b><small>Top match</small></div>
    </div>
    <div class="badge-grid">${cards}</div>
  </section>`;
}

// ---- Skeleton (used briefly on results) ------------------------------
function skeletonRow() {
  const cells = Array.from({ length: 5 }).map(() =>
    `<div class="skel-poster skeleton"><div class="a skeleton"></div><div class="b skeleton"></div><div class="c skeleton"></div></div>`
  ).join("");
  return `<div class="row"><div class="row__head"><h3 class="row__title skeleton" style="width:200px;height:24px;border-radius:8px;color:transparent">.</h3></div><div class="carousel">${cells}</div></div>`;
}
