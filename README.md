# Mobile OCR Robustness Evaluation Tool

**Status:** Active Development (Prototype)
**Developer:** Daniel Chen
**License:** Proprietary / Confidential

## 1. Project Overview

This repository contains the source code for a mobile data collection framework designed to evaluate the robustness of On-Device OCR (Optical Character Recognition) in challenging real-world environments.

The primary academic goal is to benchmark text recognition accuracy on **curved, reflective, and transparent surfaces** (e.g., bottles, cans, plastic packaging) under varying low-light conditions.

As a test case, the system implements a post-processing algorithm to detect specific chemical compounds (e.g., Phosphates, Potassium) relevant to Chronic Kidney Disease (CKD) dietary restrictions.

## 2. Technical Architecture

The system adheres to a strict "Privacy-by-Design" architecture. All image processing is performed locally on the device (Edge Computing) to ensure data sovereignty and GDPR compliance.

*   **Frontend Framework:** Flutter (Dart)
*   **OCR Engine:** Google ML Kit (On-Device Text Recognition API)
*   **Data Processing:** Local regex pattern matching and string analysis
*   **Privacy:** Zero-knowledge architecture (No image upload to external servers)

## 3. Key Features

*   **Camera Stream Integration:** Real-time capture of packaging data.
*   **Text Extraction:** Converting visual data into structured string streams.
*   **Keyword Filtering:** Algorithm to match extracted text against a local database of critical ingredients (e.g., "E450", "Diphosphat").
*   **User Feedback Loop:** Visual status indicators for detection results.

## 4. Setup & Usage

**Prerequisites:** Flutter SDK (v3.x+) and Android Studio.

```bash
# Clone the repository
git clone https://github.com/your-username/ocr-robustness-eval-tool.git

# Install dependencies
flutter pub get

# Run on physical device
flutter run