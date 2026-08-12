import '../models/user.dart';
import '../utils/password_hasher.dart';
import 'hive_setup.dart';

/// Distinguishes the reasons an auth operation can fail, so the UI can
/// render "username already taken" separately from "wrong password" without
/// the repository forcing bare booleans on its callers.
enum AuthErrorCode { usernameTaken, invalidCredentials }

/// Thrown by [AuthRepository] on a failed `register` or `login`.
class AuthException implements Exception {
  final AuthErrorCode code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

/// Multi-user local authentication backed by the `users` box for records
/// and the separate `session` box for the active session id — kept apart
/// so multi-user switching never pollutes user records.
class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  /// Registers a new user. Trims the username, rejects a case-insensitive
  /// collision, stores only salt + derived hash, and leaves any existing
  /// users untouched. Throws [AuthException] with
  /// [AuthErrorCode.usernameTaken] when the name is already registered.
  Future<User> register(String username, String password) async {
    final trimmed = username.trim();
    final lower = trimmed.toLowerCase();

    final exists = usersBox.values
        .any((user) => user.username.toLowerCase() == lower);
    if (exists) {
      throw const AuthException(
        AuthErrorCode.usernameTaken,
        'Este nome de usuário já está em uso.',
      );
    }

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final user = User(
      id: id,
      username: trimmed,
      passwordHash: hash,
      salt: salt,
    );
    await usersBox.put(id, user);
    return user;
  }

  /// Logs in with a case-insensitive username lookup. On success writes the
  /// user's id to the session box. On failure changes nothing and throws
  /// [AuthException] with [AuthErrorCode.invalidCredentials] — the same
  /// error for a wrong password and an unknown username, so the caller
  /// cannot be used as a username-enumeration oracle.
  Future<User> login(String username, String password) async {
    final lower = username.trim().toLowerCase();
    User? match;
    for (final user in usersBox.values) {
      if (user.username.toLowerCase() == lower) {
        match = user;
        break;
      }
    }

    if (match == null ||
        !PasswordHasher.verify(password, match.salt, match.passwordHash)) {
      throw const AuthException(
        AuthErrorCode.invalidCredentials,
        'Usuário ou senha inválidos.',
      );
    }

    await sessionBox.put(SessionKeys.currentUserId, match.id);
    return match;
  }

  /// Clears the active session.
  Future<void> logout() async {
    await sessionBox.delete(SessionKeys.currentUserId);
  }

  /// Resolves the stored session id through the users box. Returns null
  /// when there is no session, or when the id dangles at a deleted record —
  /// a stale session degrades to logged-out rather than throwing.
  User? get currentUser {
    final id = sessionBox.get(SessionKeys.currentUserId) as String?;
    if (id == null) return null;
    return usersBox.get(id);
  }
}
