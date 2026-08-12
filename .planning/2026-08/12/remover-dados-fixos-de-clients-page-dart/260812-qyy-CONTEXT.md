# Quick Task 260812-qyy: Remover dados fixos de clients/schedule/notifications - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Task Boundary

Follow-up to quick task 260812-pw4 (local auth + Hive persistence for
equipment). That task fixed the mock data the professor explicitly named
(`_getMockEquipments()`), but `clients_page.dart`, `schedule_page.dart` and
`notifications_page.dart` were left untouched and still contain their own
separate hardcoded lists (client cards, weekly schedule items, notification
cards) — unrelated to `EquipmentRepository`. This task removes that
remaining fixed data so the whole app reflects real, persisted state.

</domain>

<decisions>
## Implementation Decisions

### Data source
- `EquipmentRepository` (already built in 260812-pw4) is the single source
  of truth. No new backend/API, no new persistence mechanism — same
  deadline constraint as the prior task applies here.

### Clients page
- The `Equipment` model has a `client` string field but no client entity
  (no CNPJ, no logo path) — those don't exist anywhere in the data model.
  Introducing a full client CRUD/cadastro is out of scope for this pass
  (would require a new Hive box + forms + relations, not requested by the
  professor's feedback, which was specifically about calibration data being
  fixed).
  - **Decision:** Keep a small static lookup (name → CNPJ + logo asset) as
    reference/display metadata only — this is directory info, not
    calibration data. But the **counts shown per client** (equipment count,
    appointment count, next calibration) MUST be computed live from
    `EquipmentRepository` by grouping equipment on the `client` field —
    these were the numbers previously hardcoded and wrong-by-construction.
  - Clients with no matching equipment in the repository should not show
    fabricated non-zero counts.

### Schedule page
- Replace the hardcoded weekly appointment list with equipment pulled from
  `EquipmentRepository` whose `nextCalibration` falls in the relevant
  window (e.g. next 7 days), sorted by date. This reuses fields that
  already exist on `Equipment` — no new data needed.

### Notifications page
- Replace hardcoded notification cards with ones derived from equipment
  state changes already computable from `Equipment.isOverdue` /
  `Equipment.isUrgent` (overdue calibration, urgent calibration). Exact
  copy/wording can follow the existing hardcoded examples for tone/format.
  Do not fabricate a persisted notification log/history mechanism — deriving
  the "atrasado"/"urgente" list live from current equipment state is
  sufficient and keeps scope tight for the deadline.

### Deadline
- Same as 260812-pw4: tight (days). Prioritize correctness of the derived
  data over polish; do not introduce new dependencies.

### Claude's Discretion
- Exact grouping/sorting logic for clients and schedule.
- Whether to keep the static client→CNPJ/logo lookup inline in
  `clients_page.dart` or extract to a small const map/file.
- Empty-state handling when a client, schedule window, or notification list
  has zero real entries (should look intentional, not broken).

</decisions>

<specifics>
## Specific Ideas

No specific requirements — reuse the pattern already established in
260812-pw4 (`ValueListenableBuilder` on `EquipmentRepository.instance.listenable()`).

</specifics>

<canonical_refs>
## Canonical References

- `.planning/2026-08/12/adicionar-autentica-o-local-e-persist-nc/260812-pw4-PLAN.md` and `260812-pw4-SUMMARY.md` — prior task that built `EquipmentRepository`, the pattern to reuse here.

</canonical_refs>
