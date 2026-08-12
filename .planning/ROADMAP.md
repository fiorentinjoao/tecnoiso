# Roadmap

## Milestone: v1 — Auth + Persistence (professor feedback)

### Phase 1: Local auth + Hive persistence

**Goal:** Resolve professor feedback — the app must require login and must
persist real data instead of hardcoded mock lists.

**Status:** in-progress (tracked via quick tasks, see STATE.md)

Requirements:
- REQ-01: Login screen gates access to the app (username/password, hashed, local).
- REQ-02: Equipment data lives in local storage (Hive), not in hardcoded lists.
- REQ-03: `_getMockEquipments()` duplication in `home_page.dart` and
  `equipment_list_page.dart` is replaced by a single shared data source.
- REQ-04: Existing screens (home, list, detail) read from the new data layer
  without behavior regressions.
