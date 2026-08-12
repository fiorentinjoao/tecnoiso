---
phase: 260812-pw4
plan: 01
subsystem: auth-and-persistence
tags: [flutter, hive, authentication, crud, persistence]
status: complete
dependency-graph:
  requires: []
  provides:
    - lib/data/hive_setup.dart
    - lib/data/equipment_repository.dart
    - lib/data/auth_repository.dart
    - lib/utils/password_hasher.dart
    - lib/pages/auth_gate.dart
    - lib/pages/login_page.dart
    - lib/pages/register_page.dart
    - lib/pages/equipment_form_page.dart
  affects:
    - lib/main.dart
    - lib/models/equipment.dart
    - lib/pages/intro_page.dart
    - lib/pages/home_page.dart
    - lib/pages/equipment_list_page.dart
    - lib/pages/equipment_detail_page.dart
tech-stack:
  added:
    - hive_ce ^2.19.3
    - hive_ce_flutter ^2.3.4
    - crypto ^3.0.7
  patterns:
    - "Single box-opening module (lib/data/hive_setup.dart); repositories and
       screens only read the already-open boxes."
    - "Hand-written Hive TypeAdapters using the numbered-field wire format
       (typeId 0 = Equipment, typeId 1 = User) for forward compatibility
       without codegen."
    - "ValueListenableBuilder<Box<T>> on a repository's listenable() as the
       live-update mechanism between screens (dashboard, list, detail)."
    - "Session state (currentUserId, equipmentsSeeded) kept in its own Hive
       box, separate from the users box, per RESEARCH pitfall #5."
key-files:
  created:
    - lib/models/user.dart
    - lib/utils/password_hasher.dart
    - lib/data/hive_setup.dart
    - lib/data/equipment_repository.dart
    - lib/data/auth_repository.dart
    - lib/pages/auth_gate.dart
    - lib/pages/login_page.dart
    - lib/pages/register_page.dart
    - lib/pages/equipment_form_page.dart
    - test/password_hasher_test.dart
    - test/repositories_test.dart
  modified:
    - pubspec.yaml
    - lib/main.dart
    - lib/models/equipment.dart
    - lib/pages/intro_page.dart
    - lib/pages/home_page.dart
    - lib/pages/equipment_list_page.dart
    - lib/pages/equipment_detail_page.dart
    - test/widget_test.dart
decisions:
  - "Password hashing: SHA-256 over salt+password with a 16-byte
     Random.secure() salt, accepted for a local non-networked tool per
     RESEARCH assumption A1 and the plan's D-05 (no backend/JWT/OAuth)."
  - "Equipment.copyWith uses a sentinel object to distinguish 'certificateId
     not provided' from 'certificateId explicitly set to null'."
  - "AuthRepository throws a typed AuthException (usernameTaken /
     invalidCredentials) rather than returning booleans, so LoginPage and
     RegisterPage render distinct, non-oracle-leaking error copy."
metrics:
  duration: "~90 minutes"
  completed: "2026-08-12"
---

# Phase 260812-pw4 Plan 01: Local auth + Hive persistence Summary

Added multi-user local authentication (hashed credentials, registration + login)
and a single Hive-backed equipment repository with full CRUD, replacing the two
duplicated hardcoded 8-item equipment lists in `home_page.dart` and
`equipment_list_page.dart`.

## What was built

**Task 1 — Persistence layer, password hashing, repositories.**
Added `hive_ce`, `hive_ce_flutter` and `crypto` as dependencies. Extended
`Equipment` with a null-safe `copyWith` and a hand-written `EquipmentAdapter`
(typeId 0) that stores both calibration dates as epoch-ms integers, closing
the UTC/local-mixing pitfall RESEARCH flagged. Added `User` + `UserAdapter`
(typeId 1), which never holds a plaintext password field. Added
`PasswordHasher` (`Random.secure()` salt + SHA-256). Added `hive_setup.dart`
as the only module that calls the real `Hive.openBox<T>()` API, exposing
three box-name constants (`equipments`, `users`, `session`) and a
testability seam (`initHive({path})`) so tests never touch `path_provider`.
Added `EquipmentRepository` (singleton, keyed by equipment id, idempotent
`seedIfNeeded()` guarded by a session flag so user-deleted demo records never
resurrect) and `AuthRepository` (singleton; case-insensitive username
uniqueness/lookup; typed `AuthException` instead of bare booleans; a stale
session id degrades to logged-out instead of crashing).
`test/password_hasher_test.dart` and `test/repositories_test.dart` cover both
units plus a real temp-dir Hive round-trip — 25 tests, all passing.

**Task 2 — Async bootstrap and the auth gate.**
`main()` now awaits `initHive()` → `registerAdapters()` → `openBoxes()` →
`EquipmentRepository.instance.seedIfNeeded()` before `runApp()`, in the exact
order RESEARCH prescribes to avoid a cold-start box-not-found crash. Added
`AuthGate` as the single choke point into `HomePage`: it renders `LoginPage`
when there is no session and `HomePage` otherwise. `intro_page.dart` now
targets `AuthGate` instead of `HomePage` — the branding animation is
unchanged, only its destination changed. Added `LoginPage` (generic
"usuário ou senha inválidos" message for both a wrong password and an
unknown username, so it is not a username-enumeration oracle) and
`RegisterPage` (username/password/confirm validation, auto-login on
success). `home_page.dart`'s drawer gained a "Sair" item that logs out and
clears the navigation stack via `pushAndRemoveUntil`. `test/widget_test.dart`
now bootstraps Hive itself (the test pumps `TecnoisoApp` directly, not
`main()`) and gained a second test that advances past the intro and asserts
the login screen is present while a dashboard-only string is absent —
the authoritative proof the D-04 gate holds.

**Task 3 — Repository-backed equipment screens with CRUD.**
Deleted both copies of the mock builder. `home_page.dart`'s dashboard now
rebuilds from a `ValueListenableBuilder<Box<Equipment>>` on
`EquipmentRepository.instance.listenable()`; the "Novo Equipamento" quick
action and every `EquipmentTile` now navigate to the new
`EquipmentFormPage` / `EquipmentDetailPage` instead of doing nothing.
`equipment_list_page.dart` reads from the same listenable, preserving its
search/filter logic verbatim, and its pull-to-refresh now rereads from the
repository instead of running a no-op 1.5s delay. Added
`EquipmentFormPage`, a single form serving both create and edit (status
locked to the three literals `'Atrasado'/'Urgente'/'Em dia'` the rest of the
UI switches on; date pickers with an ordering check; edit mode reuses the
existing id via `copyWith` so the write lands on the same box key).
`equipment_detail_page.dart` became a `StatefulWidget` that resolves the
current record from the repository inside a `ValueListenableBuilder` (so an
edit is reflected live) and gained edit + delete actions, the latter behind
a themed confirmation dialog; if the record is deleted, the screen pops
instead of rendering stale data. Extended `repositories_test.dart` with a
regression test pinning the 8 seeded ids to their original
name/client/status.

## Verification

- `flutter analyze`: **No issues found!** (checked after every task and
  again after the plan completed).
- `flutter test`: **28/28 passing** (7 password-hasher + 19
  repository/adapter/auth + 2 widget tests, including the D-04 gate
  assertion).
- `grep -rn 'MockEquipments' lib/`: no matches.
- `grep -rn 'Equipment(id:' lib/pages/`: no matches (no page constructs a
  literal `Equipment`).
- `grep -rn 'Hive\.openBox\|\.openBox<' lib/` outside `hive_setup.dart`: no
  matches — the real Hive API is only ever called from the sanctioned
  module.
- Smoke-tested via `flutter run -d linux --no-hot` twice (after Task 2 and
  after Task 3): the app builds and launches without crashing (only a
  harmless GTK "Unable to load cursor theme" warning). No interactive UI
  automation tool was available in this environment to drive the
  register → dashboard → CRUD → logout → restart flow by hand; see
  "Not independently verified" below.

## Deviations from Plan

### Auto-fixed issues

**1. [Rule 1 - Bug] `use_build_context_synchronously` lint in
`equipment_detail_page.dart`**
- **Found during:** Task 3, `flutter analyze` after adding the delete
  confirmation flow.
- **Issue:** `Navigator.of(context)` was read immediately after an awaited
  `showDialog` without a `mounted` guard.
- **Fix:** Added `if (confirmed != true || !mounted) return;` before
  capturing the `Navigator`.
- **Files modified:** `lib/pages/equipment_detail_page.dart`
- **Commit:** `84faa7c`

**2. [Rule 1 - Bug] Unused import in `test/repositories_test.dart`**
- **Found during:** Task 1, `flutter analyze`.
- **Issue:** `package:hive_ce_flutter/hive_ce_flutter.dart` was imported
  but never referenced.
- **Fix:** Removed the import.
- **Files modified:** `test/repositories_test.dart`
- **Commit:** `d125555`

### Known false-positive in the plan's own verification text (not a defect)

Task 1's automated check `grep -rn 'openBox' lib/ | grep -v hive_setup.dart`
(also restated in the plan's overall `<verification>` §4) is a substring
match. Task 2's action text explicitly requires `main.dart` to call a
function literally named `openBoxes()` (mandated by name in the plan), and
that call now appears in `lib/main.dart`. Because `"openBoxes()"` contains
the substring `"openBox"`, the literal grep now reports a match outside
`hive_setup.dart` even though no per-page raw `Hive.openBox<T>()` call
exists anywhere. Confirmed the actual anti-pattern is absent with a
tighter check: `grep -rn 'Hive\.openBox\|\.openBox<' lib/` outside
`hive_setup.dart` returns nothing. Documented here rather than silently
ignored, since the literal command as written in the plan will report a
false failure if re-run verbatim.

## Not independently verified (human-check items from the plan)

This environment had no interactive GUI-automation tool available for the
Linux desktop app (no `claude-in-chrome`-equivalent for a native window), so
the `<human-check>` blocks in Tasks 2 and 3 were not driven end-to-end by
hand. What *was* verified:
- The app builds and launches cleanly via `flutter run -d linux` (twice,
  after Task 2 and after Task 3) with no runtime crash.
- The equivalent logic is covered by automated tests: `AuthRepository`
  register/login/logout/session-restart/dangling-session behavior (7
  tests), `EquipmentRepository` seed/idempotency/no-resurrection/CRUD (7
  tests including the new regression test), and the D-04 widget-test gate
  (login screen present, dashboard string absent, after the intro settles).

Recommend a manual pass before submission: register a user → confirm
landing on the dashboard → create/edit/delete an equipment and confirm it
appears identically on the dashboard and the equipment list → log out →
log back in → fully quit and relaunch the app → confirm the session and all
CRUD changes persisted and no deleted seed record reappeared.

## Known Stubs

None. All screens read live data from the repositories; no hardcoded/empty
placeholder values remain in the touched files.

## Threat Flags

None beyond what the plan's own `<threat_model>` already covers (T-pw4-01
through T-pw4-08, T-pw4-SC) — no new endpoints, auth paths, or trust
boundaries were introduced beyond what was planned.

## Self-Check: PASSED

All 19 files listed in the plan's `files_modified` frontmatter exist on
disk. All 3 task commits (`d125555`, `b870058`, `84faa7c`) are present in
`git log`.
