# Security Rules Tests

Tests `../firestore.rules` and `../storage.rules` against the Firebase
Emulator Suite using `@firebase/rules-unit-testing`. Never touches
production — `demo-med100` (see `../.firebaserc`) is a `demo-*` project
id, which the emulator and this package both treat as local-only.

## Running

From the repo root (requires the Firebase CLI — `npm install -g
firebase-tools` — and a JDK, since the Firestore/Storage emulators run on
the JVM):

```sh
firebase emulators:exec --project demo-med100 "cd firebase-rules-tests && npm test"
```

`emulators:exec` starts the Firestore and Storage emulators (ports fixed
in `../firebase.json`), runs the test command with the
`FIRESTORE_EMULATOR_HOST`/`FIREBASE_STORAGE_EMULATOR_HOST` environment
variables set (which `initializeTestEnvironment` auto-discovers), then
shuts the emulators down — regardless of whether the tests pass or fail.

First run downloads the emulator JARs (cached under `~/.cache/firebase`
afterwards), so it's slower than subsequent runs.

## Coverage

`firestore.rules.test.mjs` covers, per collection family: owner
read/write, cross-user denial, staff (`admin`/`editor` custom claim)
read access, the signup-time field-injection guards on `users/{userId}`,
append-only collections (`teachingSessions`, `quizAttempts`) rejecting
edits after creation, server-computed collections
(`progress`/`streaks`/`mastery`) being read-only even to their owner,
public content being world-readable but never client-writable, the
answer-key collection (`mcqAnswers`) being unreadable by anyone, and the
default-deny catch-all closing an arbitrary unmatched collection.

`storage.rules.test.mjs` covers the note-image path's ownership, content-
type allowlist, and size cap; the premium-content path being unreachable
without a signed URL; and the default-deny catch-all.
