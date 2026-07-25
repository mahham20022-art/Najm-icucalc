# Play Store release checklist

Step-by-step to get Najm ICUCalc live on Google Play. Do these once, in order.

---

## 0. Prerequisites (once)

- Google **Play Console** developer account: **$25 one-time** at
  <https://play.google.com/console/signup>. Individual account works.
- A **Firebase project** (free): <https://console.firebase.google.com>
- Flutter SDK 3.19+, JDK 17

---

## 1. Attach Firebase

```bash
cd flutter_app
firebase login
flutterfire configure --project=<your-project-id>
```

- Choose Android + iOS platforms.
- The CLI writes `lib/firebase_options.dart`, drops
  `android/app/google-services.json`, and (macOS) the iOS plist.
- Commit `google-services.json` — it's a client-side identifier, not a secret.

**Enable in Firebase console:**
- Analytics (auto)
- Crashlytics (Dashboard → Crashlytics → *Enable*)
- Remote Config (Dashboard → Remote Config → create empty template)

---

## 2. Generate the signing keystore (once, keep forever)

```bash
keytool -genkey -v -keystore najm-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the `.jks` file **outside the repo** and back it up. If lost, you
lose the ability to publish updates under the same package name.

Create `android/key.properties` (git-ignored):

```
storePassword=<...>
keyPassword=<...>
keyAlias=upload
storeFile=/absolute/path/to/najm-upload-keystore.jks
```

---

## 3. Build the release bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.
For internal test tracks and side-loading:

```bash
flutter build apk --release --split-per-abi
```

---

## 4. Play Console — create the app

1. **Create app** → App name: *Najm ICUCalc* · Default language: English (US) ·
   App or game: **App** · Free or paid: **Free** → confirm declarations.
2. **Set up your app** panel — complete every card:
   - **Privacy policy URL**:
     `https://mahham20022-art.github.io/Najm-icucalc/privacy-policy.html`
     (or your own hosted URL for the file at repo root)
   - **App access**: All functionality available without special access
   - **Ads**: No ads
   - **Content rating**: run the questionnaire → *Medical / reference* → **Everyone**
   - **Target audience**: Adult (18+) — clinicians
   - **Data safety**: “No data collected” (screens explain why below)
   - **Government apps**: No
   - **News app**: No
   - **COVID-19 contact tracing**: No
   - **Financial features**: None
3. **Store listing**:
   - Short description (80 chars): `Bedside ICU/CCU dose, ABG, vent, scores — offline reference for clinicians.`
   - Full description: use the block below (edit as needed).
   - App icon: `flutter_app/assets/icons/icon-1024.png` (or the auto-generated 512).
   - Feature graphic (1024×500): `../icons/feature-1024x500.png` (already generated).
   - Phone screenshots: 4–8 at 1080×1920 or similar. See “Take screenshots” below.
   - Category: **Medical**
   - Contact email + website + phone (optional).

### Full description (paste-ready)

```
Najm ICUCalc is a bedside clinical assistant for ICU and CCU teams.
Enter the patient once — weight, height, age, sex, creatinine — and
every module updates live: infusion drip rates, hemodynamics, ventilator
settings, arterial blood gas interpretation, electrolyte corrections,
renal clearance, and the scoring systems you use every shift.

Modules
• Infusions — 20+ ICU drugs with weight-based ranges, absolute doses, and
  drip rate (mL/hr) at standard concentrations.
• Hemodynamics — MAP, pulse pressure, shock index, CPP, and
  norepi-equivalent vasopressor load.
• Ventilator — predicted body weight, tidal volume targets, Berlin ARDS
  from P/F ratio, driving pressure, static compliance.
• ABG / Acid–Base — primary disorder, expected compensation (Winters and
  others), anion gap and albumin-corrected AG, Δ-Δ ratio, A–a gradient.
• Electrolytes — corrected calcium, glucose-corrected sodium, calculated
  osmolality with osmolar gap, free water deficit, K+ replacement guide.
• Renal & Fluids — Cockcroft–Gault CrCl with renal-dosing alert, urine
  output per kg/hr with oliguria thresholds, sepsis 30 mL/kg bolus,
  4-2-1 maintenance.
• Scores — GCS, qSOFA, SOFA, CHA₂DS₂-VASc, HAS-BLED, Wells (PE), RASS.
• Notes — plain-text scratchpad saved on device.

Privacy
Every value stays on your device — nothing is transmitted, sold, or
shared. The app requests no permissions and works fully offline.

Disclaimer
Reference aid only, not a medical device. Every calculation must be
verified against your institution’s protocols, drug labels, and the
patient's clinical context. The authors assume no liability for clinical
decisions made with this tool.
```

### Data safety — form answers

- **Does your app collect or share any of the required user data types?** No
- **Is all of the user data collected by your app encrypted in transit?** Yes (no data collected, but required)
- **Do you provide a way for users to request that their data is deleted?** Yes (users can clear all local data from within the app)

---

## 5. Upload the AAB

1. **Testing → Internal testing → Create new release**
   - Upload `app-release.aab`
   - Release name auto-fills to versionName+versionCode
   - Release notes: `Initial release.`
   - **Save → Review release → Roll out to Internal testing**
2. Add yourself as an internal tester (Testers tab → email list).
3. Open the join link on your Android phone → install from Play Store.

Iterate on internal builds until confident. When ready:

4. **Production → Create new release** → reuse the last uploaded AAB.
5. **Countries/regions** → select markets. Start with your country + 2–3
   English-speaking markets to keep review scope small.
6. **Send for review**. First-time reviews take **2–7 days**, subsequent
   updates minutes to hours.

---

## 6. Take screenshots (Android)

Best on a real 1080×2400 phone in dark mode. From an emulator:

```bash
flutter run --release
# In app: fill patient (Weight 75, Height 170, Age 55, Sex M, Cr 1.0)
# and capture each of these screens:
#   1. Infusions tab (with rates visible)
#   2. Hemodynamics (SBP 100, DBP 60, HR 110)
#   3. Ventilator (FiO₂ 0.4, PaO₂ 80)
#   4. ABG (pH 7.28, PaCO₂ 20, HCO₃ 10, Na 140, Cl 100, Alb 3)
#   5. Electrolytes
#   6. Scores → GCS or SOFA with an interesting total
#   7. Notes with a short handover blurb
```

On Android: **Power + Volume Down** → screenshots to `Pictures/Screenshots`.
Upload 4–8 to the Play Console listing.

---

## 7. Post-launch

- **Crashlytics dashboard** → any crashes on real devices show up within minutes.
- **Analytics → Events** → screen-view mix tells you which modules doctors use.
- **Remote Config** → push updated drug ranges without a store release:
  1. Console → Remote Config → add key `drug_overrides` (JSON string).
  2. In-app: read on launch, apply as diff to the default `drugs` list.
  3. The wiring stub is in `lib/services/analytics.dart` — extend as needed.

---

## Version bumps

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2   # {marketing}+{build number}
```

Then rebuild the AAB and upload a new release. Play Store requires the
build number to always increase.

## iOS release (later)

`flutter build ipa --release` and follow the Apple side — App Store Connect,
$99/year Apple Developer account. Icons, launch screen, and Firebase are
already set up for iOS in this project.
