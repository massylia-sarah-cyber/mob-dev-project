import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../services/local_music_service.dart';

class MusicProvider extends ChangeNotifier {
  final LocalMusicService _musicService = LocalMusicService.instance;
  List<Track> currentTracks = [];
  List<Track> allTracks = [];
  bool isLoading = false;
  Track? currentTrack;

  Future<void> loadPopularTracks() async {
    _setLoading(true);
    allTracks = await _musicService.loadMusicTracks();
    currentTracks = List<Track>.from(allTracks);
    _setLoading(false);
  }

  Future<void> loadGenreTracks(String genre) async {
    _setLoading(true);
    currentTracks = allTracks
        .where((track) => track.name.toLowerCase().contains(genre.toLowerCase()))
        .toList();
    _setLoading(false);
  }

  Future<void> searchTracks(String query) async {
    if (query.trim().isEmpty) return;
    _setLoading(true);
    currentTracks = allTracks
        .where((track) => track.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _setLoading(false);
  }

  void setCurrentTrack(Track track) {
    currentTrack = track;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
