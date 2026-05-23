import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class LocalUser {
  final String uid;
  final String email;
  String? displayName;

  LocalUser({required this.uid, required this.email, this.displayName});
}

class FirebaseAuthService {
  // kept the class name so the rest of the app needs minimal changes
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  LocalUser? _currentUser;
  LocalUser? get currentUser => _currentUser;

  // Simple path to the local DB file
  Future<File> get _localDbFile async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/local_db.json');
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode({'users': {}, 'favorites': {}}));
    }
    return file;
  }

  Future<Map<String, dynamic>> _readDb() async {
    final f = await _localDbFile;
    final content = await f.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> _writeDb(Map<String, dynamic> data) async {
    final f = await _localDbFile;
    await f.writeAsString(jsonEncode(data));
  }

  String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  Future<void> signIn(String email, String password) async {
    final db = await _readDb();
    final users = (db['users'] ?? {}) as Map<String, dynamic>;
    final hashed = _hash(password);
    for (final entry in users.entries) {
      final uid = entry.key;
      final data = Map<String, dynamic>.from(entry.value as Map);
      if (data['email'] == email.trim() && data['passwordHash'] == hashed) {
        _currentUser = LocalUser(
            uid: uid, email: data['email'] as String, displayName: data['displayName'] as String?);
        return;
      }
    }
    throw Exception('Invalid email or password.');
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    final age = _calculateAge(birthDate);
    if (age < 13) throw Exception('You must be at least 13 years old to create an account.');

    final db = await _readDb();
    final users = Map<String, dynamic>.from(db['users'] ?? {});

    // ensure email not already used
    for (final e in users.values) {
      if ((e as Map)['email'] == email.trim()) throw Exception('Email already in use.');
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final displayName = '$firstName $lastName';

    users[uid] = {
      'email': email.trim(),
      'displayName': displayName,
      'passwordHash': _hash(password),
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    db['users'] = users;
    await _writeDb(db);

    _currentUser = LocalUser(uid: uid, email: email.trim(), displayName: displayName);
  }

  Future<void> sendPasswordReset(String email) async {
    // Local: not implementing email sending. Provide a helpful message instead.
    throw Exception('Password reset not supported for local backend.');
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<UserModel?> fetchUserModel() async {
    final uid = _currentUser?.uid;
    if (uid == null) return null;
    final db = await _readDb();
    final users = Map<String, dynamic>.from(db['users'] ?? {});
    if (!users.containsKey(uid)) return null;
    final data = Map<String, dynamic>.from(users[uid]);
    return UserModel.fromFirestoreMap(uid, {
      'firstName': data['firstName'],
      'lastName': data['lastName'],
      'birthDate': data['birthDate'],
      'createdAt': data['createdAt'],
    });
  }

  Future<String?> checkUserDocAccess() async {
    final uid = _currentUser?.uid;
    if (uid == null) return 'No authenticated user.';
    final db = await _readDb();
    final users = Map<String, dynamic>.from(db['users'] ?? {});
    if (!users.containsKey(uid)) return 'User document does not exist.';
    return null;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
