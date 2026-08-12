# Quick Task 260812-pw4: Adicionar autenticação local e persistência Hive ao TecnoIso - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Task Boundary

Add local authentication (login gate) and local persistence (Hive) to the
TecnoIso Flutter app in /home/joaofiorentin/Desktop/PROJETOS/tecnoiso,
replacing the mocked data (`_getMockEquipments()` duplicated in
`home_page.dart` and `equipment_list_page.dart`) with a shared repository
backed by Hive. Direct response to professor feedback on the PEX submission:
(1) the app is an internal, non-public tool → needs some form of
authentication; (2) data shown is fixed → needs persistence, whether via
local storage or an API integration.

</domain>

<decisions>
## Implementation Decisions

### Persistence
- Local, in-app via Hive. No backend/API in this pass.
- On first launch, seed the Hive box with the current mocked equipment list
  (same equipment shown today) so the demo/UI looks the same but is now
  backed by real, editable data.

### Authentication
- Local login (username/password). Support **multiple users** with a
  registration screen (not a single hardcoded user) — sign up + login,
  credentials hashed and stored on-device (Hive or secure storage).
- Login/registration gates access to the app (shown before/instead of
  intro_page or right after it — Claude's discretion on exact placement,
  as long as unauthenticated users cannot reach home/equipment/client
  screens).

### Deadline
- Tight (days). Prioritize the minimum that resolves the professor's two
  points cleanly — avoid scope creep (no backend, no API integration, no
  advanced auth like JWT/OAuth).

### Claude's Discretion
- Exact Hive box/model schema for User and Equipment.
- Password hashing approach (any reasonable local hash, e.g. crypto package
  bundled with Flutter — avoid adding heavy new dependencies given the
  deadline).
- Exact placement of login/registration flow relative to `intro_page.dart`.
- Whether `equipment_detail_page.dart`, `clients_page.dart`, `schedule_page.dart`,
  `notifications_page.dart` need updates to read from the new repository —
  scope to what's needed to remove the mock-data duplication and keep the
  app functional end-to-end.

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. Existing dark theme
(`#09090B` / `#DC2626`) and widget patterns (see `lib/widgets/`) should be
reused for any new login/registration screens for visual consistency.

</specifics>

<canonical_refs>
## Canonical References

No external specs — requirements fully captured in decisions above.

</canonical_refs>
