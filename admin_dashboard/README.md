# Med100 Admin Dashboard

Internal staff tool (Flutter Web) for managing Med100's users, content, and
subscriptions — not the consumer-facing app (that's `../app_mobile`).

**Read before pointing this at a real project:** `MED100_ARCHITECTURE.md` §12
made a firm decision that internal admin/editorial tooling should run as a
separate app in its **own** dedicated Firebase project, isolated from the
higher-exposure consumer app, specifically so a consumer-app compromise can
never cascade into admin/content-publishing access. This app was built
instead sharing the *same* Firebase project as `app_mobile`, per this
feature's explicit build instruction — see `lib/firebase_options.dart`'s doc
comment for the full trade-off and what it depends on (Firestore Security
Rules independently enforcing the `admin`/`editor` claim check, since the
client-side check in `core/session`-equivalent code here is a UX convenience
only, never the real security boundary).

## Scope (this pass)

Built "shell first, then deepen": every one of the nine sections below has a
real route and a real nav destination; **Users** and **Analytics** are wired
to real Firestore reads/writes, the rest render `PlaceholderScreen` until a
later pass gives them their own data layer.

- **Manage:** Users (real), Topics, Learning Paths, Notifications,
  Subscriptions
- **Insights:** Analytics (real), Revenue
- **Content & Engagement:** Medical Content, Push Notifications

### Users

Lists `users/{userId}` (paginated, email-prefix search — no full-text
search), joined with `subscriptions/{userId}` for plan display. Suspend/
reactivate writes `accountStatus` directly (a plain Firestore field, gated by
Security Rules on the caller's own `admin` claim). Changing a user's `role`
calls an `adminSetUserRole` Cloud Functions callable that **does not exist
server-side yet** — role is also a Firebase Auth custom claim, which only the
Admin SDK can set, never a client directly; this is a loud, deliberate
foundation-stage gap, not a bug.

### Analytics

Real counts via Firestore `.count()` aggregation queries (total/suspended
users, premium users, topics, learning paths) — no Cloud Function or
BigQuery export needed for these. This is the honest ceiling of a
client-side dashboard: simple counts, not the trends/cohorts/funnels the
architecture doc's eventual BigQuery-backed reporting would provide.

## Getting started

```bash
flutter pub get
flutter run -d chrome
```

### Firebase

`lib/firebase_options.dart` is a **placeholder** — every Auth/Firestore/
Functions call in this app is a no-op until a real project replaces it:

```bash
flutterfire configure
```

Sign-in requires an existing Firebase Auth account whose `role` custom claim
is `admin` or `editor` (`MED100_ARCHITECTURE.md` §7) — a real `learner`
account is correctly turned away at `/not-authorized`.
