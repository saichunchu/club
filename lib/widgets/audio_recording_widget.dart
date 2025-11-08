import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../theme/app_theme.dart';

typedef OnRecorded = void Function(String filePath);
typedef OnRecordingStateChanged = void Function(bool isRecording);

class AudioRecorderWidget extends StatefulWidget {
  final OnRecorded onRecorded;
  final VoidCallback? onDeleted;
  final OnRecordingStateChanged? onRecordingStateChanged;

  const AudioRecorderWidget({
    Key? key,
    required this.onRecorded,
    this.onDeleted,
    this.onRecordingStateChanged,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => AudioRecorderWidgetState();
}

class AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final Record _recorder = Record();
  final RecorderController _recorderController = RecorderController();
  final PlayerController _playerController = PlayerController();

  late final StreamSubscription<PlayerState> _playerSub;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _playerSub = _playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        if (state == PlayerState.playing) {
          setState(() => _isPlaying = true);
        } else {
          setState(() => _isPlaying = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorderController.dispose();
    _playerController.dispose();
    _recorder.dispose();
    _playerSub.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRecording && _recordingStartTime != null) {
          setState(() {
            _recordingDuration =
                DateTime.now().difference(_recordingStartTime!);
          });
          _startTimer();
        }
      });
    }
  }

  Future<String> _tempPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  /// Start recording
  Future<void> start() async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) return;

    final path = await _tempPath();
    await _recorder.start(
      path: path,
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
    );
    _recorderController.record();

    _recordingStartTime = DateTime.now();
    _recordingDuration = Duration.zero;

    setState(() {
      _isRecording = true;
      _recordedPath = null;
    });

    _animationController.forward();
    widget.onRecordingStateChanged?.call(true);
    _startTimer();
  }

  /// Stop recording
  Future<String?> stop() async {
    final path = await _recorder.stop();
    _recorderController.stop();

    if (path != null) {
      widget.onRecorded(path);
      _recordedPath = path;
      
      await _playerController.preparePlayer(path: path);
    }

    setState(() {
      _isRecording = false;
      _recordingStartTime = null;
    });

    _animationController.reverse();
    widget.onRecordingStateChanged?.call(false);
    return path;
  }

  /// Delete the recorded file
  Future<void> delete() async {
    if (_recordedPath != null && File(_recordedPath!).existsSync()) {
      File(_recordedPath!).deleteSync();
    }
    await _playerController.stopPlayer();
    setState(() {
      _recordedPath = null;
      _recordingDuration = Duration.zero;
      _isPlaying = false;
    });
    widget.onDeleted?.call();
  }

  /// Toggle audio playback (fixed: no invalid named parameter)
  Future<void> _togglePlayback() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      // pause playback
      await _playerController.pausePlayer();
      
    } else {
      if (!_playerController.playerState.isInitialised) {
        await _playerController.preparePlayer(path: _recordedPath!);
      }
      await _playerController.startPlayer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      // Recording UI
      return Container(
        decoration: BoxDecoration(
          color: AppColors.base2,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recording Audio...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () async => await stop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B7EFF),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AudioWaveforms(
                    enableGesture: false,
                    size: Size(MediaQuery.of(context).size.width - 140, 44),
                    recorderController: _recorderController,
                    waveStyle: const WaveStyle(
                      waveColor: Color(0xFF8B7EFF),
                      extendWaveform: true,
                      showMiddleLine: false,
                      waveThickness: 3,
                      spacing: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isRecording && _recordedPath != null) {
      // Playback UI
      return Container(
        decoration: BoxDecoration(
          color: AppColors.base2,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Audio Recorded',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${_formatDuration(_recordingDuration)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFF8B7EFF), size: 22),
                  onPressed: delete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B7EFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AudioFileWaveforms(
                    size: Size(MediaQuery.of(context).size.width - 140, 44),
                    playerController: _playerController,
                    enableSeekGesture: true,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: Color(0xFF8B7EFF),
                      liveWaveColor: Colors.white,
                      spacing: 6,
                      waveThickness: 3,
                      showSeekLine: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
