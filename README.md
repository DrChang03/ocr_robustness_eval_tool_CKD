# 🚀 Project LifeGuard (Internal Codename)

> **Status:** Active Development (MVP Phase)  
> **Copyright:** © 2025 Daniel Chen. All Rights Reserved.  
> **Confidentiality:** Private Repository. Do not distribute.

## 📋 Executive Summary
Project LifeGuard is a privacy-first, AI-driven dietary management platform designed for CKD (Chronic Kidney Disease) patients. It utilizes on-device OCR and hashing algorithms to detect changes in food ingredients without uploading sensitive user images to the cloud, ensuring strict GDPR compliance and BfArM (DiGA) readiness.

## 🏗 Technical Architecture (Solopreneur Stack)

The system follows a "Zero-Knowledge" privacy architecture:

*   **Client:** Flutter (Dart)
    *   *Role:* UI, OCR (Google ML Kit), Hash Generation, Business Logic.
    *   *Privacy:* No image upload. Only extracted text hashes leave the device.
*   **Backend:** Supabase
    *   *Role:* Product Database (`foods_db`), User Analytics (Anonymized).
    *   *Auth:* Anonymous Login for MVP.
*   **Data Pipeline:**
    *   `Raw Scan` -> `On-device OCR` -> `Text Extraction` -> `SHA-256 Hash` -> `Server Query`.

## 🛠 Setup & Installation

**Prerequisites:**
*   Flutter SDK (v3.x+)
*   Dart SDK
*   Google ML Kit dependencies

**How to Run:**
```bash
# Clone the repository
git clone https://github.com/your-username/project-lifeguard-core.git

# Install dependencies
flutter pub get

# Run on emulator or physical device
flutter run