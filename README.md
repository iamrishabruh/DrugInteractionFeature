# Drug Interaction Checker

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Public **SwiftUI proof of concept** for exploring how a patient-facing app might surface **medication interaction** information using healthcare-style API integration patterns. This is **not** a production clinical product, **not** affiliated with any employer’s shipped app, and **not** a source of medical advice.

## What this is

A small iOS demo that lets you enter medication names, resolve them to drug identifiers (RxCUIs) when using the live client, fetch interaction rows, and display severity-aware summaries with clear error states.

Screenshots (stylized placeholders that mirror the layout palette) live in [`docs/assets/`](docs/assets/).

## Why it matters

People often take multiple prescription and over-the-counter medications (**polypharmacy**). Drug–drug interactions can change effectiveness or increase risk, yet the underlying data sources are easy to misread without careful UX and explicit limitations. This project focuses on **clarity**, **testability**, and **honest disclaimers** rather than clinical completeness.

## Architecture

SwiftUI views, an `ObservableObject` view model, a protocol-based API client, and small models. See [`docs/architecture.md`](docs/architecture.md) for a concise map of responsibilities and data flow.

At a glance:

- **Views:** `ContentView`, `InteractionReportView`, `InformationPage`
- **View model:** `DrugInteractionViewModel`
- **API client protocol:** `DrugInteractionAPIClient`
- **Implementations:** `RxNavDrugInteractionClient` (live), `MockDrugInteractionClient` (offline-friendly)
- **Models:** `Medication`, `DrugInteraction`, `InteractionSeverity`, `DrugInteractionError`

## Mock mode (default)

By default the app uses **`MockDrugInteractionClient`**, which ships with a tiny built-in drug directory and sample interactions (for example **aspirin** + **warfarin**). This keeps the project usable for UI exploration and tests even when public endpoints change.

To attempt **live RxNav** HTTP calls from the simulator or device, set the environment variable **`USE_LIVE_RXNAV=1`** on the `DrugInteractionChecker` run scheme (Xcode → Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables).

## How to run

1. Open **`DrugInteractionChecker.xcodeproj`** in Xcode 15+ on macOS.
2. Select an iOS Simulator (iOS 16+).
3. Run the **`DrugInteractionChecker`** scheme.

Try mock mode first: add **aspirin** and **warfarin**, then open **Check for interactions**.

## Tests

The `DrugInteractionCheckerTests` target covers:

- JSON parsing for RxCUI lookup and interaction payloads
- Mock client behavior and simulated failures
- View model state transitions
- Severity normalization and sorting

Run tests with **Product → Test** (⌘U).

## API / deprecation note

This POC historically referenced RxNav-style JSON over HTTP. **Public medication APIs change, move, or retire without notice.** The live client is provided **as-is** for experimentation. Prefer the mock client for stable demos, and verify any real integration against current vendor documentation and your compliance requirements.

## Limitations and safety disclaimer

This repository is for **software education and prototyping** only.

- It does **not** provide medical diagnosis, treatment, or prescribing guidance.
- It may be **incomplete**, **out of date**, or **incorrect** relative to evolving formularies and clinical evidence.
- Always consult a **qualified clinician or pharmacist** about medication questions or emergencies.

The authors and contributors disclaim responsibility for decisions made based on this sample code or any data it displays.

## License

MIT — see [`LICENSE`](LICENSE).
