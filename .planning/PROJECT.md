# TecnoIso

## What this is

Flutter mobile app for managing measurement/calibration equipment (internal
tool for a calibration company in Joinville/SC). Built as a university
extension project (PEX/TCC) — Centro Universitário Católica de Santa
Catarina, ADS course, author João Vitor Jatobá Fiorentin, July 2026.

## Current state (imported 2026-08-12)

The app was submitted with the "Resultados" section already written, treating
the app as done. Professor feedback on the submission identified two gaps:

1. It's an internal, non-public tool → needs authentication.
2. Data shown in the app is fixed/mocked (`_getMockEquipments()` duplicated
   in `home_page.dart` and `equipment_list_page.dart`) → needs real
   persistence.

## Decisions locked

- **Persistence:** local, in-app (Hive) — no backend/API for this pass.
- **Auth:** local login (username/password, hashed, stored on-device) — no
  auth server.
- **Deadline:** tight (days), so scope is the minimum that resolves the
  professor's two points, not a rewrite.

## Stack

- Flutter (SDK ^3.12.1), Dart
- google_fonts, cupertino_icons
- Dark theme (`#09090B` bg / `#DC2626` primary)
- No state management library yet (StatefulWidget + local state)
