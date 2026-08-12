import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/equipment.dart';
import '../models/user.dart';

/// The ONLY module in the codebase that opens Hive boxes. Opening the same
/// box twice with different type arguments is a crash, and per-page
/// `openBox()` calls are the anti-pattern RESEARCH flags — every screen
/// reads boxes already opened here through the repositories instead.
class HiveBoxNames {
  HiveBoxNames._();

  static const String equipments = 'equipments';
  static const String users = 'users';
  static const String session = 'session';
}

/// Keys stored in the untyped [HiveBoxNames.session] box.
class SessionKeys {
  SessionKeys._();

  static const String currentUserId = 'currentUserId';
  static const String equipmentsSeeded = 'equipmentsSeeded';
}

late Box<Equipment> equipmentsBox;
late Box<User> usersBox;
late Box sessionBox;

/// Initializes the Hive engine. In production (`path == null`) this goes
/// through `Hive.initFlutter()`, which resolves the app's documents
/// directory via `path_provider` — that call throws in `flutter test`, so
/// every test passes an explicit temp directory instead. This `path`
/// parameter is the testability seam.
Future<void> initHive({String? path}) async {
  if (path == null) {
    await Hive.initFlutter();
  } else {
    Hive.init(path);
  }
}

/// Registers both hand-written adapters, guarded so repeated calls (as
/// happen across tests) are safe.
void registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(EquipmentAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserAdapter());
  }
}

/// Opens the three boxes used by the app. Must run after [registerAdapters].
Future<void> openBoxes() async {
  equipmentsBox = await Hive.openBox<Equipment>(HiveBoxNames.equipments);
  usersBox = await Hive.openBox<User>(HiveBoxNames.users);
  sessionBox = await Hive.openBox(HiveBoxNames.session);
}

/// Closes all open boxes. Used by tests to simulate an app restart.
Future<void> closeHive() async {
  await Hive.close();
}
