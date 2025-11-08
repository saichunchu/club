import 'dart:io';
import 'package:club/screens/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../providers/selection_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_recording_widget.dart';
import '../widgets/progress_indicator_widget.dart';

class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState
    extends ConsumerState<OnboardingQuestionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AudioRecorderWidgetState> _audioRecorderKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  String? _audioPath;
  String? _videoPath;
  String? _videoThumbnailPath;
  Duration? _videoDuration;
  bool _isRecording = false;
  bool _isCapturingVideo = false;

  VideoPlayerController? _videoController;

  late AnimationController _fadeAnimationController;
  late AnimationController _buttonWidthController;
  late Animation<double> _buttonWidthAnimation;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1.0;

    _buttonWidthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _buttonWidthAnimation = CurvedAnimation(
      parent: _buttonWidthController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    _fadeAnimationController.dispose();
    _buttonWidthController.dispose();
    super.dispose();
  }

  Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbPath,
        imageFormat: ImageFormat.PNG,
        maxWidth: 256,
        quality: 90,
      );
      if (thumbnail != null && File(thumbnail).existsSync()) {
        return thumbnail;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> _loadVideo(String path) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(path));
      await _videoController!.initialize();
      final duration = _videoController!.value.duration;
      final thumbnail = await generateVideoThumbnail(path);

      if (mounted) {
        setState(() {
          _videoPath = path;
          _videoDuration = duration;
          _videoThumbnailPath = thumbnail;
          _isCapturingVideo = false;
        });
        _fadeAnimationController.forward();
        _buttonWidthController.reverse();
      }
    } catch (e) {
      debugPrint('❌ Error loading video: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      setState(() => _isCapturingVideo = true);
      _fadeAnimationController.reverse();
      _buttonWidthController.forward();

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final tempDir = await getTemporaryDirectory();
        final copiedPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
        await File(video.path).copy(copiedPath);
        await _loadVideo(copiedPath);
        ref.read(recordedVideoPathProvider.notifier).state = copiedPath;
      } else {
        setState(() => _isCapturingVideo = false);
        _fadeAnimationController.forward();
        _buttonWidthController.reverse();
      }
    } catch (e) {
      setState(() => _isCapturingVideo = false);
      _fadeAnimationController.forward();
      _buttonWidthController.reverse();
    }
  }

  void _toggleAudioRecording() async {
    if (_isRecording) {
      final path = await _audioRecorderKey.currentState?.stop();
      if (path != null && mounted) {
        setState(() {
          _audioPath = path;
          _isRecording = false;
        });
        ref.read(recordedAudioPathProvider.notifier).state = path;
      } else {
        setState(() => _isRecording = false);
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _fadeAnimationController.forward();
        _buttonWidthController.reverse();
      }
    } else {
      _audioRecorderKey.currentState?.start();
      setState(() {
        _audioPath = null;
        _isRecording = true;
      });
      _fadeAnimationController.reverse();
      _buttonWidthController.forward();
    }
  }

  void _handleRecordingStateChanged(bool isRecording) {
    if (mounted) {
      setState(() => _isRecording = isRecording);
      if (!isRecording) {
        _fadeAnimationController.forward();
        _buttonWidthController.reverse();
      }
    }
  }

  String formattedDuration(Duration? d) {
    if (d == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final onboardingText = ref.watch(onboardingTextProvider);
    final bool hasUserInput =
        onboardingText.isNotEmpty || _audioPath != null || _videoPath != null;

    final double keyboardHeight = MediaQuery.of(context).viewPadding.bottom;
    final bool shouldMoveUp =
        keyboardHeight > 0 || _isRecording || _isCapturingVideo;

    return Scaffold(
      backgroundColor: AppColors.base1,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.text1,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ProgressIndicatorWidget(currentStep: 2, totalSteps: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.text1, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background pattern
            Container(
              decoration: BoxDecoration(
                color: AppColors.base1,
                image: DecorationImage(
                  image: const AssetImage('assets/pattern.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.5,
                ),
              ),
            ),

            // Smooth Animated Align (starts bottom, moves up)
            AnimatedAlign(
              alignment:
                  shouldMoveUp ? Alignment.topCenter : Alignment.bottomCenter,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  bottom: shouldMoveUp ? keyboardHeight + 50 : 0,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 750),
                  decoration: BoxDecoration(
                    color: AppColors.base1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Scrollable content
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  '02',
                                  style: AppTextStyles.subtextRegular.copyWith(
                                    color: AppColors.text3,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Why do you want to host with us?',
                                  style:
                                      AppTextStyles.h2Bold.copyWith(fontSize: 24),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tell us about your intent and what motivates you to create experiences.',
                                  style: AppTextStyles.body2Regular.copyWith(
                                    color: AppColors.text3,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Text box
                                TextField(
                                  controller: _controller,
                                  maxLines: 6,
                                  maxLength: 600,
                                  onChanged: (v) => ref
                                      .read(onboardingTextProvider.notifier)
                                      .state = v,
                                  cursorColor: AppColors.primaryAccent,
                                  style: AppTextStyles.body1Regular.copyWith(
                                    color: AppColors.text1,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '/ Start typing here',
                                    filled: true,
                                    fillColor: AppColors.base2,
                                    hintStyle:
                                        AppTextStyles.subtextRegular.copyWith(
                                      color:
                                          AppColors.text3.withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.border2.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.primaryAccent
                                            .withOpacity(0.7),
                                        width: 1.4,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(18),
                                    counterText: '',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (_videoPath != null &&
                                    _videoThumbnailPath != null)
                                  _buildVideoRecordedPreview(
                                    thumbnailPath: _videoThumbnailPath!,
                                    durationText:
                                        formattedDuration(_videoDuration),
                                    onPlay: () async {
                                      if (_videoController != null) {
                                        await _videoController!.play();
                                      }
                                    },
                                    onDelete: () {
                                      setState(() {
                                        _videoPath = null;
                                        _videoThumbnailPath = null;
                                        _videoDuration = null;
                                      });
                                      _videoController?.dispose();
                                      _videoController = null;
                                      ref
                                          .read(recordedVideoPathProvider.notifier)
                                          .state = null;
                                    },
                                  ),

                                AudioRecorderWidget(
                                  key: _audioRecorderKey,
                                  onRecorded: (path) {
                                    setState(() => _audioPath = path);
                                    ref
                                        .read(recordedAudioPathProvider.notifier)
                                        .state = path;
                                  },
                                  onDeleted: () {
                                    setState(() => _audioPath = null);
                                    ref
                                        .read(recordedAudioPathProvider.notifier)
                                        .state = null;
                                  },
                                  onRecordingStateChanged:
                                      _handleRecordingStateChanged,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bottom bar
                        Container(
                          color: AppColors.base1,
                          padding:
                              const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          child: AnimatedBuilder(
                            animation: _buttonWidthAnimation,
                            builder: (context, _) {
                              final showMediaButtons =
                                  !_isRecording && !_isCapturingVideo;
                              return Row(
                                children: [
                                  if (showMediaButtons)
                                    FadeTransition(
                                      opacity: _fadeAnimationController,
                                      child: Row(
                                        children: [
                                          _buildIconButton(
                                            icon: Icons.mic,
                                            active: _isRecording,
                                            onPressed: _toggleAudioRecording,
                                          ),
                                          const SizedBox(width: 12),
                                          _buildIconButton(
                                            icon: Icons.videocam,
                                            active: _isCapturingVideo,
                                            onPressed: _pickVideo,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasUserInput
                                              ? AppColors.primaryAccent
                                              : AppColors.base2.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: hasUserInput
                                            ? () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const DataSyncSuccessScreen(),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Next',
                                              style: AppTextStyles.body1Bold
                                                  .copyWith(
                                                fontSize: 16,
                                                color: hasUserInput
                                                    ? Colors.white
                                                    : AppColors.text3
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Image.asset(
                                              'assets/arrow-big-right-dash.png',
                                              height: 24,
                                              width: 18,
                                              fit: BoxFit.fill,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoRecordedPreview({
    required String thumbnailPath,
    required String? durationText,
    required VoidCallback onDelete,
    required VoidCallback onPlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlay,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: File(thumbnailPath).existsSync()
                      ? Image.file(
                          File(thumbnailPath),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.broken_image, color: Colors.red),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Recorded',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (durationText != null)
                  Text(
                    '• $durationText',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFF8B7EFF),
              size: 22,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.base2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.primaryAccent : AppColors.border2,
          width: active ? 2 : 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: active ? AppColors.primaryAccent : AppColors.text1,
          size: 22,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
