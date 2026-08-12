---
phase: 260812-qyy
plan: 01
type: execute
wave: 1
depends_on: [260812-pw4]
autonomous: true
requirements: [CLIENTS-DERIVED, SCHEDULE-DERIVED, NOTIF-DERIVED, NO-FIXED-DATA]
files_modified:
  - lib/data/client_directory.dart
  - lib/data/derivations.dart
  - lib/utils/date_labels.dart
  - lib/pages/clients_page.dart
  - lib/pages/schedule_page.dart
  - lib/pages/notifications_page.dart
  - test/derivations_test.dart
  - test/pages_derived_test.dart

must_haves:
  truths:
    - "The clients screen shows one card per distinct client that actually has equipment in the repository — a client with no equipment never appears with fabricated non-zero counts (D-03)."
    - "Each client card's equipment count, agenda count and next-calibration date are computed from EquipmentRepository at render time and change when equipment is added, edited or deleted (D-02)."
    - "A client name typed into the equipment form that is absent from the static directory still appears on the clients screen, with placeholder identity text and a letter avatar instead of a missing-asset crash."
    - "The schedule screen lists real equipment whose calibration is overdue or due within 30 days, sorted earliest first, and displays no invented clock times (D-04)."
    - "The schedule calendar strip shows the current month/year and the current week derived from the system date, with today highlighted."
    - "The notifications screen shows one alert per overdue or urgent equipment, derived live from Equipment.isOverdue / Equipment.isUrgent; no event-log entries are shown for events the app never recorded (D-05)."
    - "Each of the three screens renders an intentional empty state when there is nothing to show, instead of a blank or broken layout."
    - "No hardcoded client, appointment or notification list literal remains under lib/pages/."
    - "The 28 tests from 260812-pw4 still pass and pubspec.yaml gains no new dependency (D-01, D-06)."
  artifacts:
    - lib/data/client_directory.dart
    - lib/data/derivations.dart
    - lib/utils/date_labels.dart
    - test/derivations_test.dart
    - test/pages_derived_test.dart
  key_links:
    - "All three pages subscribe through ValueListenableBuilder on EquipmentRepository.instance.listenable(), the same pattern as home_page._buildDashboardListenable() — without it, a write from the equipment form leaves these screens stale, which is the exact bug being fixed."
    - "Agenda membership is defined once, as isOnAgenda(e) => e.isOverdue || e.isUrgent, reusing the Equipment model getters — so the clients AGEND. count, the schedule list and the notification list can never disagree with each other or with the dashboard counters."
    - "ClientSummary.name is the raw Equipment.client string and kClientDirectory is keyed on that same string — any normalization mismatch silently drops CNPJ and logo for a real client."
    - "lib/data/derivations.dart must import no Flutter material types (severity is an enum, never a Color), otherwise test/derivations_test.dart stops being a pure unit test."
    - "clients_page must branch on a null logoAsset BEFORE calling Image.asset — Image.asset cannot take a null path, and an asset path not listed in pubspec.yaml throws rather than reaching errorBuilder in some load paths."
---

<objective>
Remove the remaining hardcoded data from `clients_page.dart`, `schedule_page.dart` and
`notifications_page.dart`, deriving every number, date and alert on those three screens
from the real Hive-backed `EquipmentRepository` built in 260812-pw4.

Purpose: 260812-pw4 fixed the mock data the professor named explicitly
(`_getMockEquipments()`), but three screens still ship their own independent hardcoded
lists — client cards with invented equipment/appointment counts, a weekly agenda with
invented clock times, and notification cards describing events the app never recorded.
Any of those screens contradicts the dashboard the moment a user edits equipment.

Output: a small pure-Dart derivation layer (`lib/data/derivations.dart`,
`lib/data/client_directory.dart`, `lib/utils/date_labels.dart`), the three pages rewired
to it through `ValueListenableBuilder`, and two new test files proving the derived values
are real and the hardcoded literals are gone.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/STATE.md
@.planning/2026-08/12/remover-dados-fixos-de-clients-page-dart/260812-qyy-CONTEXT.md
@.planning/2026-08/12/adicionar-autentica-o-local-e-persist-nc/260812-pw4-SUMMARY.md
@lib/models/equipment.dart
@lib/data/equipment_repository.dart
@lib/data/hive_setup.dart
@lib/pages/home_page.dart
@lib/pages/clients_page.dart
@lib/pages/schedule_page.dart
@lib/pages/notifications_page.dart
@test/repositories_test.dart
@test/widget_test.dart
</context>

<decision_map>
CONTEXT.md states its decisions as prose sections rather than numbered IDs. This plan
uses the following stable IDs; every task action cites the ones it implements.

| ID | Decision (from 260812-qyy-CONTEXT.md) |
|----|----------------------------------------|
| D-01 | `EquipmentRepository` is the single source of truth. No new backend, API or persistence mechanism. |
| D-02 | Clients page keeps a small static name→CNPJ+logo lookup as display metadata only; the counts per client (equipment, agenda, next calibration) MUST be computed live from the repository by grouping on `Equipment.client`. |
| D-03 | Clients with no matching equipment must not show fabricated non-zero counts. |
| D-04 | Schedule page derives its list from equipment whose `nextCalibration` falls in the relevant window, sorted by date. |
| D-05 | Notifications derive from `Equipment.isOverdue` / `Equipment.isUrgent`; no persisted notification log is to be fabricated; existing copy sets the tone. |
| D-06 | Tight deadline: correctness of derived data over polish; introduce no new dependencies. |
| DISC-A | Claude's discretion: exact grouping/sorting logic for clients and schedule. |
| DISC-B | Claude's discretion: inline vs extracted static client lookup. |
| DISC-C | Claude's discretion: empty-state handling for zero real entries. |

Discretion resolved in this plan:
- DISC-A — Agenda membership is `isOverdue || isUrgent`, i.e. overdue plus the next 30
  days, expressed through the existing model getters rather than a new window constant.
  CONTEXT says "e.g. next 7 days"; a literal 7-day window renders an EMPTY agenda against
  the current seed data (nearest future `nextCalibration` is 2026-10-01, ~7 weeks out) and
  hides the five overdue items, which are precisely the pending work. Reusing the model
  getters also keeps these screens in lockstep with the dashboard's overdue/urgent tiles.
- DISC-B — Extracted to `lib/data/client_directory.dart`, so `lib/data/derivations.dart`
  stays pure and unit-testable and the page file holds no data literals at all.
- DISC-C — Each screen gets a centered icon + message empty state, styled from the
  existing dark palette.

Out of scope, per CONTEXT: client CRUD/cadastro, a new Hive box for clients, a persisted
notification history, and making the decorative search bar / month-nav chevrons functional.
</decision_map>

<source_audit>
| # | Source | Item | Covered by | Status |
|---|--------|------|-----------|--------|
| 1 | GOAL | Remove fixed data from clients_page.dart | Task 2 | COVERED |
| 2 | GOAL | Remove fixed data from schedule_page.dart | Task 2 | COVERED |
| 3 | GOAL | Remove fixed data from notifications_page.dart | Task 3 | COVERED |
| 4 | GOAL | Derive from the real EquipmentRepository (Hive) | Tasks 1-3 | COVERED |
| 5 | REQ | CLIENTS-DERIVED | Tasks 1, 2 | COVERED |
| 6 | REQ | SCHEDULE-DERIVED | Tasks 1, 2 | COVERED |
| 7 | REQ | NOTIF-DERIVED | Tasks 1, 3 | COVERED |
| 8 | REQ | NO-FIXED-DATA (grep gates + widget proof) | Tasks 2, 3 | COVERED |
| 9 | CONTEXT | D-01 single source of truth, no new persistence | Tasks 1-3 | COVERED |
| 10 | CONTEXT | D-02 static identity lookup, live counts | Tasks 1, 2 | COVERED |
| 11 | CONTEXT | D-03 no fabricated counts for empty clients | Tasks 1, 2 | COVERED |
| 12 | CONTEXT | D-04 schedule from nextCalibration window, sorted | Tasks 1, 2 | COVERED |
| 13 | CONTEXT | D-05 notifications from isOverdue/isUrgent, no log | Tasks 1, 3 | COVERED |
| 14 | CONTEXT | D-06 no new dependencies | Task 3 (pubspec gate) | COVERED |
| 15 | CONTEXT | DISC-A/B/C discretion areas | decision_map | COVERED |

RESEARCH: no RESEARCH.md exists for this task — the pattern source is the 260812-pw4
SUMMARY (`ValueListenableBuilder` on `EquipmentRepository.instance.listenable()`), already
loaded in `<context>`.

No unplanned items. No phase split required.
</source_audit>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Pure derivation layer — client summaries, agenda entries, notifications</name>
  <files>lib/data/client_directory.dart, lib/data/derivations.dart, lib/utils/date_labels.dart, test/derivations_test.dart</files>
  <behavior>
    Write `test/derivations_test.dart` FIRST and watch it fail, then implement. These are
    pure unit tests: they build `List&lt;Equipment&gt;` fixtures in memory and never open Hive,
    so no `initHive`/`openBoxes` setup is needed in this file.

    Fixtures must be built RELATIVE to `DateTime.now()` (for example
    `DateTime.now().subtract(const Duration(days: 27))` for an overdue item,
    `DateTime.now().add(const Duration(days: 10))` for an urgent one,
    `DateTime.now().add(const Duration(days: 200))` for an in-day one), because
    `Equipment.isOverdue` and `Equipment.isUrgent` read the system clock internally. Do not
    add a `now` parameter to the derivation functions — reusing the model getters is what
    keeps these screens consistent with the dashboard.

    buildClientSummaries:
    - Two equipment records sharing the client name produce exactly one summary with
      equipmentCount 2.
    - An empty equipment list produces an empty summary list — the static directory alone
      must never materialise a client card (D-03).
    - A client whose equipment is all in-day has agendaCount 0 while equipmentCount stays
      at the real number.
    - nextCalibration on the summary is the EARLIEST nextCalibration in that client's group.
    - A client name absent from the directory still yields a summary, with the placeholder
      CNPJ constant and a null logoAsset.
    - A client name present in the directory yields the directory's CNPJ and asset path.
    - Summaries are ordered most-urgent-first: non-null nextCalibration ascending, then
      entries with a null date, ties broken alphabetically by name.

    buildScheduleEntries:
    - Excludes equipment that is neither overdue nor urgent.
    - Includes both overdue and urgent equipment, sorted by nextCalibration ascending, so
      the most overdue item is first.
    - Maps severity: overdue equipment to the overdue severity, due-within-30-days to the
      urgent severity.
    - daysUntil is negative for an overdue entry.
    - An all-in-day equipment list produces an empty entry list.

    buildNotifications:
    - An overdue record produces one notification whose title marks it as late and whose
      body contains both the equipment name and the client name.
    - An urgent record produces one notification whose title marks it as urgent.
    - An in-day record produces no notification, and an all-in-day list returns empty.
    - Overdue notifications sort before urgent ones.
    - One notification per qualifying equipment — count equals the number of qualifying
      records, so nothing is invented and nothing is collapsed.

    date_labels:
    - formatDayMonth renders a zero-padded day/month pair.
    - relativeDueLabel distinguishes overdue, today, tomorrow and future-days wording.
    - currentWeekDays returns exactly 7 consecutive dates, Monday through Sunday, that
      contain the date passed in.
  </behavior>
  <action>
    Create three small files. Introduce no package dependency — `pubspec.yaml` must not be
    touched (D-01, D-06).

    1. `lib/utils/date_labels.dart` — pure Dart, imports nothing outside `dart:core`.
       Expose: `monthYearLabelPtBr(DateTime)` returning the pt-BR month name plus the year;
       `weekdayAbbrevPtBr(int weekday)` returning the three-letter pt-BR abbreviation for
       `DateTime.monday`..`DateTime.sunday`; `formatDayMonth(DateTime)` returning
       zero-padded `dd/MM`; `relativeDueLabel(int daysUntil)` returning a short pt-BR
       phrase for overdue / today / tomorrow / in N days; and
       `currentWeekDays(DateTime now)` returning the seven `DateTime`s of that Monday-based
       week. Back the name lookups with private `const List&lt;String&gt;` tables indexed by
       month/weekday number — this is why no `intl` dependency is needed.

    2. `lib/data/client_directory.dart` — a `ClientInfo` class with `const` constructor
       holding `cnpj` and `logoAsset`, a `const Map&lt;String, ClientInfo&gt; kClientDirectory`
       keyed by client name, and `ClientInfo? lookupClient(String name)`. Populate the map
       with the six client entries currently passed to `_buildClientCard` in
       `clients_page.dart` — carry over each name, its placeholder CNPJ string and its
       asset path verbatim from those existing call sites, so the six assets already
       declared in `pubspec.yaml` keep resolving. Also export a
       `const String kUnknownClientCnpj` placeholder used when a client is not in the map.
       Add a file-level doc comment stating this is display/identity metadata only, never a
       source of counts (D-02).

    3. `lib/data/derivations.dart` — pure Dart plus the `Equipment` model import ONLY.
       It must NOT import `package:flutter/material.dart` or any Flutter widget/paint type;
       severity travels as `enum CalibrationSeverity { overdue, urgent, ok }` and colours
       stay in the page layer, which is what keeps this file unit-testable.
       Define the single agenda predicate `bool isOnAgenda(Equipment e)` as
       `e.isOverdue || e.isUrgent` and route every other function through it (DISC-A).
       Define `severityOf(Equipment e)` returning overdue / urgent / ok from the same
       getters.
       Define value classes `ClientSummary` (name, cnpj, logoAsset, equipmentCount,
       agendaCount, nextCalibration as nullable, severity), `ScheduleEntry` (equipmentName,
       clientName, nextCalibration, daysUntil, severity) and `AppNotification` (title, body,
       meta, severity).
       Implement `List&lt;ClientSummary&gt; buildClientSummaries(List&lt;Equipment&gt;)` by grouping
       on the raw `Equipment.client` string, counting group size for equipmentCount and the
       `isOnAgenda` subset for agendaCount, taking the earliest `nextCalibration` in the
       group, resolving identity through `lookupClient` with the placeholder fallback, and
       sorting most-urgent-first (D-02, D-03).
       Implement `List&lt;ScheduleEntry&gt; buildScheduleEntries(List&lt;Equipment&gt;)` filtering on
       `isOnAgenda` and sorting by `nextCalibration` ascending, carrying
       `Equipment.daysUntilCalibration` into daysUntil (D-04). Carry no time-of-day field —
       the model has none, and inventing one would re-introduce exactly the fixed data this
       task removes.
       Implement `List&lt;AppNotification&gt; buildNotifications(List&lt;Equipment&gt;)` emitting one
       entry per overdue record and one per urgent record, overdue first then urgent, each
       group by soonest `nextCalibration`. Follow the tone of the two existing hardcoded
       cards in `notifications_page.dart` — a late title with a body naming the equipment,
       the client and the number of days late; an urgent title with a body naming the
       equipment, the client and the due date via `formatDayMonth`. Put the due-date text in
       `meta`; never a wall-clock timestamp (D-05).
  </action>
  <verify>
<!-- planner-discipline-allow: package:flutter -->
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; flutter test test/derivations_test.dart &amp;&amp; flutter analyze 2>&amp;1 | tail -5</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; test "$(grep -E '^import ' lib/data/derivations.dart | grep -c 'package:flutter')" -eq 0</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; git diff --quiet -- pubspec.yaml &amp;&amp; echo "pubspec untouched"</automated>
  </verify>
  <done>`test/derivations_test.dart` passes with the behaviors above covered, `flutter analyze` reports no issues, `lib/data/derivations.dart` imports no Flutter package, and `pubspec.yaml` is unmodified.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Rewire clients_page and schedule_page to the repository</name>
  <files>lib/pages/clients_page.dart, lib/pages/schedule_page.dart, test/pages_derived_test.dart</files>
  <behavior>
    Create `test/pages_derived_test.dart`. Reuse the Hive setup from
    `test/repositories_test.dart` verbatim: a `Directory.systemTemp.createTempSync` temp
    dir in `setUp`, then `initHive(path:)`, `registerAdapters()`, `openBoxes()`, and
    `closeHive()` plus a recursive delete in `tearDown`. Do NOT call `seedIfNeeded()` —
    write controlled fixtures straight into `equipmentsBox` so assertions are exact.

    Fixtures are relative to `DateTime.now()`, as in Task 1.

    Pump each page inside `MaterialApp(home: Scaffold(body: ...))` — `ClientsPage` and
    `SchedulePage` return bare `Column`s and need a Scaffold ancestor.

    Pumping discipline: `FadeSlideIn` schedules a one-shot `Timer` per staggered child, and
    `flutter_test` fails a test that ends with a timer still pending. After
    `pumpWidget`, call `await tester.pump(const Duration(seconds: 2))` to let every
    staggered delay fire, then `await tester.pumpAndSettle()` before asserting.

    Clients page tests:
    - With two Heineken records and one Docol record in the box, the page renders a
      Heineken card showing equipment count 2 and a Docol card showing 1 — the counts are
      read off the box, not off any literal in the page.
    - With an equipment whose client name is not in the directory, that client's card is
      still present, and the page does not throw.
    - With an empty box, no client card renders and the empty-state message is found.

    Schedule page tests:
    - With one overdue, one urgent and one in-day record, exactly the overdue and urgent
      equipment names are found and the in-day equipment name is absent.
    - The calendar heading shows the CURRENT month/year label produced by
      `monthYearLabelPtBr(DateTime.now())`, asserted by calling that function in the test
      rather than by hardcoding a month string.
    - With an all-in-day box, the empty-state message is found.
  </behavior>
  <action>
    Rewrite the data path of both pages; keep the existing visual language (dark palette,
    `FadeSlideIn` stagger, `TapScale`, card radii and spacing) untouched — this is a data
    fix, not a redesign (D-06).

    `lib/pages/clients_page.dart`:
    - Import `hive_ce_flutter`, `../data/equipment_repository.dart`, `../models/equipment.dart`,
      `../data/derivations.dart` and `../utils/date_labels.dart`.
    - Wrap the list region in `ValueListenableBuilder&lt;Box&lt;Equipment&gt;&gt;` on
      `EquipmentRepository.instance.listenable()`, mirroring
      `home_page._buildDashboardListenable()`. Inside the builder call
      `EquipmentRepository.instance.all()` then `buildClientSummaries(...)`, and build one
      card per summary with `ListView.builder`, passing the list index through so the
      existing stagger delay formula still applies.
    - Change `_buildClientCard` to take a `ClientSummary` plus the index. Render name and
      cnpj from the summary; render the EQUIP. stat from `equipmentCount`, the AGEND. stat
      from `agendaCount`, and the PRÓX. stat from `formatDayMonth(nextCalibration)`
      falling back to an em dash when `nextCalibration` is null (D-02, D-03). Delete the six
      literal call sites and the fixed date currently hardcoded in the third stat.
    - Guard the logo: when `summary.logoAsset` is null, render the existing letter-avatar
      container directly instead of calling `Image.asset`; keep the current `errorBuilder`
      fallback for the non-null path.
    - Add a `_buildEmptyState` centered icon + message shown when the summary list is
      empty, styled with the page's existing colours (DISC-C).
    - Leave the decorative search bar and back button exactly as they are.

    `lib/pages/schedule_page.dart`:
    - Same imports and the same `ValueListenableBuilder` wrapper, wrapping the
      `RefreshIndicator`/`ListView` region; keep the `RefreshIndicator` but drop its
      artificial delay body — with a live listenable it has nothing to wait for, so make
      `onRefresh` a no-op async that returns immediately.
    - Build the list from `buildScheduleEntries(EquipmentRepository.instance.all())` via
      `ListView.builder`, preserving the index-based stagger.
    - Change `_buildScheduleItem` to take a `ScheduleEntry` plus the index. The coloured
      badge that currently shows an invented clock time must instead show
      `formatDayMonth(entry.nextCalibration)`, and the small label beneath it must show
      `relativeDueLabel(entry.daysUntil)` — the model carries no time of day, so no clock
      value may be rendered (D-04). Derive the accent colour from `entry.severity` with a
      private helper mapping overdue to the existing red, urgent to the existing amber and
      ok to the existing green; keep those exact colour values.
    - Rewrite `_buildCalendar` to derive from `DateTime.now()`: the heading uses
      `monthYearLabelPtBr(now)` instead of the hardcoded month/year text, and the day strip
      maps `currentWeekDays(now)` through `_buildDayColumn`, using `weekdayAbbrevPtBr` for
      the label, the zero-padded day number, and `isSelected` true only for today's date.
      Leave the month-nav chevrons decorative.
    - Add the same style of empty state for a zero-entry agenda (DISC-C).
  </action>
  <verify>
<!-- planner-discipline-allow: ValueListenableBuilder -->
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; flutter test test/pages_derived_test.dart</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; test "$(grep -vE '^\s*//' lib/pages/clients_page.dart | grep -c '3\.654\.xxx')" -eq 0 &amp;&amp; test "$(grep -vE '^\s*//' lib/pages/schedule_page.dart | grep -c 'Julho 2026')" -eq 0</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; for f in clients_page schedule_page; do test "$(grep -c 'ValueListenableBuilder' lib/pages/$f.dart)" -ge 1 &amp;&amp; test "$(grep -c 'equipment_repository.dart' lib/pages/$f.dart)" -ge 1 || exit 1; done; echo wired</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; flutter analyze 2>&amp;1 | tail -5</automated>
  </verify>
  <done>Both pages rebuild from the equipment box listenable, the clients cards show grouped real counts with an em-dash fallback, the agenda shows only overdue/urgent equipment with date badges and no clock times, the calendar strip tracks the system date, both pages have empty states, `test/pages_derived_test.dart` passes, and `flutter analyze` is clean.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Rewire notifications_page and sweep for remaining fixed data</name>
  <files>lib/pages/notifications_page.dart, test/pages_derived_test.dart</files>
  <behavior>
    Extend `test/pages_derived_test.dart` with a notifications group reusing the same Hive
    setUp/tearDown, fixtures and pumping discipline as Task 2. `NotificationsPage` builds
    its own `Scaffold`, so pump it as `MaterialApp(home: NotificationsPage())`.

    - With one overdue and one urgent record in the box, exactly two notification cards
      render, and the overdue equipment's name appears on screen.
    - With an all-in-day box, no notification card renders and the empty-state message is
      found.
    - The number of cards equals the number of qualifying equipment records — assert
      against `buildNotifications(EquipmentRepository.instance.all()).length` so the widget
      count can never drift from the derivation.
  </behavior>
  <action>
    Rewrite the data path of `lib/pages/notifications_page.dart`, preserving its card
    layout, icon container, colours and stagger exactly (D-06).

    - Import `hive_ce_flutter`, `../data/equipment_repository.dart`, `../models/equipment.dart`
      and `../data/derivations.dart`.
    - Wrap the `ListView` region in `ValueListenableBuilder&lt;Box&lt;Equipment&gt;&gt;` on
      `EquipmentRepository.instance.listenable()` and build from
      `buildNotifications(EquipmentRepository.instance.all())` with `ListView.builder`,
      keeping the index-based stagger delay.
    - Change `_buildNotificationItem` to take an `AppNotification` plus the index. Title and
      body come from the notification; the small top-right slot that currently shows an
      invented wall-clock timestamp shows `notification.meta` instead. Derive colour and
      icon from `notification.severity` via a private helper: the overdue severity keeps the
      existing red plus warning icon, the urgent severity keeps the existing amber plus
      schedule icon.
    - Delete the five literal card call sites, including the three that describe events the
      app has no record of — a completed calibration with a certificate number, a newly
      registered device, and a generated monthly report. Deriving live overdue/urgent state
      is the whole notification feature for this pass; no event log is to be invented (D-05).
    - Add the same style of empty state used on the other two screens for a zero-alert box
      (DISC-C).
    - Final sweep: run the full suite and confirm the 28 tests from 260812-pw4 still pass
      alongside the new ones, and confirm `pubspec.yaml` is still untouched (D-01, D-06).
  </action>
  <verify>
<!-- planner-discipline-allow: ValueListenableBuilder -->
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; flutter test 2>&amp;1 | tail -5</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; test "$(grep -vE '^\s*//' lib/pages/notifications_page.dart | grep -c 'CAL-2026-0847')" -eq 0</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; test "$(grep -c 'ValueListenableBuilder' lib/pages/notifications_page.dart)" -ge 1 &amp;&amp; echo "notifications derived"</automated>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; flutter analyze 2>&amp;1 | tail -5 &amp;&amp; git diff --quiet -- pubspec.yaml &amp;&amp; echo "pubspec untouched"</automated>
  </verify>
  <done>Notifications render one card per overdue/urgent equipment derived from the box, the event-log style cards and wall-clock timestamps are gone, the empty state shows for an all-in-day box, the full suite passes (28 pre-existing tests plus the new ones), `flutter analyze` is clean and `pubspec.yaml` is unmodified.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| equipment form → Hive box | The only untrusted input in this change: client names, equipment names and calibration dates typed by the logged-in technician flow into the derivation layer and are rendered as card text on all three screens. |
| Hive box → derivation layer → UI | Local on-device data crossing into freshly derived aggregate views (counts, agenda, alerts) that previously showed constants. |
| pubspec asset registry → Image.asset | `client_directory.dart` supplies asset paths that the widget layer loads; an unregistered path is a runtime failure surface. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-qyy-01 | Information Disclosure | derivations.dart → all three pages | low | accept | The equipment box is not partitioned per user, so any authenticated technician sees every client's counts and alerts. Accepted: single-tenant internal tool, matches the existing dashboard/equipment list behaviour shipped in 260812-pw4. Revisit only if multi-tenant access is ever requested. |
| T-qyy-02 | Denial of Service | clients_page.dart, schedule_page.dart, notifications_page.dart | low | mitigate | An asset path in `kClientDirectory` that is absent from `pubspec.yaml`, or a null path passed to `Image.asset`, crashes the card build. Mitigated by branching on a null `logoAsset` before `Image.asset` and keeping the existing `errorBuilder` letter-avatar fallback for the non-null path; the six carried-over paths are exactly the ones already declared in `pubspec.yaml`. |
| T-qyy-03 | Tampering | Equipment.client string as directory key | low | mitigate | A client name that differs by whitespace or case silently loses its CNPJ/logo and splits into a second card. Mitigated by keying the lookup on the raw `Equipment.client` string used for grouping (one key, one code path) and by the unit test asserting an unknown name degrades to the placeholder identity rather than throwing or being dropped. |
| T-qyy-04 | Information Disclosure | AppNotification body strings | low | accept | Notification bodies interpolate user-entered equipment and client names into display text. Flutter `Text` renders strings literally with no markup or template interpretation, and nothing here reaches a shell, a web view or a query, so there is no injection sink. Accepted with rationale. |
| T-qyy-05 | Denial of Service | ValueListenableBuilder rebuild path | low | accept | The derivations run O(n) over the whole box on every box write. Accepted: dataset is a local, single-user calibration list in the tens of records; the dashboard already does the same full scan per rebuild. |
| T-qyy-SC | Tampering | npm/pub package installs | high | mitigate | This task installs no packages — the plan forbids touching `pubspec.yaml` (D-01, D-06) and every task verifies it with `git diff --quiet -- pubspec.yaml`. No new supply-chain surface is introduced, so no Package Legitimacy Gate checkpoint applies. If an executor finds it needs a package, it must stop and escalate rather than add one. |
</threat_model>

<verification>
Run from the project root on this Linux dev machine — no emulator required.

1. `flutter analyze` — expect no issues.
2. `flutter test` — expect the 28 tests from 260812-pw4 plus the new
   `derivations_test.dart` and `pages_derived_test.dart` tests, all passing.
3. `git diff --quiet -- pubspec.yaml` — must exit 0 (no dependency added).
4. Fixed-data gates, all scoped to the page files so the static directory keeps its
   legitimate literals:
   - `grep -vE '^\s*//' lib/pages/clients_page.dart | grep -c '3\.654\.xxx'` → 0
   - `grep -vE '^\s*//' lib/pages/schedule_page.dart | grep -c 'Julho 2026'` → 0
   - `grep -vE '^\s*//' lib/pages/notifications_page.dart | grep -c 'CAL-2026-0847'` → 0
5. Wiring gates — each of the three page files contains `ValueListenableBuilder` and
   imports `data/equipment_repository.dart`.

<human-check>
Deferred to end-of-phase review (`workflow.human_verify_mode: end-of-phase`), and it is
the one thing automation here cannot cover — the same manual gap flagged in the
260812-pw4 summary.

1. `flutter run` on a device or emulator, log in, and open the Clientes tab. Confirm the
   client cards match the equipment actually in the app: the equipment counts should sum
   to the total shown on the dashboard.
2. Create a new equipment from the form with a brand-new client name. Return to Clientes
   and confirm a new card appeared with a letter avatar and placeholder CNPJ, and that
   the counts changed without restarting the app.
3. Delete an equipment and confirm its client's counts drop immediately, and that a
   client left with zero equipment disappears from the list rather than showing zeros.
4. Open the Agenda tab. Confirm the calendar heading shows the CURRENT month and year and
   that today is the highlighted day, and that every listed item shows a real due date
   with no clock time.
5. Open Notificações from the dashboard. Confirm each alert names an equipment that is
   genuinely overdue or urgent, and that nothing claims a completed calibration or a
   generated report.
6. Confirm each of the three screens shows a readable empty state rather than a blank
   area when its list is empty.
</human-check>
</verification>

<success_criteria>
- [ ] `lib/data/derivations.dart`, `lib/data/client_directory.dart` and
      `lib/utils/date_labels.dart` exist; `derivations.dart` imports no Flutter package.
- [ ] `clients_page.dart`, `schedule_page.dart` and `notifications_page.dart` each rebuild
      from `EquipmentRepository.instance.listenable()`.
- [ ] Client cards show grouped real counts and the earliest real next-calibration date;
      a client with no equipment does not appear at all.
- [ ] An unknown client name renders with placeholder identity and a letter avatar without
      throwing.
- [ ] The agenda lists only overdue/urgent equipment, sorted earliest first, with date
      badges and relative labels and no invented clock times.
- [ ] The calendar strip is derived from the system date, with today highlighted.
- [ ] Notifications are one-per-overdue and one-per-urgent equipment; the event-log cards
      are deleted.
- [ ] All three screens have an intentional empty state.
- [ ] `flutter analyze` clean; `flutter test` green including the 28 pre-existing tests.
- [ ] `pubspec.yaml` unchanged — no new dependency.
- [ ] Every threat in the register has a severity and a disposition.
</success_criteria>

<output>
Create `.planning/2026-08/12/remover-dados-fixos-de-clients-page-dart/260812-qyy-SUMMARY.md` when done.
</output>
    <automated>cd /home/joaofiorentin/Desktop/PROJETOS/tecnoiso &amp;&amp; test "$(grep -vE '^\s*//' lib/pages/notifications_page.dart | grep -c 'CAL-2026-0847')" -eq 0 &amp;&amp; test "$(grep -c 'ValueListenableBuilder' lib/pages/notifications_page.dart)" -ge 1