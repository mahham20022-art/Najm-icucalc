/* ============================================================
   CineMind — Data layer
   Movies, survey questions, badges. No network calls: posters are
   rendered as cinematic gradient cards so the app works offline.
   ============================================================ */

// Poster gradients keyed loosely to mood so the collage feels intentional.
const GRADIENTS = {
  noir:      "linear-gradient(160deg,#1b1d2b,#3a2140)",
  ember:     "linear-gradient(160deg,#3a0d12,#7a1d24)",
  ocean:     "linear-gradient(160deg,#0c2a3e,#10516b)",
  violet:    "linear-gradient(160deg,#221446,#5b3bb0)",
  gold:      "linear-gradient(160deg,#3a2c08,#8a6a16)",
  forest:    "linear-gradient(160deg,#0f2a1f,#1f5d40)",
  rose:      "linear-gradient(160deg,#3a1226,#a02d59)",
  steel:     "linear-gradient(160deg,#1a2230,#3c5066)",
  crimson:   "linear-gradient(160deg,#2a060a,#c0111c)",
  cosmos:    "linear-gradient(160deg,#0a0a24,#3a2b8a)",
  sand:      "linear-gradient(160deg,#2e2412,#9c7b2e)",
  ice:       "linear-gradient(160deg,#102530,#347a8c)"
};

// Helper: pick the gradient by index of name so it's deterministic.
function gradFor(key) { return GRADIENTS[key] || GRADIENTS.noir; }

const MOVIES = [
  {
    id: "interstellar", title: "Interstellar", year: 2014, rating: 8.7, runtime: 169,
    grad: "cosmos", genres: ["Sci-Fi", "Drama"], director: "Christopher Nolan",
    cast: ["Matthew McConaughey", "Anne Hathaway", "Jessica Chastain"],
    streaming: ["Prime", "Max"], tone: ["Mind-bending", "Emotional"], moods: ["Curious", "Motivated"],
    categories: ["perfect", "mindblowing", "personality"],
    synopsis: "A team of explorers travel through a wormhole in space in a bid to ensure humanity's survival as Earth becomes uninhabitable.",
    why: "Recommended because you enjoy complex narratives where emotion and big ideas collide."
  },
  {
    id: "arrival", title: "Arrival", year: 2016, rating: 7.9, runtime: 116,
    grad: "ice", genres: ["Sci-Fi", "Mystery", "Drama"], director: "Denis Villeneuve",
    cast: ["Amy Adams", "Jeremy Renner", "Forest Whitaker"],
    streaming: ["Prime", "Hulu"], tone: ["Mind-bending", "Emotional"], moods: ["Curious", "Emotional"],
    categories: ["perfect", "mindblowing", "personality"],
    synopsis: "A linguist is recruited to communicate with extraterrestrial visitors, and her discoveries unravel her perception of time itself.",
    why: "Recommended because you're drawn to cerebral stories with deep emotional undercurrents."
  },
  {
    id: "whiplash", title: "Whiplash", year: 2014, rating: 8.5, runtime: 106,
    grad: "ember", genres: ["Drama", "Thriller"], director: "Damien Chazelle",
    cast: ["Miles Teller", "J.K. Simmons"],
    streaming: ["Netflix", "Prime"], tone: ["Inspirational", "Dark"], moods: ["Motivated", "Stressed"],
    categories: ["perfect", "personality"],
    synopsis: "A promising young drummer enrolls at a cutthroat music conservatory under a teacher who will stop at nothing to realize a student's potential.",
    why: "Recommended because you respond to intense, driven characters chasing greatness."
  },
  {
    id: "her", title: "Her", year: 2013, rating: 8.0, runtime: 126,
    grad: "rose", genres: ["Romance", "Sci-Fi", "Drama"], director: "Spike Jonze",
    cast: ["Joaquin Phoenix", "Scarlett Johansson"],
    streaming: ["Max", "Prime"], tone: ["Emotional", "Mind-bending"], moods: ["Lonely", "Emotional"],
    categories: ["hidden", "comfort", "personality"],
    synopsis: "In a near future, a lonely writer develops an unlikely relationship with an operating system designed to meet his every need.",
    why: "Recommended because you value tender, reflective stories about connection and solitude."
  },
  {
    id: "blade2049", title: "Blade Runner 2049", year: 2017, rating: 8.0, runtime: 164,
    grad: "violet", genres: ["Sci-Fi", "Mystery"], director: "Denis Villeneuve",
    cast: ["Ryan Gosling", "Harrison Ford", "Ana de Armas"],
    streaming: ["Prime", "Max"], tone: ["Mind-bending", "Dark"], moods: ["Curious", "Lonely"],
    categories: ["mindblowing", "hidden"],
    synopsis: "A young blade runner uncovers a long-buried secret that has the potential to plunge what's left of society into chaos.",
    why: "Recommended because you appreciate slow-burn, philosophical world-building."
  },
  {
    id: "parasite", title: "Parasite", year: 2019, rating: 8.5, runtime: 132,
    grad: "forest", genres: ["Thriller", "Drama", "Crime"], director: "Bong Joon-ho",
    cast: ["Song Kang-ho", "Lee Sun-kyun", "Cho Yeo-jeong"],
    streaming: ["Max", "Hulu"], tone: ["Dark", "Mind-bending"], moods: ["Curious", "Stressed"],
    categories: ["perfect", "mindblowing"],
    synopsis: "A poor family schemes to become employed by a wealthy household, infiltrating their lives with unexpected and explosive consequences.",
    why: "Recommended because you love sharp, twist-laden stories with social bite."
  },
  {
    id: "grandbudapest", title: "The Grand Budapest Hotel", year: 2014, rating: 8.1, runtime: 99,
    grad: "rose", genres: ["Comedy", "Drama"], director: "Wes Anderson",
    cast: ["Ralph Fiennes", "Tony Revolori"],
    streaming: ["Disney+", "Prime"], tone: ["Inspirational", "Real-life stories"], moods: ["Happy", "Curious"],
    categories: ["hidden", "comfort"],
    synopsis: "A legendary concierge and his trusted lobby boy become embroiled in the theft of a priceless painting and a battle for a vast fortune.",
    why: "Recommended because you enjoy witty, beautifully crafted comfort cinema."
  },
  {
    id: "everything", title: "Everything Everywhere All at Once", year: 2022, rating: 7.8, runtime: 139,
    grad: "cosmos", genres: ["Sci-Fi", "Comedy", "Drama"], director: "Daniels",
    cast: ["Michelle Yeoh", "Ke Huy Quan", "Stephanie Hsu"],
    streaming: ["Prime", "Hulu"], tone: ["Mind-bending", "Emotional", "Inspirational"], moods: ["Stressed", "Emotional"],
    categories: ["perfect", "mindblowing", "personality"],
    synopsis: "An exhausted laundromat owner discovers she must connect with parallel-universe versions of herself to save existence.",
    why: "Recommended because you crave chaotic, heartfelt stories that find meaning in the messy."
  },
  {
    id: "prestige", title: "The Prestige", year: 2006, rating: 8.5, runtime: 130,
    grad: "noir", genres: ["Mystery", "Drama", "Thriller"], director: "Christopher Nolan",
    cast: ["Hugh Jackman", "Christian Bale", "Scarlett Johansson"],
    streaming: ["Netflix", "Prime"], tone: ["Mind-bending", "Dark"], moods: ["Curious", "Stressed"],
    categories: ["hidden", "mindblowing"],
    synopsis: "Two rival magicians engage in a bitter battle of one-upmanship that turns increasingly dangerous and obsessive.",
    why: "Recommended because you love puzzles that reward your attention with a gut-punch reveal."
  },
  {
    id: "soul", title: "Soul", year: 2020, rating: 8.0, runtime: 100,
    grad: "ocean", genres: ["Fantasy", "Comedy", "Drama"], director: "Pete Docter",
    cast: ["Jamie Foxx", "Tina Fey"],
    streaming: ["Disney+"], tone: ["Emotional", "Inspirational"], moods: ["Lonely", "Motivated"],
    categories: ["comfort", "personality"],
    synopsis: "A jazz musician on the cusp of his big break takes an unexpected detour through the realm where souls find their spark.",
    why: "Recommended because you find comfort in warm, life-affirming stories about purpose."
  },
  {
    id: "shawshank", title: "The Shawshank Redemption", year: 1994, rating: 9.3, runtime: 142,
    grad: "gold", genres: ["Drama", "Crime"], director: "Frank Darabont",
    cast: ["Tim Robbins", "Morgan Freeman"],
    streaming: ["Max", "Prime"], tone: ["Inspirational", "Emotional", "Real-life stories"], moods: ["Motivated", "Lonely"],
    categories: ["comfort", "personality"],
    synopsis: "Over decades behind bars, a banker convicted of murder forms a profound friendship and quietly holds on to hope.",
    why: "Recommended because you're moved by patient stories of resilience and hope."
  },
  {
    id: "knives", title: "Knives Out", year: 2019, rating: 7.9, runtime: 130,
    grad: "ember", genres: ["Mystery", "Comedy", "Crime"], director: "Rian Johnson",
    cast: ["Daniel Craig", "Ana de Armas", "Chris Evans"],
    streaming: ["Prime", "Netflix"], tone: ["Real-life stories", "Inspirational"], moods: ["Happy", "Curious"],
    categories: ["comfort", "hidden"],
    synopsis: "A master detective untangles a web of lies and self-serving relatives after a wealthy novelist is found dead.",
    why: "Recommended because you enjoy clever, playful whodunits that keep you guessing."
  },
  {
    id: "darkknight", title: "The Dark Knight", year: 2008, rating: 9.0, runtime: 152,
    grad: "noir", genres: ["Crime", "Thriller", "Drama"], director: "Christopher Nolan",
    cast: ["Christian Bale", "Heath Ledger", "Aaron Eckhart"],
    streaming: ["Max", "Prime"], tone: ["Dark", "Action-packed"], moods: ["Motivated", "Stressed"],
    categories: ["perfect", "personality"],
    synopsis: "When a chaos-loving criminal mastermind emerges, Gotham's protector is pushed to the edge of his moral code.",
    why: "Recommended because you're hooked by morally complex heroes under relentless pressure."
  },
  {
    id: "lalaland", title: "La La Land", year: 2016, rating: 8.0, runtime: 128,
    grad: "rose", genres: ["Romance", "Drama", "Comedy"], director: "Damien Chazelle",
    cast: ["Ryan Gosling", "Emma Stone"],
    streaming: ["Prime", "Hulu"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"],
    categories: ["comfort", "hidden"],
    synopsis: "A jazz pianist and an aspiring actress fall in love while chasing their dreams in modern-day Los Angeles.",
    why: "Recommended because you love bittersweet, beautifully scored romances."
  },
  {
    id: "duneone", title: "Dune", year: 2021, rating: 8.0, runtime: 155,
    grad: "sand", genres: ["Sci-Fi", "Drama"], director: "Denis Villeneuve",
    cast: ["Timothée Chalamet", "Rebecca Ferguson", "Zendaya"],
    streaming: ["Max"], tone: ["Mind-bending", "Action-packed"], moods: ["Curious", "Motivated"],
    categories: ["perfect", "personality"],
    synopsis: "A gifted young heir must travel to the most dangerous planet in the universe to secure the future of his family and his people.",
    why: "Recommended because you're captivated by epic, immersive worlds with mythic stakes."
  },
  {
    id: "spirited", title: "Spirited Away", year: 2001, rating: 8.6, runtime: 125,
    grad: "forest", genres: ["Fantasy", "Drama"], director: "Hayao Miyazaki",
    cast: ["Rumi Hiiragi", "Miyu Irino"],
    streaming: ["Max"], tone: ["Emotional", "Inspirational"], moods: ["Curious", "Lonely"],
    categories: ["comfort", "hidden", "personality"],
    synopsis: "A young girl wanders into a spirit world and must find the courage to free her parents and herself.",
    why: "Recommended because you treasure imaginative, soulful journeys about growing up."
  },
  {
    id: "socialnetwork", title: "The Social Network", year: 2010, rating: 7.8, runtime: 120,
    grad: "steel", genres: ["Drama", "History"], director: "David Fincher",
    cast: ["Jesse Eisenberg", "Andrew Garfield"],
    streaming: ["Netflix", "Prime"], tone: ["Real-life stories", "Dark"], moods: ["Motivated", "Curious"],
    categories: ["hidden", "personality"],
    synopsis: "The story of how a Harvard student built a social network that reshaped the world, and the relationships it cost him.",
    why: "Recommended because you're fascinated by ambition, genius, and its human price."
  },
  {
    id: "12angry", title: "12 Angry Men", year: 1957, rating: 9.0, runtime: 96,
    grad: "steel", genres: ["Drama", "Crime"], director: "Sidney Lumet",
    cast: ["Henry Fonda", "Lee J. Cobb"],
    streaming: ["Prime"], tone: ["Real-life stories", "Inspirational"], moods: ["Curious", "Motivated"],
    categories: ["hidden", "mindblowing"],
    synopsis: "A lone juror challenges his peers to reconsider the evidence before condemning a young man to death.",
    why: "Recommended because you value tight, principled stories driven by ideas over spectacle."
  },
  {
    id: "spiderverse", title: "Spider-Man: Into the Spider-Verse", year: 2018, rating: 8.4, runtime: 117,
    grad: "violet", genres: ["Fantasy", "Comedy", "Sci-Fi"], director: "Persichetti, Ramsey & Rothman",
    cast: ["Shameik Moore", "Jake Johnson", "Hailee Steinfeld"],
    streaming: ["Netflix", "Prime"], tone: ["Inspirational", "Action-packed"], moods: ["Happy", "Motivated"],
    categories: ["comfort", "perfect"],
    synopsis: "A Brooklyn teen joins a band of heroes from across the multiverse to stop a threat to all realities.",
    why: "Recommended because you love bold, joyful stories about finding your own way."
  },
  {
    id: "nomadland", title: "Nomadland", year: 2020, rating: 7.3, runtime: 107,
    grad: "sand", genres: ["Drama", "Documentary"], director: "Chloé Zhao",
    cast: ["Frances McDormand", "David Strathairn"],
    streaming: ["Hulu", "Disney+"], tone: ["Real-life stories", "Emotional"], moods: ["Lonely", "Emotional"],
    categories: ["hidden", "personality"],
    synopsis: "After losing everything in the Great Recession, a woman embarks on a journey through the American West living as a modern-day nomad.",
    why: "Recommended because you connect with quiet, observational stories about real lives."
  },
  {
    id: "oldboy", title: "Oldboy", year: 2003, rating: 8.3, runtime: 120,
    grad: "crimson", genres: ["Thriller", "Mystery", "Crime"], director: "Park Chan-wook",
    cast: ["Choi Min-sik", "Yoo Ji-tae"],
    streaming: ["Prime"], tone: ["Dark", "Mind-bending"], moods: ["Stressed", "Curious"],
    categories: ["mindblowing", "hidden"],
    synopsis: "Imprisoned for fifteen years without explanation, a man is suddenly released and given five days to uncover the truth.",
    why: "Recommended because you can handle dark, audacious stories with devastating twists."
  },
  {
    id: "amelie", title: "Amélie", year: 2001, rating: 8.3, runtime: 122,
    grad: "gold", genres: ["Romance", "Comedy"], director: "Jean-Pierre Jeunet",
    cast: ["Audrey Tautou", "Mathieu Kassovitz"],
    streaming: ["Max", "Prime"], tone: ["Emotional", "Inspirational"], moods: ["Happy", "Lonely"],
    categories: ["comfort", "hidden"],
    synopsis: "A shy Parisian waitress decides to quietly change the lives of those around her for the better, while struggling with her own isolation.",
    why: "Recommended because you adore whimsical, warm-hearted stories that make the small things magic."
  },
  {
    id: "fightclub", title: "Fight Club", year: 1999, rating: 8.8, runtime: 139,
    grad: "noir", genres: ["Drama", "Thriller"], director: "David Fincher",
    cast: ["Brad Pitt", "Edward Norton", "Helena Bonham Carter"],
    streaming: ["Prime", "Hulu"], tone: ["Dark", "Mind-bending"], moods: ["Stressed", "Motivated"],
    categories: ["mindblowing", "personality"],
    synopsis: "An insomniac office worker and a soap maker form an underground club that spirals into something far larger and darker.",
    why: "Recommended because you're drawn to provocative stories that question everything."
  },
  {
    id: "coco", title: "Coco", year: 2017, rating: 8.4, runtime: 105,
    grad: "ember", genres: ["Fantasy", "Comedy", "Drama"], director: "Lee Unkrich",
    cast: ["Anthony Gonzalez", "Gael García Bernal"],
    streaming: ["Disney+"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"],
    categories: ["comfort", "personality"],
    synopsis: "A music-loving boy is transported to the Land of the Dead, where he seeks the truth about his family's history.",
    why: "Recommended because you cherish heartfelt stories about family, memory, and dreams."
  },
  { id: "matrix", title: "The Matrix", year: 1999, rating: 8.7, runtime: 136, grad: "forest", genres: ["Sci-Fi", "Action"], director: "The Wachowskis", cast: ["Keanu Reeves", "Laurence Fishburne", "Carrie-Anne Moss"], streaming: ["Max"], tone: ["Mind-bending", "Action-packed"], moods: ["Curious", "Motivated"], categories: ["perfect", "mindblowing"], synopsis: "A hacker discovers reality is a simulation and joins a rebellion against the machines that built it.", why: "Recommended because you love reality-bending action with big ideas." },
  { id: "inception", title: "Inception", year: 2010, rating: 8.8, runtime: 148, grad: "steel", genres: ["Sci-Fi", "Thriller", "Action"], director: "Christopher Nolan", cast: ["Leonardo DiCaprio", "Joseph Gordon-Levitt", "Elliot Page"], streaming: ["Max", "Prime"], tone: ["Mind-bending", "Action-packed"], moods: ["Curious", "Stressed"], categories: ["perfect", "mindblowing"], synopsis: "A thief who steals secrets through dream-sharing is offered a chance to plant an idea instead.", why: "Recommended because you love layered puzzles that reward your full attention." },
  { id: "pulpfiction", title: "Pulp Fiction", year: 1994, rating: 8.9, runtime: 154, grad: "crimson", genres: ["Crime", "Drama"], director: "Quentin Tarantino", cast: ["John Travolta", "Samuel L. Jackson", "Uma Thurman"], streaming: ["Prime"], tone: ["Dark", "Real-life stories"], moods: ["Curious", "Stressed"], categories: ["mindblowing", "hidden"], synopsis: "The lives of two hit men, a boxer and a gangster's wife interweave in four tales of violence and redemption.", why: "Recommended because you love bold, non-linear storytelling with sharp dialogue." },
  { id: "godfather", title: "The Godfather", year: 1972, rating: 9.2, runtime: 175, grad: "noir", genres: ["Crime", "Drama"], director: "Francis Ford Coppola", cast: ["Marlon Brando", "Al Pacino", "James Caan"], streaming: ["Prime"], tone: ["Dark", "Real-life stories"], moods: ["Motivated", "Stressed"], categories: ["perfect", "personality"], synopsis: "The aging patriarch of a crime dynasty transfers control to his reluctant son.", why: "Recommended because you value epic, morally complex family sagas." },
  { id: "goodfellas", title: "Goodfellas", year: 1990, rating: 8.7, runtime: 145, grad: "ember", genres: ["Crime", "Drama"], director: "Martin Scorsese", cast: ["Robert De Niro", "Ray Liotta", "Joe Pesci"], streaming: ["Max"], tone: ["Dark", "Real-life stories"], moods: ["Motivated", "Stressed"], categories: ["hidden", "personality"], synopsis: "The rise and fall of a mob associate across three decades of life in the mafia.", why: "Recommended because you're drawn to propulsive, real-feeling crime epics." },
  { id: "se7en", title: "Se7en", year: 1995, rating: 8.6, runtime: 127, grad: "noir", genres: ["Crime", "Thriller", "Mystery"], director: "David Fincher", cast: ["Brad Pitt", "Morgan Freeman", "Kevin Spacey"], streaming: ["Prime"], tone: ["Dark", "Mind-bending"], moods: ["Stressed", "Curious"], categories: ["mindblowing", "hidden"], synopsis: "Two detectives hunt a serial killer who uses the seven deadly sins as his motif.", why: "Recommended because you can handle dark, meticulous thrillers with a gut-punch." },
  { id: "gladiator", title: "Gladiator", year: 2000, rating: 8.5, runtime: 155, grad: "sand", genres: ["Action", "Drama", "History"], director: "Ridley Scott", cast: ["Russell Crowe", "Joaquin Phoenix"], streaming: ["Prime", "Netflix"], tone: ["Action-packed", "Inspirational"], moods: ["Motivated"], categories: ["perfect", "personality"], synopsis: "A betrayed Roman general rises from slavery as a gladiator to avenge his family.", why: "Recommended because you love epic tales of honor and vengeance." },
  { id: "forrestgump", title: "Forrest Gump", year: 1994, rating: 8.8, runtime: 142, grad: "gold", genres: ["Drama", "Romance"], director: "Robert Zemeckis", cast: ["Tom Hanks", "Robin Wright"], streaming: ["Prime"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"], categories: ["comfort", "personality"], synopsis: "A kind-hearted man with a low IQ inadvertently shapes decades of American history.", why: "Recommended because you love big-hearted, life-spanning journeys." },
  { id: "greenmile", title: "The Green Mile", year: 1999, rating: 8.6, runtime: 189, grad: "forest", genres: ["Drama", "Crime", "Fantasy"], director: "Frank Darabont", cast: ["Tom Hanks", "Michael Clarke Duncan"], streaming: ["Max"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Lonely"], categories: ["comfort", "hidden"], synopsis: "Death-row guards encounter a gentle giant with a miraculous gift.", why: "Recommended because you're moved by tender stories about humanity and grace." },
  { id: "joker", title: "Joker", year: 2019, rating: 8.4, runtime: 122, grad: "crimson", genres: ["Crime", "Drama", "Thriller"], director: "Todd Phillips", cast: ["Joaquin Phoenix"], streaming: ["Max"], tone: ["Dark", "Emotional"], moods: ["Lonely", "Stressed"], categories: ["mindblowing", "hidden"], synopsis: "A failed comedian's descent into madness mirrors a city on the brink.", why: "Recommended because you're drawn to raw, unsettling character studies." },
  { id: "madmax", title: "Mad Max: Fury Road", year: 2015, rating: 8.1, runtime: 120, grad: "sand", genres: ["Action", "Sci-Fi", "Adventure"], director: "George Miller", cast: ["Tom Hardy", "Charlize Theron"], streaming: ["Max"], tone: ["Action-packed"], moods: ["Motivated", "Stressed"], categories: ["perfect", "hidden"], synopsis: "On a post-apocalyptic desert, a drifter and a rebel warrior flee a tyrant in a relentless chase.", why: "Recommended because you love kinetic, non-stop practical action." },
  { id: "lotr", title: "The Lord of the Rings: The Fellowship of the Ring", year: 2001, rating: 8.9, runtime: 178, grad: "forest", genres: ["Fantasy", "Adventure", "Drama"], director: "Peter Jackson", cast: ["Elijah Wood", "Ian McKellen", "Viggo Mortensen"], streaming: ["Max"], tone: ["Action-packed", "Inspirational"], moods: ["Curious", "Motivated"], categories: ["perfect", "personality"], synopsis: "A hobbit inherits a perilous ring and sets out with a fellowship to destroy it.", why: "Recommended because you love immersive, mythic adventures." },
  { id: "spirited2", title: "Whisper of the Heart", year: 1995, rating: 7.9, runtime: 111, grad: "rose", genres: ["Romance", "Drama", "Fantasy"], director: "Yoshifumi Kondō", cast: ["Yoko Honna"], streaming: ["Max"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"], categories: ["comfort", "hidden"], synopsis: "A bookish teen chases her creative dreams during one transformative summer.", why: "Recommended because you love gentle coming-of-age stories about finding your voice." },
  { id: "wall-e", title: "WALL·E", year: 2008, rating: 8.4, runtime: 98, grad: "ice", genres: ["Sci-Fi", "Family", "Adventure"], director: "Andrew Stanton", cast: ["Ben Burtt", "Elissa Knight"], streaming: ["Disney+"], tone: ["Emotional", "Inspirational"], moods: ["Lonely", "Happy"], categories: ["comfort", "personality"], synopsis: "A lonely waste-collecting robot embarks on a journey that decides humanity's future.", why: "Recommended because you love warm, wondrous stories with heart." },
  { id: "insideout", title: "Inside Out", year: 2015, rating: 8.1, runtime: 95, grad: "violet", genres: ["Family", "Comedy", "Drama"], director: "Pete Docter", cast: ["Amy Poehler", "Phyllis Smith"], streaming: ["Disney+"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"], categories: ["comfort", "personality"], synopsis: "Inside a young girl's mind, five emotions navigate a life-changing move.", why: "Recommended because you love clever, deeply feeling stories about growing up." },
  { id: "truman", title: "The Truman Show", year: 1998, rating: 8.2, runtime: 103, grad: "ocean", genres: ["Drama", "Comedy", "Sci-Fi"], director: "Peter Weir", cast: ["Jim Carrey", "Ed Harris"], streaming: ["Prime"], tone: ["Mind-bending", "Emotional"], moods: ["Curious", "Lonely"], categories: ["hidden", "mindblowing"], synopsis: "A man slowly realizes his entire life is a televised reality show.", why: "Recommended because you love thought-provoking premises with real emotion." },
  { id: "eternal", title: "Eternal Sunshine of the Spotless Mind", year: 2004, rating: 8.3, runtime: 108, grad: "ice", genres: ["Romance", "Sci-Fi", "Drama"], director: "Michel Gondry", cast: ["Jim Carrey", "Kate Winslet"], streaming: ["Max"], tone: ["Emotional", "Mind-bending"], moods: ["Lonely", "Emotional"], categories: ["hidden", "mindblowing"], synopsis: "A couple erase each other from their memories, only to rediscover what they lost.", why: "Recommended because you love inventive, aching love stories." },
  { id: "beautifulmind", title: "A Beautiful Mind", year: 2001, rating: 8.2, runtime: 135, grad: "steel", genres: ["Drama", "History"], director: "Ron Howard", cast: ["Russell Crowe", "Jennifer Connelly"], streaming: ["Prime"], tone: ["Emotional", "Real-life stories"], moods: ["Motivated", "Emotional"], categories: ["hidden", "personality"], synopsis: "A brilliant mathematician battles schizophrenia on his path to a Nobel Prize.", why: "Recommended because you're inspired by true stories of the mind and resilience." },
  { id: "slumdog", title: "Slumdog Millionaire", year: 2008, rating: 8.0, runtime: 120, grad: "gold", genres: ["Drama", "Romance"], director: "Danny Boyle", cast: ["Dev Patel", "Freida Pinto"], streaming: ["Prime"], tone: ["Inspirational", "Emotional"], moods: ["Motivated", "Emotional"], categories: ["comfort", "hidden"], synopsis: "A Mumbai teen recounts his life to explain how he knows the answers on a quiz show.", why: "Recommended because you love uplifting, against-the-odds journeys." },
  { id: "departed", title: "The Departed", year: 2006, rating: 8.5, runtime: 151, grad: "noir", genres: ["Crime", "Thriller", "Drama"], director: "Martin Scorsese", cast: ["Leonardo DiCaprio", "Matt Damon", "Jack Nicholson"], streaming: ["Max"], tone: ["Dark", "Action-packed"], moods: ["Stressed", "Motivated"], categories: ["hidden", "mindblowing"], synopsis: "An undercover cop and a mole in the police race to identify each other.", why: "Recommended because you love tense, twisty crime thrillers." },
  { id: "nocountry", title: "No Country for Old Men", year: 2007, rating: 8.2, runtime: 122, grad: "sand", genres: ["Crime", "Thriller", "Drama"], director: "Joel & Ethan Coen", cast: ["Javier Bardem", "Josh Brolin", "Tommy Lee Jones"], streaming: ["Prime"], tone: ["Dark", "Mind-bending"], moods: ["Stressed", "Curious"], categories: ["mindblowing", "hidden"], synopsis: "A hunter's discovery of drug-deal cash unleashes a relentless killer.", why: "Recommended because you love bleak, masterfully tense thrillers." },
  { id: "gonegirl", title: "Gone Girl", year: 2014, rating: 8.1, runtime: 149, grad: "steel", genres: ["Thriller", "Mystery", "Drama"], director: "David Fincher", cast: ["Ben Affleck", "Rosamund Pike"], streaming: ["Max"], tone: ["Dark", "Mind-bending"], moods: ["Stressed", "Curious"], categories: ["mindblowing", "hidden"], synopsis: "A man becomes the prime suspect when his wife disappears on their anniversary.", why: "Recommended because you love razor-sharp, twist-filled mysteries." },
  { id: "martian", title: "The Martian", year: 2015, rating: 8.0, runtime: 144, grad: "crimson", genres: ["Sci-Fi", "Adventure", "Drama"], director: "Ridley Scott", cast: ["Matt Damon", "Jessica Chastain"], streaming: ["Disney+"], tone: ["Inspirational", "Mind-bending"], moods: ["Motivated", "Curious"], categories: ["comfort", "personality"], synopsis: "Stranded alone on Mars, an astronaut must science his way to survival.", why: "Recommended because you love smart, optimistic survival stories." },
  { id: "gravity", title: "Gravity", year: 2013, rating: 7.7, runtime: 91, grad: "cosmos", genres: ["Sci-Fi", "Thriller", "Drama"], director: "Alfonso Cuarón", cast: ["Sandra Bullock", "George Clooney"], streaming: ["Max"], tone: ["Action-packed", "Emotional"], moods: ["Stressed", "Lonely"], categories: ["hidden"], synopsis: "After debris destroys their shuttle, an astronaut fights to survive the void of space.", why: "Recommended because you love breathless, immersive survival tension." },
  { id: "lion-king", title: "The Lion King", year: 1994, rating: 8.5, runtime: 88, grad: "gold", genres: ["Family", "Drama", "Adventure"], director: "Roger Allers", cast: ["Matthew Broderick", "James Earl Jones"], streaming: ["Disney+"], tone: ["Emotional", "Inspirational"], moods: ["Emotional", "Happy"], categories: ["comfort", "personality"], synopsis: "A young lion prince flees his kingdom after his father's death, only to reclaim his destiny.", why: "Recommended because you love timeless, sweeping coming-of-age tales." },
  { id: "johnwick", title: "John Wick", year: 2014, rating: 7.4, runtime: 101, grad: "noir", genres: ["Action", "Thriller", "Crime"], director: "Chad Stahelski", cast: ["Keanu Reeves"], streaming: ["Peacock", "Prime"], tone: ["Action-packed", "Dark"], moods: ["Motivated", "Stressed"], categories: ["hidden"], synopsis: "A retired hitman is pulled back into the underworld to avenge a personal loss.", why: "Recommended because you love stylish, relentless action." }
];

// ---- Survey questions ------------------------------------------------
const QUESTIONS = [
  {
    id: "mood", type: "single", eyebrow: "Step 1 · Mood",
    q: "How are you feeling today?",
    hint: "Your mood shapes the emotional tone we'll match.",
    layout: "pills",
    options: [
      { v: "Happy", emoji: "😊" }, { v: "Curious", emoji: "🤔" },
      { v: "Emotional", emoji: "🥹" }, { v: "Lonely", emoji: "🌙" },
      { v: "Motivated", emoji: "🔥" }, { v: "Stressed", emoji: "😮‍💨" }
    ]
  },
  {
    id: "story", type: "single", eyebrow: "Step 2 · Story",
    q: "Which stories attract you most?",
    hint: "We'll prioritize narratives that resonate with you.",
    options: [
      { v: "Mind-bending", emoji: "🧠" }, { v: "Emotional", emoji: "💔" },
      { v: "Inspirational", emoji: "✨" }, { v: "Action-packed", emoji: "💥" },
      { v: "Dark", emoji: "🌑" }, { v: "Real-life stories", emoji: "🎬" }
    ]
  },
  {
    id: "pace", type: "single", eyebrow: "Step 3 · Pacing",
    q: "Preferred pacing",
    hint: "From meditative slow-burns to relentless intensity.",
    layout: "pills",
    options: [
      { v: "Slow and deep", emoji: "🌊" },
      { v: "Balanced", emoji: "⚖️" },
      { v: "Fast and intense", emoji: "⚡" }
    ]
  },
  {
    id: "character", type: "single", eyebrow: "Step 4 · Character",
    q: "Which character do you relate to?",
    hint: "The lens you watch through tells us a lot.",
    options: [
      { v: "The Dreamer", emoji: "💭" }, { v: "The Leader", emoji: "👑" },
      { v: "The Outsider", emoji: "🧩" }, { v: "The Rebel", emoji: "🔥" },
      { v: "The Thinker", emoji: "📚" }, { v: "The Explorer", emoji: "🧭" }
    ]
  },
  {
    id: "lifestyle", type: "single", eyebrow: "Step 5 · Lifestyle",
    q: "Your ideal weekend activity?",
    hint: "Tastes off-screen hint at tastes on-screen.",
    options: [
      { v: "Reading", emoji: "📖" }, { v: "Gaming", emoji: "🎮" },
      { v: "Traveling", emoji: "✈️" }, { v: "Sports", emoji: "⚽" },
      { v: "Family time", emoji: "🏡" }, { v: "Learning", emoji: "🔬" }
    ]
  },
  {
    id: "genres", type: "multi", eyebrow: "Step 6 · Genres",
    q: "Pick your favorite genres",
    hint: "Select as many as you like — multi-select.",
    options: [
      { v: "Sci-Fi", emoji: "🚀" }, { v: "Drama", emoji: "🎭" },
      { v: "Thriller", emoji: "🔪" }, { v: "Mystery", emoji: "🕵️" },
      { v: "Crime", emoji: "🚔" }, { v: "Fantasy", emoji: "🐉" },
      { v: "Documentary", emoji: "📹" }, { v: "Comedy", emoji: "😂" },
      { v: "Romance", emoji: "💕" }, { v: "History", emoji: "🏛️" }
    ]
  }
];

// ---- Personality archetypes (derived from answers) -------------------
const ARCHETYPES = {
  "The Thinker": {
    summary: "You are a highly curious and reflective person who enjoys intelligent storytelling, emotional depth, and morally complex characters. You'd rather be left thinking long after the credits roll.",
    tags: ["Analytical", "Reflective", "Curious", "Cerebral"]
  },
  "The Dreamer": {
    summary: "You're an imaginative, emotionally open soul who gravitates toward beauty, wonder, and stories that make you feel deeply. Magic and meaning matter more to you than spectacle.",
    tags: ["Creative", "Empathetic", "Imaginative", "Romantic"]
  },
  "The Explorer": {
    summary: "You crave bold worlds and big adventures. You love being transported somewhere new, with a strong appetite for epic scope and the thrill of the unknown.",
    tags: ["Adventurous", "Open-minded", "Bold", "Restless"]
  },
  "The Rebel": {
    summary: "You're drawn to the provocative and the unconventional. Stories that challenge norms, subvert expectations, and refuse easy answers are exactly your kind of dangerous.",
    tags: ["Provocative", "Independent", "Intense", "Fearless"]
  },
  "The Leader": {
    summary: "You connect with drive, ambition, and characters under pressure. You admire excellence and grit, and you're energized by stories of people who refuse to lose.",
    tags: ["Driven", "Decisive", "Resilient", "Ambitious"]
  },
  "The Outsider": {
    summary: "You feel for the overlooked and the in-between. Quiet, observational stories about identity, belonging, and solitude speak to you more than any blockbuster.",
    tags: ["Observant", "Sensitive", "Authentic", "Introspective"]
  }
};

// ---- Badges ----------------------------------------------------------
const BADGES = [
  { id: "scifi", name: "Sci-Fi Master", emoji: "🚀", desc: "Add 3 sci-fi films to your watchlist.", goal: 3, genre: "Sci-Fi" },
  { id: "doc", name: "Documentary Explorer", emoji: "📹", desc: "Discover 2 documentaries.", goal: 2, genre: "Documentary" },
  { id: "thriller", name: "Thriller Hunter", emoji: "🔪", desc: "Track down 3 thrillers.", goal: 3, genre: "Thriller" },
  { id: "philosopher", name: "Cinema Philosopher", emoji: "🧠", desc: "Save 4 mind-bending films.", goal: 4, category: "mindblowing" },
  { id: "romantic", name: "Hopeless Romantic", emoji: "💕", desc: "Collect 2 romances.", goal: 2, genre: "Romance" },
  { id: "curator", name: "Master Curator", emoji: "🏆", desc: "Build a watchlist of 6 titles.", goal: 6, any: true }
];

const ROW_DEFS = [
  { key: "perfect", title: "Perfect Matches", hint: "Top AI picks for you" },
  { key: "hidden", title: "Hidden Gems", hint: "Underrated masterpieces" },
  { key: "comfort", title: "Comfort Watches", hint: "Feel-good content" },
  { key: "mindblowing", title: "Mind-Blowing Stories", hint: "Psychological & philosophical" },
  { key: "personality", title: "Based on Your Personality", hint: "Custom AI recommendations" }
];

const STREAM_COLORS = {
  Netflix: "#E50914", Prime: "#00A8E1", Max: "#7B2FF7",
  Hulu: "#1CE783", "Disney+": "#113CCF"
};
