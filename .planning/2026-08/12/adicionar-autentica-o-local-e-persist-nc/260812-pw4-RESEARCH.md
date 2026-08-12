# Quick Task 260812-pw4: Local Auth + Hive Persistence - Research

**Researched:** 2026-08-12
**Domain:** Flutter local persistence (Hive) + local password auth (no backend)
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Persistence: local, in-app via Hive. No backend/API in this pass.
- On first launch, seed the Hive box with the current mocked equipment list
  (same equipment shown today) so the demo/UI looks the same but is now
  backed by real, editable data.
- Auth: local login (username/password). Support **multiple users** with a
  registration screen (not a single hardcoded user) — sign up + login,
  credentials hashed and stored on-device (Hive or secure storage).
- Login/registration gates access to the app (shown before/instead of
  intro_page or right after it — Claude's discretion on exact placement, as
  long as unauthenticated users cannot reach home/equipment/client screens).
- Deadline: tight (days). Prioritize the minimum that resolves the
  professor's two points cleanly — avoid scope creep (no backend, no API
  integration, no advanced auth like JWT/OAuth).

### Claude's Discretion
- Exact Hive box/model schema for User and Equipment.
- Password hashing approach (any reasonable local hash, e.g. crypto package
  bundled with Flutter — avoid adding heavy new dependencies given the
  deadline).
- Exact placement of login/registration flow relative to `intro_page.dart`.
- Whether `equipment_detail_page.dart`, `clients_page.dart`,
  `schedule_page.dart`, `notifications_page.dart` need updates to read from
  the new repository — scope to what's needed to remove the mock-data
  duplication and keep the app functional end-to-end.

### Deferred Ideas (OUT OF SCOPE)
None recorded in CONTEXT.md — no backend/API, no JWT/OAuth, no heavy new
dependencies.
</user_constraints>

## Summary

The app currently has zero persistence (mock lists rebuilt on every
`initState`) and zero auth gate (`IntroPage` → `HomePage` directly). Both
gaps are addressed with a single, low-friction addition: **`hive_ce` +
`hive_ce_flutter`** for on-device storage of two simple models (`User`,
`Equipment`), plus the already-transitively-present **`crypto`** package for
salted SHA-256 password hashing. The original `hive`/`hive_flutter`
packages are abandoned (last published 2022-06-30) — `hive_ce` is the
actively maintained fork (last published 2026-02-03, 160/160 pub points,
~880K downloads/30 days) and is the correct choice for a project that
still needs to work in 2026.

Given the tight deadline, the single highest-leverage decision is to **skip
`hive_ce_generator` + `build_runner` entirely** and hand-write two
`TypeAdapter<T>` classes (~15 lines each, mechanical field-by-field
read/write). With only two models this is less total effort than wiring up
codegen (dependency install, `part` directives, running/re-running
`build_runner build` on every model change) and removes an entire class of
"forgot to regenerate" bugs before a demo.

**Primary recommendation:** Add `hive_ce` + `hive_ce_flutter` + `crypto`
(3 packages, 1 already present transitively), hand-write two
`TypeAdapter`s, initialize Hive in `main()` before `runApp`, build one
`EquipmentRepository` (singleton over a Hive box) that both
`home_page.dart` and `equipment_list_page.dart` read from, and one
`AuthRepository`/`AuthService` (Hive box of `User` + salted-hash check) with
a new `LoginPage`/`RegisterPage` inserted between `IntroPage` and
`HomePage`.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Equipment data storage/CRUD | Local Storage (Hive box) | Repository (Dart singleton) | No backend in scope; Hive box is the persistence layer, repository is the app-facing API |
| Equipment list rendering | Browser/Client (Flutter widgets) | Repository | `home_page.dart` / `equipment_list_page.dart` become pure consumers of `EquipmentRepository` |
| User credential storage | Local Storage (Hive box) | Repository | Passwords never leave device; no backend to validate against |
| Password verification | Repository/Service (Dart) | — | Hashing/compare logic lives in `AuthService`, not in widgets |
| Session/auth gate | Client (root widget routing) | Repository (reads "current user" state) | `main.dart`/a root `AuthGate` widget decides Login vs Home based on repository state |

This is a single-tier (client-only) Flutter app for this pass — there is no
SSR/API/CDN tier. All "primary tier" entries above collapse to
**Client + on-device storage**, which matches the locked "no backend"
decision.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `hive_ce` | ^2.19.3 | Core NoSQL key-value box engine | Actively maintained fork of Hive; original `hive` package is abandoned (last publish 2022-06-30) [VERIFIED: pub.dev registry] |
| `hive_ce_flutter` | ^2.3.4 | Flutter bindings (`Hive.initFlutter()`, box lifecycle tied to app dir via `path_provider`) | Companion package to `hive_ce`, mirrors old `hive_flutter` API [VERIFIED: pub.dev registry] |
| `crypto` | ^3.0.7 | SHA-256 hashing for passwords | Official Dart-team package, already a transitive dependency in this project's `pubspec.lock`; zero new install cost, no native code [VERIFIED: pub.dev registry] |

### Supporting

None required. No `hive_ce_generator`, no `build_runner`, no
`flutter_secure_storage` — see rationale below.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `hive_ce` (manual adapters) | `hive_ce` + `hive_ce_generator` + `build_runner` (`@GenerateAdapters`) | Codegen removes adapter boilerplate but adds a dev-dependency, a `part` file per model, and a `dart run build_runner build` step that must be re-run on every model field change — unnecessary friction for 2 small models under deadline pressure [CITED: github.com/IO-Design-Team/hive_ce_docs] |
| `hive_ce` (plain box) | `hive_ce` encrypted box (`HiveAesCipher`) | Encryption at rest is nice-to-have for a credentials box, but adds key-management complexity (where does the AES key live?) that isn't justified for an internal single-device tool with hashed (not plaintext) passwords already stored — out of scope per "avoid heavy new dependencies" |
| `crypto` (SHA-256 + salt) | `bcrypt`/`argon2`/`crypt` package | bcrypt/argon2 are the correct choice for internet-facing production auth (deliberately slow, resist brute force), but add new dependencies and complexity the user explicitly asked to avoid; SHA-256+salt is a reasonable minimum for a local, non-networked internal tool per the locked decision text ("any reasonable local hash, e.g. crypto package") [ASSUMED — security tradeoff accepted by user's explicit wording, not independently re-verified as sufficient for production] |
| Hive box for credentials | `flutter_secure_storage` | Explicitly allowed by CONTEXT.md ("Hive or secure storage") but `flutter_secure_storage` requires `libsecret`/keyring integration on Linux desktop (this dev machine) and platform channels on mobile — more moving parts to debug under deadline; a Hive box storing only salted hashes (never plaintext) is adequate for this use case |

**Installation:**
```bash
flutter pub add hive_ce hive_ce_flutter crypto
```
(`crypto` is likely already resolved in `pubspec.lock` as a transitive dep;
`flutter pub add` will still pin it explicitly in `pubspec.yaml`, which is
correct — don't rely on transitive resolution for a package you use
directly.)

**Version verification:** Confirmed live against pub.dev API on
2026-08-12:
- `hive_ce` 2.19.3, published 2026-02-03, SDK constraint `^3.4.0` (project
  uses Dart `^3.12.1` — compatible)
- `hive_ce_flutter` 2.3.4, published 2026-01-09
- `crypto` 3.0.7, published 2025-11-04
- `hive` (original) 2.2.3, published 2022-06-30 — 4+ years stale, do not use

## Package Legitimacy Audit

> Ecosystem is pub.dev (Dart/Flutter), not npm/PyPI/crates — the
> `gsd-tools package-legitimacy check` command does not cover this
> ecosystem. Verification below was performed directly against the pub.dev
> registry API (`https://pub.dev/api/packages/<name>` and
> `/score`), which is the authoritative source for this ecosystem
> (equivalent rigor to `npm view`).

| Package | Registry | Age | Downloads (30d) | Source Repo | Pub Score | Verdict | Disposition |
|---------|----------|-----|------------------|--------------|-----------|---------|-------------|
| `hive_ce` | pub.dev | latest published 2026-02-03 (package family active since ~2024) | ~882,397 | github.com/IO-Design-Team/hive_ce | 160/160, verified publisher `iodesignteam.com` | OK | Approved |
| `hive_ce_flutter` | pub.dev | latest published 2026-01-09 | (companion to hive_ce) | github.com/IO-Design-Team/hive_ce | verified publisher | OK | Approved |
| `crypto` | pub.dev | long-standing dart-lang org package | 10,425,574 | github.com/dart-lang/tools | 160/160 | OK | Approved |

**Packages removed due to SLOP verdict:** none
**Packages flagged as suspicious [SUS]:** none — all three are
well-established, high-download, verified-publisher packages. Package names
were confirmed directly against the live pub.dev registry in this session
(not solely from training data/WebSearch), so they carry `[VERIFIED:
pub.dev registry]` status rather than `[ASSUMED]`.

## Architecture Patterns

### System Architecture Diagram

```
main() [async]
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  ├─ await Hive.initFlutter()
  ├─ Hive..registerAdapter(EquipmentAdapter())..registerAdapter(UserAdapter())
  ├─ await EquipmentRepository.instance.init()   ──► opens 'equipments' box, seeds mock data if empty
  ├─ await AuthRepository.instance.init()         ──► opens 'users' box + 'session' box
  └─ runApp(TecnoisoApp())
        │
        ▼
   AuthGate (StatelessWidget, reads AuthRepository.currentUser)
        │
   ┌────┴─────┐
   │           │
no session   session exists
   │           │
   ▼           ▼
IntroPage → LoginPage ──(register link)──► RegisterPage    HomePage
   │              │                              │             │
   │         AuthService.login(user,pass)   AuthService     reads
   │         → hash+compare against Hive     .register()   EquipmentRepository
   │           'users' box → on success            │        .getAll() (no
   │           write session, navigate Home        │         more per-page
   └──────────────────────────────────────────────►┘         mock lists)
                                                               │
                                                               ▼
                                                    EquipmentListPage (same
                                                    repository instance —
                                                    single source of truth)
```

### Recommended Project Structure
```
lib/
├── models/
│   ├── equipment.dart          # existing — add HiveType annotations OR keep plain + adapter maps fields
│   └── user.dart                # NEW — id, username, passwordHash, salt
├── adapters/
│   ├── equipment_adapter.dart   # NEW — hand-written TypeAdapter<Equipment>, typeId 0
│   └── user_adapter.dart        # NEW — hand-written TypeAdapter<User>, typeId 1
├── repositories/
│   ├── equipment_repository.dart # NEW — CRUD over Hive box 'equipments', seeds mock data on first run
│   └── auth_repository.dart      # NEW — CRUD over Hive box 'users' + session box, hash/verify
├── pages/
│   ├── login_page.dart          # NEW
│   ├── register_page.dart       # NEW
│   ├── intro_page.dart          # existing — navigates to AuthGate/Login instead of Home
│   ├── home_page.dart           # MODIFIED — reads EquipmentRepository instead of _getMockEquipments()
│   └── equipment_list_page.dart # MODIFIED — same
└── main.dart                    # MODIFIED — async main, Hive init, adapter registration, AuthGate root
```

### Pattern 1: Hand-written TypeAdapter (no build_runner)
**What:** Extend `TypeAdapter<T>`, implement `read`/`write` manually,
assign a unique `typeId` (0–223 reserved for app use).
**When to use:** Simple models with a fixed, small field set — exactly this
project's `Equipment` (11 fields) and new `User` (a handful of fields).
**Example:**
```dart
// Source: pattern derived from hive_ce_docs (github.com/IO-Design-Team/hive_ce_docs)
// and hive core TypeAdapter API — DateTime is a natively supported Hive
// type, no special handling needed inside read/write.
class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 0;

  @override
  Equipment read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      id: fields[0] as String,
      name: fields[1] as String,
      client: fields[2] as String,
      type: fields[3] as String,
      brand: fields[4] as String,
      model: fields[5] as String,
      serialNumber: fields[6] as String,
      lastCalibration: fields[7] as DateTime,
      nextCalibration: fields[8] as DateTime,
      status: fields[9] as String,
      certificateId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.client)
      ..writeByte(3)..write(obj.type)
      ..writeByte(4)..write(obj.brand)
      ..writeByte(5)..write(obj.model)
      ..writeByte(6)..write(obj.serialNumber)
      ..writeByte(7)..write(obj.lastCalibration)
      ..writeByte(8)..write(obj.nextCalibration)
      ..writeByte(9)..write(obj.status)
      ..writeByte(10)..write(obj.certificateId);
  }
}
```
This "numbered fields" style (rather than fixed positional read/write)
matches what `hive_ce_generator` itself emits — it is forward-compatible if
a field is added later (old records missing a new field just get `null`
from the map lookup) and safe to copy from official generated-adapter
examples.

### Pattern 2: Hive init before runApp
**What:** `main()` becomes `Future<void> main() async { ... }`, binding is
initialized first, then Hive, then adapters, then boxes are opened, only
then `runApp`.
**When to use:** Always, for any Hive-backed Flutter app — boxes must be
open before any widget tries to read them.
**Example:**
```dart
// Source: pattern confirmed across hive_ce_flutter usage examples
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(EquipmentAdapter())
    ..registerAdapter(UserAdapter());

  await EquipmentRepository.instance.init(); // opens box, seeds mock data if empty
  await AuthRepository.instance.init();      // opens users + session boxes

  runApp(const TecnoisoApp());
}
```

### Pattern 3: Repository as single source of truth
**What:** One `EquipmentRepository` (simple singleton via static
`instance` or a `ChangeNotifier` if list-refresh-on-change is wanted) wraps
`Box<Equipment>` and exposes `getAll()`, `add()`, `update()`, `delete()`,
`seedIfEmpty(List<Equipment> mockData)`.
**When to use:** Both `home_page.dart` and `equipment_list_page.dart` call
`EquipmentRepository.instance.getAll()` in `initState`/`build` instead of
each defining their own `_getMockEquipments()`. This is the direct fix for
the professor's "data is fixed/mocked and duplicated" note.
**Example:**
```dart
// Source: standard repository-over-Hive-box pattern
class EquipmentRepository {
  EquipmentRepository._();
  static final EquipmentRepository instance = EquipmentRepository._();

  late Box<Equipment> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Equipment>('equipments');
    if (_box.isEmpty) {
      for (final e in _seedData()) {
        await _box.put(e.id, e);
      }
    }
  }

  List<Equipment> getAll() => _box.values.toList();
  Future<void> upsert(Equipment e) => _box.put(e.id, e);
  Future<void> delete(String id) => _box.delete(id);

  List<Equipment> _seedData() => [
    // exact same records currently hardcoded in
    // home_page.dart _getMockEquipments() (lines 536-...) —
    // copy verbatim so the demo looks identical on first run.
  ];
}
```

### Anti-Patterns to Avoid
- **Opening the same box twice under different generic types:** `Hive.box<Equipment>('equipments')` after `openBox<Equipment>` is fine, but never open the same box name with two different type parameters — Hive throws at runtime. Keep one repository owning one box/type pairing.
- **Calling `Hive.openBox` inside widget `build()`/`initState()` per page:** this re-triggers the "duplicated mock data" problem in a new form. Open boxes once in `main()`, hand out data via the repository singleton.
- **Storing plaintext passwords "temporarily to save time":** always hash+salt before `box.put`, even for a class project — there is no reason to regress on this given `crypto` costs nothing extra to add.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Binary serialization of Dart objects | Custom JSON-to-file read/write | `hive_ce` `Box<T>` | Hive already handles file I/O, type registry, and native `DateTime`/`List`/`Map` support — a hand-rolled JSON file store would need to solve the same problems worse and slower |
| Salt generation | Manual pseudo-random string | `dart:math` `Random.secure()` generating N random bytes, base64/hex-encoded | `Random.secure()` uses a cryptographically secure RNG; `Random()` (default) does not and must never be used for salts |
| Password comparison | String `==` on hash | Constant-ish comparison isn't critical for a fully local, non-networked app (no timing-attack surface across a network), but still hash-then-compare, never store/compare plaintext | Avoids the actual risk here (stored plaintext), which is what the professor's feedback is about |

**Key insight:** For a local, single-device internal tool, the two things
that actually matter are (1) not showing frozen mock data, and (2) not
storing plaintext credentials. Hive + salted SHA-256 solve exactly those
two things with zero new heavyweight infrastructure — do not reach for
JWT, OAuth, or a real database engine, none of which the deadline or the
professor's feedback calls for.

## Common Pitfalls

### Pitfall 1: `main()` not made `async`, Hive opened after `runApp`
**What goes wrong:** Widgets built by `runApp` try to read a box before
`Hive.openBox` resolves → `HiveError: Box not found. Did you forget to call Hive.openBox()?`
**Why it happens:** Easy to forget when converting `void main()` →
`Future<void> main() async` and to forget `WidgetsFlutterBinding.ensureInitialized()` (required before any plugin call, including `path_provider` used internally by `Hive.initFlutter()`).
**How to avoid:** Always: `ensureInitialized()` → `Hive.initFlutter()` → register adapters → open boxes → `runApp()`, all awaited in sequence before `runApp`.
**Warning signs:** App crashes on cold start only, works fine on hot reload (because boxes are already open in memory from the previous run).

### Pitfall 2: `typeId` collisions
**What goes wrong:** Two adapters registered with the same `typeId` silently overwrite each other's registration or throw `HiveError: Cannot read, unknown typeId`.
**Why it happens:** Manual adapters need manually-assigned unique ids; with only 2 models (`Equipment`=0, `User`=1) this is trivial but must be tracked as more models are added later.
**How to avoid:** Keep a single comment/table listing typeId → model mapping (e.g. at the top of `main.dart` or in a `hive_registrar.dart` file) so future additions don't reuse an id.
**Warning signs:** Data for one model appears corrupted/wrong-typed after adding a second model.

### Pitfall 3: `DateTime` round-trips as local vs UTC unexpectedly
**What goes wrong:** Hive stores `DateTime` including its `isUtc` flag; if you construct dates with `DateTime(2026, 5, 15)` (local) that's fine and consistent, but mixing `DateTime.now()` (local) and `DateTime.now().toUtc()` in different places causes comparison bugs (`isOverdue`, `isUrgent` getters in `Equipment` use `DateTime.now()` directly — keep all stored dates in the same (local) timezone mode to match).
**How to avoid:** Since the existing mock data and getters already use local `DateTime(...)` construction, keep writing local (non-UTC) `DateTime` values when seeding/creating equipment — no change needed, just don't introduce `.toUtc()` anywhere in the new repository code.

### Pitfall 4: Linux desktop dev target and `path_provider`
**What goes wrong:** `Hive.initFlutter()` uses `path_provider` under the hood to locate the app's documents/support directory; on unsupported platforms this throws `MissingPluginException`.
**Why it happens:** Federated plugins need the platform-specific implementation package present.
**How to avoid:** `hive_ce_flutter`'s dependency on `path_provider` already pulls in the Linux federated implementation transitively via `path_provider` (which auto-selects `path_provider_linux` when running on Linux) — this is standard and works out of the box for `flutter run -d linux`. No extra config needed; `hive_ce` pub.dev listing explicitly tags `platform:linux` support [VERIFIED: pub.dev registry score tags]. Verify with a quick `flutter run -d linux` smoke test after adding Hive, since this is the actual dev machine for this project.
**Warning signs:** Works on `flutter run` (mobile emulator) but crashes with a plugin-not-found error when run with `-d linux`.

### Pitfall 5: Registering only one auth "current user" globally when box supports multiple users
**What goes wrong:** Since multiple users are supported (registration screen), don't hardcode a single global logged-in flag inside the `users` box itself (mixing session state with user records). Use a **separate** small Hive box (e.g. `'session'`) or a simple in-memory field for "who is currently logged in" (store just the username/id), so logging out/switching users doesn't require touching user records.
**How to avoid:** Two boxes: `users` (id → `User`), `session` (holds e.g. `currentUserId` or nothing if logged out).

## Code Examples

### Salted SHA-256 password hashing
```dart
// Source: crypto package (pub.dev/packages/crypto) standard usage pattern
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
```

### User model + hand-written adapter
```dart
// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String passwordHash;
  final String salt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
  });
}

// lib/adapters/user_adapter.dart
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return User(
      id: f[0] as String,
      username: f[1] as String,
      passwordHash: f[2] as String,
      salt: f[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.username)
      ..writeByte(2)..write(obj.passwordHash)
      ..writeByte(3)..write(obj.salt);
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `hive` + `hive_flutter` (isar-team) | `hive_ce` + `hive_ce_flutter` (community fork) | `hive` unmaintained since mid-2022; `hive_ce` fork active since ~2024, still receiving releases in 2026 | Original packages still install and technically work today, but receive no bug fixes/Dart-SDK-compat updates — new projects should start on `hive_ce` directly to avoid a migration later |

**Deprecated/outdated:**
- `hive`/`hive_flutter` (pub.dev, last published 2022-06-30): superseded by `hive_ce`/`hive_ce_flutter`. Same API shape, drop-in for this project's needs.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Salted SHA-256 (via `crypto`) is an acceptable password-hashing strength for this specific local, non-networked, internal-tool context (per user's own wording in CONTEXT.md) | Standard Stack / Alternatives Considered | If the professor or a future reviewer expects a slow KDF (bcrypt/argon2) specifically, this would need revisiting — but doing so adds a new dependency the user explicitly wants to avoid under deadline pressure |
| A2 | A single hand-written `TypeAdapter` per model (vs. codegen) will not become unwieldy given the app stays at 2 models for this pass | Architecture Patterns / Pattern 1 | If more Hive-backed models are added later (clients, schedule entries), the manual-adapter approach still works but boilerplate grows linearly — acceptable trade for now, revisit if the model count grows past ~4-5 |

## Open Questions

1. **Should `equipment_detail_page.dart`, `clients_page.dart`, `schedule_page.dart`, `notifications_page.dart` be wired to the repository in this pass?**
   - What we know: CONTEXT.md explicitly leaves this to discretion, scoped to "what's needed to remove the mock-data duplication and keep the app functional end-to-end."
   - What's unclear: Whether `clients_page.dart`/`schedule_page.dart` currently also hardcode their own mock lists (not confirmed in this research pass — only `home_page.dart` and `equipment_list_page.dart` were read in full).
   - Recommendation: Planner should grep those 4 files for `_getMock`/hardcoded lists before deciding scope; if they don't duplicate equipment data (e.g. `equipment_detail_page.dart` just receives an `Equipment` object via constructor from the list pages — confirmed from the file read), they likely need no changes beyond continuing to receive real (not mock) `Equipment` objects, which happens automatically once the list pages are repository-backed.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | whole app | ✓ | 3.44.3 (stable) | — |
| Dart SDK | whole app | ✓ | 3.12.2 | — |
| `flutter run -d linux` desktop target | dev-machine smoke testing (this machine is Linux) | assumed ✓ (not explicitly probed for Linux desktop enablement in this session) | — | If Linux desktop isn't `flutter config --enable-linux-desktop` enabled, planner should add a one-line enable step before first `flutter run -d linux`, or fall back to `flutter test`/an Android emulator if available |

**Missing dependencies with no fallback:** none identified.
**Missing dependencies with fallback:** Linux desktop target enablement (trivial `flutter config` toggle if not already on) — not independently confirmed in this research pass.

## Validation Architecture

No `nyquist_validation` config found (`.planning/config.json` was not
present/read as part of this quick-task's `<files_to_read>` set, and this
is a `gsd-quick` task, not a full phase). No existing test directory or
test framework config was observed in the files read. Given the tight
deadline and quick-task scope, recommend **manual smoke testing** (run app,
register a user, log in, log out, log back in, add/edit an equipment item,
confirm it persists across app restart) rather than standing up a test
framework in this pass. If the planner wants a minimal automated check,
`flutter test` with `flutter_test` (already a dev-dependency) can cover the
`PasswordHasher.hash`/`verify` pure-function logic cheaply without any UI
harness.

## Security Domain

No `security_enforcement` config found for this quick task (no
`.planning/config.json` in the read set). Treating as a lightweight,
best-effort pass appropriate to a student/internal-tool project rather than
a formal ASVS audit:

| Concern | Applies | Standard Control Used Here |
|---------|---------|------------------------------|
| Credential storage | yes | Salted SHA-256 hash via `crypto`, never plaintext, stored in local Hive box (no network exposure) |
| Input validation (login/register forms) | yes | Basic non-empty / min-length checks in the form widgets; username uniqueness check against the `users` box before registering |
| Session handling | yes (locally) | Simple "logged-in user id" marker in a dedicated `session` Hive box; no tokens/JWT needed since there's no server to validate against |
| Transport security | n/a | No network calls in scope |

### Known Threat Patterns

| Pattern | Relevance | Mitigation Used |
|---------|-----------|------------------|
| Plaintext password storage | Directly what the professor flagged as a gap alongside "mock data" | Hash+salt before storing, as designed above |
| Duplicate username registration | Local multi-user support | Check `users` box for existing username before `put` |

## Sources

### Primary (HIGH confidence)
- pub.dev API (`https://pub.dev/api/packages/hive_ce`, `hive_ce_flutter`, `hive`, `crypto`) — live version/publish-date/score verification performed in this session, 2026-08-12
- Direct file reads of this project's `pubspec.yaml`, `main.dart`, `models/equipment.dart`, `pages/home_page.dart`, `pages/equipment_list_page.dart`, `pages/intro_page.dart`, `pages/equipment_detail_page.dart`

### Secondary (MEDIUM confidence)
- github.com/IO-Design-Team/hive_ce_docs (manual TypeAdapter vs `@GenerateAdapters` comparison, `Hive.initFlutter()` usage pattern) — WebSearch-surfaced, cross-checked against pub.dev package metadata for the same publisher
- pub.dev `crypto` package documentation (SHA-256 usage pattern) — WebSearch-surfaced, standard/uncontested API usage

### Tertiary (LOW confidence)
- General blog/Medium sources on Hive vs Hive CE maintenance status — used only to corroborate the pub.dev-verified publish-date gap (2022 vs 2026), not as a standalone source of truth

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — package choice and versions independently verified against live pub.dev registry data, not training-data recall alone
- Architecture: HIGH — patterns (async main + Hive init ordering, repository-over-box, manual TypeAdapter) are standard, low-risk, and directly informed by this project's actual existing file structure
- Pitfalls: MEDIUM — Hive-specific pitfalls are well-documented and cross-checked; the Linux-desktop-target pitfall is flagged but not independently smoke-tested in this research pass (see Open Questions/Environment Availability)

**Research date:** 2026-08-12
**Valid until:** ~2026-09-12 (30 days — Flutter/Dart package ecosystem moves at a moderate pace; re-verify `hive_ce` version if planning is delayed past that window)
