import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/firebase_auth_service.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  static const _prefixDaily = 'daily_seconds_';
  static const _prefixPlayCount = 'play_count_';
  static const _defaultGoalHours = 20;

  Future<File> get _localDbFile async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/local_db.json');
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode({'users': {}, 'favorites': {}, 'stats': {}}));
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

  /// Record [seconds] of listening for [trackId] on today's date into local DB.
  Future<void> recordPlay(String trackId, int seconds) async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null || seconds <= 0) return;

    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final userStats = Map<String, dynamic>.from(stats[uid] ?? {});
    final tracking = Map<String, dynamic>.from(userStats['tracking'] ?? {});

    final dayKey = _dailyKey(DateTime.now());
    final countKey = '$_prefixPlayCount$trackId';

    tracking[dayKey] = ((tracking[dayKey] as int?) ?? 0) + seconds;
    tracking[countKey] = ((tracking[countKey] as int?) ?? 0) + 1;

    userStats['tracking'] = tracking;
    stats[uid] = userStats;
    db['stats'] = stats;
    await _writeDb(db);
  }

  Future<int> getTotalListeningSeconds() async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null) return 0;
    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final tracking = Map<String, dynamic>.from(stats[uid]?['tracking'] ?? {});
    int total = 0;
    for (final key in tracking.keys) {
      if (key.startsWith(_prefixDaily)) {
        total += (tracking[key] as int?) ?? 0;
      }
    }
    return total;
  }

  Future<Map<int, double>> getDailyMinutesThisMonth() async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    final Map<int, double> result = {};
    if (uid == null) return result;

    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final tracking = Map<String, dynamic>.from(stats[uid]?['tracking'] ?? {});

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final key = _dailyKey(date);
      final seconds = (tracking[key] as int?) ?? 0;
      result[day] = seconds / 60.0;
    }
    return result;
  }

  Future<List<MapEntry<String, int>>> getMostPlayedTracks() async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null) return [];
    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final tracking = Map<String, dynamic>.from(stats[uid]?['tracking'] ?? {});
    final entries = <MapEntry<String, int>>[];
    for (final key in tracking.keys) {
      if (key.startsWith(_prefixPlayCount)) {
        final trackId = key.replaceFirst(_prefixPlayCount, '');
        final count = (tracking[key] as int?) ?? 0;
        entries.add(MapEntry(trackId, count));
      }
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Future<int> getMonthlyGoalHours() async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null) return _defaultGoalHours;
    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final config = Map<String, dynamic>.from(stats[uid]?['config'] ?? {});
    return (config['monthly_goal_hours'] as int?) ?? _defaultGoalHours;
  }

  Future<void> setMonthlyGoalHours(int hours) async {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null) return;
    final db = await _readDb();
    final stats = Map<String, dynamic>.from(db['stats'] ?? {});
    final userStats = Map<String, dynamic>.from(stats[uid] ?? {});
    final config = Map<String, dynamic>.from(userStats['config'] ?? {});
    config['monthly_goal_hours'] = hours;
    userStats['config'] = config;
    stats[uid] = userStats;
    db['stats'] = stats;
    await _writeDb(db);
  }

  String _dailyKey(DateTime date) {
    return '$_prefixDaily${date.year}_${date.month}_${date.day}';
  }

  Future<double> getThisMonthListeningHours() async {
    final dailyMinutes = await getDailyMinutesThisMonth();
    final totalMinutes = dailyMinutes.values.fold<double>(0.0, (a, b) => a + b);
    return totalMinutes / 60.0;
  }

  static String formatSeconds(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
