# MedicalSnap Cloud v1.2

> **Repo:** `ocr_robustness_eval_tool_CKD`

![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.1-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status](https://img.shields.io/badge/Status-Paused-lightgrey)
![Accuracy](https://img.shields.io/badge/OCR%20Accuracy-95.2%25-brightgreen)

---

## Overview

**MedicalSnap** is a cross-platform mobile application (iOS & Android) designed to assist patients with **Chronic Kidney Disease (CKD)** in identifying potentially harmful food additives in packaged products. Using the device camera, the app performs on-device OCR on ingredient labels, analyzes the extracted text against a curated list of CKD-relevant substances, and provides instant traffic-light feedback — all without requiring an internet connection for the core detection step.

Scan results, including raw OCR text and detected keywords, are uploaded to a cloud database to support ongoing research into label readability and ingredient detection robustness in real-world retail environments.

> **This is a research and field-testing tool, not a medical device. See the [Disclaimer](#%EF%B8%8F-medical-disclaimer).**

---

## Features

- **Camera-based label scanning** — capture food packaging ingredient lists using the device camera
- **On-device OCR** — text recognition runs locally via Google ML Kit (Latin script); no internet required for detection
- **Regex-based ingredient analysis** — detection engine v3.3, validated against products from Rewe supermarkets
- **Traffic-light visual feedback**
  - **Red** — one or more dangerous ingredients detected
  - **Orange** — result uncertain (too little text extracted or low confidence)
  - **Green** — no flagged ingredients found
- **Raw data debug view** — collapsible panel showing the full OCR output for verification
- **Cloud sync** — raw OCR text and detected keywords are uploaded to Supabase for research logging

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Flutter (Dart) `^3.10.1` | Cross-platform iOS & Android |
| OCR Engine | Google ML Kit Text Recognition | On-device, Latin script |
| Backend / DB | Supabase (PostgreSQL) | Frankfurt region; table: `field_test_data` |
| Camera / Image | `image_picker` | Native camera integration |
| Detection Logic | Custom Regex Engine v3.3 | Dart, see `ingredient_analyzer.dart` |

---

## Detected Ingredients

The following substances are flagged as potentially harmful for CKD patients. Detection is performed via case-insensitive regex matching against the raw OCR text.

| Identifier | Name | CKD Concern |
|---|---|---|
| `phospha` / `phospho` | Phosphate / Phosphoric acid (PHOSPHAT / SÄURE) | Elevated phosphorus accelerates CKD progression and cardiovascular risk |
| E450 | Diphosphate | Inorganic phosphate additive; high bioavailability |
| E338 | Phosphoric acid | Acidulant; significant phosphorus load |
| E339 | Sodium phosphates | Phosphorus additive |
| E340 | Potassium phosphates | Combined phosphorus and potassium risk |
| E341 | Calcium phosphates | Phosphorus additive |
| E451 | Triphosphates (Polyphosphate) | High-absorption inorganic phosphate |
| E452 | Polyphosphates | High-absorption inorganic phosphate |
| E621 | Monosodium glutamate (MSG / Glutamate) | Flavor enhancer; associated with dietary load concerns |
| `KALIUM` | Potassium | Hyperkalemia risk in CKD; can cause cardiac arrhythmia |
| `HEFEEXTRAKT` | Yeast extract | Hidden source of phosphate and potassium |
| `GESCHMACKSVERSTÄRKER` | Flavor enhancers (generic) | Often contain glutamates or hidden phosphates |
| `NATRIUMNITRIT` | Sodium nitrite | Preservative; associated with oxidative stress in CKD |

---

## Architecture & File Structure

```
ocr_robustness_eval_tool_CKD/
├── lib/
│   ├── main.dart                        # App entry point; Supabase initialization
│   ├── screens/
│   │   └── ocr_scanner_screen.dart      # Main UI, camera trigger, OCR pipeline, result display
│   ├── utils/
│   │   └── ingredient_analyzer.dart     # Regex-based detection engine (v3.3)
│   └── services/
│       └── supabase_service.dart        # Supabase singleton — cloud upload logic
├── pubspec.yaml
└── README.md
```

**Data flow:**

```
Camera capture
    │
    ▼
ML Kit OCR (on-device)
    │
    ▼
ingredient_analyzer.dart  ──► Traffic-light result (Red / Orange / Green)
    │
    ▼
supabase_service.dart  ──► Supabase PostgreSQL (field_test_data table)
```

---

## Setup & Installation

### Prerequisites

- Flutter SDK `^3.10.1` installed and on your `PATH`
- A Supabase project with a `field_test_data` table and a valid anonymous key
- iOS: Xcode 14+ with a provisioning profile; Android: Android Studio or the Android SDK

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/DrChang03/ocr_robustness_eval_tool_CKD.git
cd ocr_robustness_eval_tool_CKD
```

**2. Set up your Supabase project**

- Create a free account at [supabase.com](https://supabase.com)
- Create a new project and open the **SQL Editor**
- Run the setup script from this repo:

```bash
# Copy the contents of supabase/schema.sql into the Supabase SQL Editor and execute it
```

Or paste [`supabase/schema.sql`](supabase/schema.sql) directly. This creates the `field_test_data` table and the required Row Level Security policies.

- Copy your **Project URL** and **anon public key** from *Project Settings → API*

**3. Install Flutter dependencies**
```bash
flutter pub get
```

**4. Run the app — pass your credentials at build time**
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

> **Security note:** Credentials are injected via `--dart-define` and must never be committed to the repository.

For a release build:

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## How It Works

1. **Capture** — The user points the camera at a food product's ingredient list and triggers a scan. `image_picker` passes the image to the ML Kit pipeline.
2. **OCR** — Google ML Kit Text Recognition processes the image entirely on-device and returns the extracted text string.
3. **Analysis** — `ingredient_analyzer.dart` applies a set of case-insensitive regular expressions against the extracted text, producing a list of matched substances and a summary verdict (Red / Orange / Green).
4. **Display** — `ocr_scanner_screen.dart` renders the traffic-light indicator, the list of detected ingredients, and (optionally) the collapsible raw OCR text panel.
5. **Upload** — `supabase_service.dart` asynchronously pushes a log record to the `field_test_data` table in Supabase, containing the raw OCR text and the detected keyword list.

---

## Accuracy & Testing

| Metric | Value |
|---|---|
| Products tested | 42 (field export) / 84 (total manual evaluation) |
| Correct detections | 80 / 84 |
| Overall accuracy | **95.2%** |
| Test location | Rewe supermarket (German labels) |
| Detection engine | v3.3 (regex) |
| Study period | 2025-12-14 – 2025-12-17 |

### Methodology

Testing was conducted as a **continuous field session** with iterative bugfix versioning — every error discovered during scanning triggered an immediate fix and a version increment (V1.0 → V1.1 → ...). This means the dataset spans multiple app versions within a single session.

**Test conditions:**
- **Lighting:** Low light only — monitor/screen brightness as sole light source
- **Materials:** Kunststoff (plastic), Verbundstoffe (composite), Metall, Pappe/Papier, Glas

**Known failure modes:**
- Curved surfaces distort printed text — OCR merges or drops characters along the curve (e.g. `kalumjodat` instead of `Kaliumjodat`)
- Reflective packaging introduces scan noise
- Low-contrast labels under low light reduce OCR confidence

> Raw scan data and full field notes are available in [`data/`](data/RESULTS.md).

---

## Data & Privacy

| Aspect | Detail |
|---|---|
| On-device processing | OCR and ingredient analysis run entirely on the device; no image data is transmitted |
| What is uploaded | Raw OCR text (the string extracted from the label) and the list of matched keywords |
| What is not uploaded | Images, device identifiers, or any personal health information |
| Storage location | Supabase PostgreSQL, Frankfurt region (EU) |
| Purpose | Robustness research — evaluating OCR accuracy and regex coverage across real-world products |
| GDPR | Processing of image data occurs on-device only. Only derived text results are synced to the cloud. No personal data is collected intentionally. |

Users should be aware that ingredient list text from scanned products is sent to a cloud database. Do not scan documents containing personal or sensitive information.

---

## ⚠️ Medical Disclaimer

> **THIS APPLICATION IS NOT A MEDICAL DEVICE.**
> Use of this application does not constitute medical advice, diagnosis, or treatment.

**Daniel Chen, the developer of MedicalSnap, expressly disclaims all responsibility and liability for any harm, injury, health damage, or adverse outcome — direct or indirect — that may result from use of, or reliance on, this application.**

This tool was built solely for **research purposes** to evaluate OCR accuracy on food packaging. It is **not approved, certified, or validated** by any medical authority, health agency, or regulatory body (including but not limited to FDA, EMA, or BfArM).

### What this app cannot and does not do:
- It does **not** provide a complete or medically accurate ingredient analysis
- It does **not** replace reading the full ingredient list on the packaging yourself
- It does **not** account for individual CKD severity, comorbidities, or prescribed dietary limits
- It does **not** detect all harmful substances — detection coverage is limited and may miss new additives or non-standard labeling

### Your responsibility as a user:
- **Always consult a qualified nephrologist or renal dietitian** before making any dietary decisions
- **Never rely solely on this app** for food safety decisions
- **Always read the original product label** in full

**By using this application, you acknowledge that you do so entirely at your own risk. The developer assumes no liability whatsoever.**

---

## Project Status

**Paused.** Core functionality is complete and the app is functional. Active development is not ongoing at this time.

---

## License

MIT License — Copyright (c) 2025 Daniel Chen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
