# Architecture

This repository is a **public educational proof of concept** for a SwiftUI medication interaction checker. It is intentionally small and explicit so the moving parts are easy to read and test.

## Layers

### Views (SwiftUI)

- `ContentView` collects medication names and navigates to the report screen.
- `InteractionReportView` triggers loading, renders loading/empty/error/success states, and lists interaction cards.
- `InformationPage` provides neutral educational copy and an external literature link.

Views depend on `DrugInteractionViewModel` and do not call `URLSession` directly.

### View model

`DrugInteractionViewModel` owns:

- The list of user-entered medication names.
- A `Phase` state machine: `idle`, `loading`, `loaded`, `failed`.
- Orchestration rules: empty input validation, unknown drug detection (unresolved RxCUI in live mode, missing directory entry in mock mode), and stable sorting of results by severity.

### Networking

`DrugInteractionAPIClient` is the abstraction boundary.

- `RxNavDrugInteractionClient` performs best-effort calls to RxNav REST endpoints and maps HTTP/transport failures into `DrugInteractionError`.
- `MockDrugInteractionClient` returns deterministic RxCUIs and sample interactions so the UI and tests work even when public endpoints change or are unavailable.

Runtime selection happens in `DrugInteractionViewModel.makeClient()` using the `USE_LIVE_RXNAV` environment variable (see README).

### Models

- `Medication` — display name plus optional `rxcui`.
- `DrugInteraction` — paired drug names, clinical text, a short recommendation string for the POC, and `InteractionSeverity`.
- `InteractionSeverity` — normalized enum used for sorting and UI emphasis.
- `DrugInteractionError` — explicit, user-presentable failures (empty list, unknown drug, network, API unavailable/deprecated behavior).

### Parsing

`RxNavDTOs` defines a minimal `Codable` subset of RxNav JSON.

`RxNavResponseParser` converts downloaded JSON into `[DrugInteraction]` and extracts an RxCUI from lookup responses. The parser is covered by unit tests with canned JSON.

## Data flow

1. The user adds medication strings in `ContentView`.
2. `InteractionReportView` appears and calls `loadInteractions()` via `.task` / refresh.
3. The view model asks the client to resolve names to RxCUIs, then fetches interactions for the resolved id set.
4. Results are sorted (high-severity rows first) and published as `.loaded`.
5. Failures become `.failed` with a dismissible callout.

## Testing strategy

- **Parsing tests** validate JSON decoding and mapping without network I/O.
- **Mock client tests** validate deterministic behavior and simulated failure modes.
- **View model tests** validate state transitions across happy path and error paths.
- **Severity tests** validate normalization and sort ordering.

## Non-goals

This project does not implement authentication, persistence, clinician workflows, dosing, or a vetted clinical knowledge base. It demonstrates UI patterns and a testable service boundary only.
