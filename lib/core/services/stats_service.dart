import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  static const _prefixDaily = 'daily_seconds_';
  static const _prefixPlayCount = 'play_count_';
  static const _defaultGoalHours = 20;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────
  // Recording
  // ─────────────────────────────────────────────────────

  /// Record [seconds] of listening for [trackId] on today's date into Firestore.
  Future<void> recordPlay(String trackId, int seconds) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || seconds <= 0) return;

    final dayKey = _dailyKey(DateTime.now());
    final countKey = '$_prefixPlayCount$trackId';

    final ref = _db.collection('users').doc(uid).collection('stats').doc('tracking');
    await ref.set({
      dayKey: FieldValue.increment(seconds),
      countKey: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────────────────

  /// Total listening seconds across all tracked days.
  Future<int> getTotalListeningSeconds() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final snap = await _db.collection('users').doc(uid).collection('stats').doc('tracking').get();
    if (!snap.exists) return 0;

    final data = snap.data()!;
    int total = 0;
    for (final key in data.keys) {
      if (key.startsWith(_prefixDaily)) {
        total += (data[key] as num).toInt();
      }
    }
    return total;
  }

  /// Minutes listened per day for the current month.
  /// Returns a map where the key is the day-of-month (1–31).
  Future<Map<int, double>> getDailyMinutesThisMonth() async {
    final uid = _auth.currentUser?.uid;
    final Map<int, double> result = {};
    if (uid == null) return result;

    final snap = await _db.collection('users').doc(uid).collection('stats').doc('tracking').get();
    final data = snap.data() ?? {};

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final key = _dailyKey(date);
      final seconds = (data[key] as num?)?.toInt() ?? 0;
      result[day] = seconds / 60.0;
    }
    return result;
  }

  /// Play counts for all tracked tracks, sorted descending.
  /// Returns list of [trackId, playCount] pairs.
  Future<List<MapEntry<String, int>>> getMostPlayedTracks() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snap = await _db.collection('users').doc(uid).collection('stats').doc('tracking').get();
    final entries = <MapEntry<String, int>>[];
    if (!snap.exists) return entries;

    final data = snap.data()!;
    for (final key in data.keys) {
      if (key.startsWith(_prefixPlayCount)) {
        final trackId = key.replaceFirst(_prefixPlayCount, '');
        final count = (data[key] as num).toInt();
        entries.add(MapEntry(trackId, count));
      }
    }

    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // ─────────────────────────────────────────────────────
  // Monthly goal
  // ─────────────────────────────────────────────────────

  Future<int> getMonthlyGoalHours() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return _defaultGoalHours;

    final snap = await _db.collection('users').doc(uid).collection('stats').doc('config').get();
    return (snap.data()?['monthly_goal_hours'] as num?)?.toInt() ?? _defaultGoalHours;
  }

  Future<void> setMonthlyGoalHours(int hours) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
       await _db.collection('users').doc(uid).collection('stats').doc('config').set({
         'monthly_goal_hours': hours,
       }, SetOptions(merge: true));
    }
  }

  // ─────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────

  String _dailyKey(DateTime date) {
    return '$_prefixDaily${date.year}_${date.month}_${date.day}';
  }

  /// Returns total listening hours for the current month.
  Future<double> getThisMonthListeningHours() async {
    final dailyMinutes = await getDailyMinutesThisMonth();
    final totalMinutes =
        dailyMinutes.values.fold<double>(0.0, (a, b) => a + b);
    return totalMinutes / 60.0;
  }

  /// Formatted string like "4h 23m"
  static String formatSeconds(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
