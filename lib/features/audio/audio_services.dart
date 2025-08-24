import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:needu/core/globals.dart'; // for `auth`
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioServices2 {
  AudioServices2._();
  static final AudioServices2 instance = AudioServices2._();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? lastFilePath; // absolute local path

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Build a unique, human-readable filename.
  String _makeFileName(DateTime now) =>
      'rec_${now.hour}.${now.minute}.${now.second}.m4a';

  /// Where to save temp recordings (absolute dir).
  Future<String> _recordingDir() async {
    final dir = await getTemporaryDirectory();
    final recDir = Directory('${dir.path}/needu_recordings');
    if (!recDir.existsSync()) recDir.createSync(recursive: true);
    return recDir.path;
  }

  /// Start recording to an absolute path. Returns the absolute local path.
  Future<String?> startRecording() async {
    if (!await _recorder.hasPermission()) return null;

    final now = DateTime.now();
    final dir = await _recordingDir();
    final absolutePath = '$dir/${_makeFileName(now)}';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc, // m4a-friendly
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: absolutePath, // ✅ absolute file path
    );

    lastFilePath = absolutePath;
    if (kDebugMode) print('started: $absolutePath');
    return absolutePath;
  }

  /// Stop recording and return the absolute path to the file.
  Future<String?> stopRecording() async {
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop(); // absolute path or null
        if (path != null) {
          lastFilePath = path;
          if (kDebugMode) print('stopped: $path');
          return path;
        }
      }
    } catch (e) {
      debugPrint('stopRecording error: $e');
    }
    return lastFilePath;
  }

  /// Play the last recorded file (from disk).
  Future<void> playRecording() async {
    if (lastFilePath == null) return;
    final f = File(lastFilePath!);
    if (!f.existsSync()) return;

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(lastFilePath!));
    } catch (e) {
      debugPrint('playRecording error: $e');
    }
  }

  /// Upload a local file to Firebase Storage. Returns the download URL.
  Future<String?> uploadRecording(String? localPath) async {
    if (localPath == null) return null;

    final f = File(localPath);
    if (!f.existsSync()) {
      debugPrint('uploadRecording: file not found at $localPath');
      return null;
    }

    final uid = auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('uploadRecording: no authenticated user');
      return null;
    }

    final now = DateTime.now();
    final datePath = '${now.year}-${now.month}-${now.day}';
    final fileName = 'rec_${now.hour}.${now.minute}.${now.second}.m4a';

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'sos_recordings/$uid/Triggered_on_$datePath/$fileName',
      );

      await ref.putFile(f);
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      debugPrint('uploadRecording error: $e');
      return null;
    }
  }

  /// One-shot helper: record N seconds, stop, upload.
  Future<String?> recordAndUpload({int seconds = 5}) async {
    final started = await startRecording();
    if (started == null) return null;

    await Future.delayed(Duration(seconds: seconds));
    final finalPath = await stopRecording();
    if (finalPath == null) return null;

    return uploadRecording(finalPath);
  }

  /// Record in chunks (uploads each chunk ASAP). Returns URLs for uploaded chunks.
  Future<List<String>> recordInSafeChunks({
    int totalDurationSeconds = 30,
    int chunkDurationSeconds = 5,
  }) async {
    final urls = <String>[];
    final chunks = (totalDurationSeconds / chunkDurationSeconds).ceil();

    for (int i = 0; i < chunks; i++) {
      final started = await startRecording();
      if (started == null) {
        debugPrint('Permission denied or failed to start recording.');
        break;
      }

      await Future.delayed(Duration(seconds: chunkDurationSeconds));

      final finalPath = await stopRecording();
      if (finalPath == null) continue;

      final url = await uploadRecording(finalPath);
      if (url != null) {
        urls.add(url);
        debugPrint('Uploaded chunk ${i + 1}: $url');
      }
    }
    return urls;
  }
}
