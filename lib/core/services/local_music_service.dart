import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/track.dart';

class LocalMusicService {
  LocalMusicService._();
  static final LocalMusicService instance = LocalMusicService._();

  static const _allowedExtensions = ['mp3', 'm4a', 'wav', 'ogg', 'flac'];

  Future<Directory> _getBaseMusicDirectory() async {
    // Use a local "music" folder in the project root during development.
    final projectMusicDir = Directory(
      '${Directory.current.path}${Platform.pathSeparator}music',
    );
    if (await projectMusicDir.exists()) {
      return projectMusicDir;
    }

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      final home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home != null && home.isNotEmpty) {
        final standardMusicDir = Directory(
          '$home${Platform.pathSeparator}Music',
        );
        if (await standardMusicDir.exists()) {
          return standardMusicDir;
        }

        final appMusicDir = Directory(
          '$home${Platform.pathSeparator}Music${Platform.pathSeparator}mplay',
        );
        return appMusicDir;
      }
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory('${appDocDir.path}${Platform.pathSeparator}music');
  }

  Future<Directory> _ensureMusicDirectory() async {
    final dir = await _getBaseMusicDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<Track>> loadMusicTracks() async {
    final musicDir = await _ensureMusicDirectory();
    final files = musicDir.listSync(recursive: true).whereType<File>().where((
      file,
    ) {
      final ext = file.path.split('.').last.toLowerCase();
      return _allowedExtensions.contains(ext);
    }).toList();

    return files.map((file) {
      final name = file.path.split(Platform.pathSeparator).last;
      final title = name
          .replaceAll('_', ' ')
          .replaceAll('.mp3', '')
          .replaceAll('.m4a', '')
          .replaceAll('.wav', '')
          .replaceAll('.ogg', '')
          .replaceAll('.flac', '');
      return Track(
        id: file.path,
        name: title,
        artistName: 'Zedk',
        albumName: 'Local Music',
        image: '',
        audioUrl: file.path,
        duration: 0,
      );
    }).toList();
  }

  Future<List<Track>> searchMusicTracks(String query) async {
    final tracks = await loadMusicTracks();
    return tracks
        .where(
          (track) => track.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
