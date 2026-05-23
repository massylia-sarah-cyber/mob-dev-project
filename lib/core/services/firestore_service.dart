import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/track.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final Map<String, StreamController<List<Track>>> _streamControllers = {};

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

  // ─────────────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────────────

  Stream<List<Track>> favoritesStream(String uid) {
    if (!_streamControllers.containsKey(uid)) {
      _streamControllers[uid] = StreamController<List<Track>>.broadcast();
      // emit initial value
      getFavorites(uid).then((list) => _streamControllers[uid]!.add(list));
    }
    return _streamControllers[uid]!.stream;
  }

  Future<void> addFavorite(String uid, Track track) async {
    final db = await _readDb();
    final favs = Map<String, dynamic>.from(db['favorites'] ?? {});
    final userFavs = Map<String, dynamic>.from(favs[uid] ?? {});
    userFavs[track.id] = track.toMap();
    favs[uid] = userFavs;
    db['favorites'] = favs;
    await _writeDb(db);
    _streamControllers[uid]?.add(await getFavorites(uid));
  }

  Future<void> removeFavorite(String uid, String trackId) async {
    final db = await _readDb();
    final favs = Map<String, dynamic>.from(db['favorites'] ?? {});
    final userFavs = Map<String, dynamic>.from(favs[uid] ?? {});
    userFavs.remove(trackId);
    favs[uid] = userFavs;
    db['favorites'] = favs;
    await _writeDb(db);
    _streamControllers[uid]?.add(await getFavorites(uid));
  }

  Future<bool> isFavorite(String uid, String trackId) async {
    final db = await _readDb();
    final favs = Map<String, dynamic>.from(db['favorites'] ?? {});
    final userFavs = Map<String, dynamic>.from(favs[uid] ?? {});
    return userFavs.containsKey(trackId);
  }

  Future<List<Track>> getFavorites(String uid) async {
    final db = await _readDb();
    final favs = Map<String, dynamic>.from(db['favorites'] ?? {});
    final userFavs = Map<String, dynamic>.from(favs[uid] ?? {});
    return userFavs.entries
        .map((e) => Track.fromFirestoreMap(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
  }
}
