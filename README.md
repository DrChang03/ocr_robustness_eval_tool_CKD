# OCR Robustness Evaluation Tool

A mobile framework for evaluating On-Device OCR accuracy on curved,
reflective, and transparent surfaces under low-light conditions.

## Use Case

Detects critical food ingredients (e.g., Phosphates, Potassium, E450)
relevant to dietary restrictions for CKD (Chronic Kidney Disease) patients
— directly on the device, with results synced to a cloud database.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| OCR Engine | Google ML Kit (On-Device) |
| Backend | Supabase (PostgreSQL + Auth) |
| Data Processing | Local regex + string analysis |
| Privacy | On-Device processing, GDPR compliant |

## Key Features

- **Real-time camera stream** for packaging scan
- **On-Device OCR** — works offline, full GDPR compliance
- **Ingredient detection** against a local database of critical compounds
- **Cloud sync** — evaluation results uploaded to Supabase for analysis
- **Visual feedback** for instant detection results
- **Edge Computing** — image processing stays local, only results are synced

## Setup

**Prerequisites:** Flutter SDK (v3.x+), Android Studio and a Supabase project

```bash
git clone https://github.com/DrChang03/ocr-robustness-eval-tool.git
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## Status

⏸️ **Paused** — core functionality complete, development temporarily on hold.

> ⚠️ **Disclaimer:** This tool is intended for research and testing purposes 
> only.
> Detected 80 out of 84 tested products (95.2% accuracy). 
> Do not use for medical decisions. The developer assumes no liability 
> for incorrect ingredient detection.

## License

MIT — Daniel Chen 2025
