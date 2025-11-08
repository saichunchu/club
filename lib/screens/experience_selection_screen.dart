import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience_model.dart';
import '../providers/experience_provider.dart';
import '../providers/selection_provider.dart';
import '../widgets/experience_card.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_indicator_widget.dart';
import 'onboarding_question_screen.dart';

class ExperienceSelectionScreen extends ConsumerStatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  ConsumerState<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends ConsumerState<ExperienceSelectionScreen>
    with TickerProviderStateMixin {
  final Set<int> _selected = {};
  final TextEditingController _descController = TextEditingController();

  late AnimationController _entryController;
  late AnimationController _reorderController;

  @override
  void initState() {
    super.initState();

    // Entry animation for smooth screen fade-in
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // For reorder + card animation
    _reorderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _entryController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index, List<Experience> experiences) async {
    final e = experiences[index];
    final newList = [...experiences];

    setState(() {
      // toggle multi-select
      if (_selected.contains(e.id)) {
        _selected.remove(e.id);
      } else {
        _selected.add(e.id);
      }
    });

    // Move selected ones to the start
    newList.sort((a, b) {
      final aSel = _selected.contains(a.id);
      final bSel = _selected.contains(b.id);
      if (aSel && !bSel) return -1;
      if (!aSel && bSel) return 1;
      return 0;
    });

    await _reorderController.forward(from: 0);
    ref.read(experiencesProvider.notifier).state = AsyncData(newList);
    ref.read(selectedIdsProvider.notifier).state = _selected.toList();
  }

  @override
  Widget build(BuildContext context) {
    final experiencesState = ref.watch(experiencesProvider);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.base1,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text1, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ProgressIndicatorWidget(currentStep: 1, totalSteps: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.text1, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: experiencesState.when(
        data: (experiences) => _buildAnimatedContent(context, experiences, keyboardVisible),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
        error: (e, _) => Center(
          child: Text('Failed to load experiences', style: AppTextStyles.body1Regular),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(
      BuildContext context, List<Experience> experiences, bool keyboardVisible) {
    return SafeArea(
      child: Stack(
        children: [
          // Pattern background
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

          // Animated content aligned bottom → moves up with keyboard
          AnimatedAlign(
            alignment: keyboardVisible ? Alignment.topCenter : Alignment.bottomCenter,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: keyboardVisible
                    ? MediaQuery.of(context).viewPadding.bottom
                    : 0,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FadeTransition(
                  opacity: _entryController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '01',
                        style: AppTextStyles.subtextRegular.copyWith(
                          color: AppColors.text3,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'What kind of hotspots do you want to host?',
                        style: AppTextStyles.h2Bold.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 24),

                    
                      SizedBox(
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _reorderController,
                          builder: (context, _) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: experiences.length,
                              itemBuilder: (context, idx) {
                                final e = experiences[idx];
                                final selected = _selected.contains(e.id);

                                final scale = selected
                                    ? Tween<double>(begin: 1, end: 1.05)
                                        .animate(CurvedAnimation(
                                          parent: _reorderController,
                                          curve: Curves.elasticOut,
                                        ))
                                        .value
                                    : 1.0;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  margin: EdgeInsets.only(
                                      right: idx == experiences.length - 1 ? 0 : 12),
                                  transform: Matrix4.identity()..scale(scale),
                                  child: ExperienceCard(
                                    imageUrl: e.imageUrl.isNotEmpty
                                        ? e.imageUrl
                                        : 'https://via.placeholder.com/150',
                                    title: e.name,
                                    selected: selected,
                                    onTap: () => _toggleSelection(idx, experiences),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.base2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border2.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _descController,
                          maxLines: 4,
                          maxLength: 250,
                          style: AppTextStyles.body1Regular.copyWith(
                            color: AppColors.text1,
                            fontSize: 15,
                          ),
                          cursorColor: AppColors.primaryAccent,
                          decoration: InputDecoration(
                            hintText: '/ Describe your perfect hotspot',
                            hintStyle: AppTextStyles.subtextRegular.copyWith(
                              color: AppColors.text3.withOpacity(0.5),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                            counterText: '',
                          ),
                          onChanged: (v) =>
                              ref.read(experienceTextProvider.notifier).state = v,
                        ),
                      ),
                      const SizedBox(height: 20),

                      
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.base2,
                            foregroundColor: AppColors.text1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            ref
                                .read(selectedIdsProvider.notifier)
                                .state = _selected.toList();
                            ref
                                .read(experienceTextProvider.notifier)
                                .state = _descController.text;

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    const OnboardingQuestionScreen(),
                                transitionsBuilder:
                                    (context, animation, secondary, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: AppTextStyles.body1Bold.copyWith(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(width: 6),
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
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
