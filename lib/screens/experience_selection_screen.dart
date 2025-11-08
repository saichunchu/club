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
    with SingleTickerProviderStateMixin {
  final Set<int> _selected = {};
  final TextEditingController _descController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _descController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    ref.read(selectedIdsProvider.notifier).state = _selected.toList();
  }

  @override
  Widget build(BuildContext context) {
    final experiencesState = ref.watch(experiencesProvider);

    return Scaffold(
      backgroundColor: AppColors.base1,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppColors.text1, size: 20),
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
        data: (experiences) => _buildContent(context, experiences),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent)),
        error: (e, _) => Center(
          child: Text('Failed to load experiences',
              style: AppTextStyles.body1Regular),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Experience> experiences) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
          
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          kToolbarHeight -
                          keyboardHeight -
                          20, // Add extra buffer for keyboard
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Texts at the top ---
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
                                style:
                                    AppTextStyles.h2Bold.copyWith(fontSize: 26),
                              ),
                              const SizedBox(height: 24),

                              // --- Horizontal Experience Cards ---
                              SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: experiences.length,
                                  itemBuilder: (context, idx) {
                                    final e = experiences[idx];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          right: idx == experiences.length - 1
                                              ? 0
                                              : 12),
                                      child: ExperienceCard(
                                        imageUrl: e.imageUrl.isNotEmpty
                                            ? e.imageUrl
                                            : 'https://via.placeholder.com/150',
                                        title: e.name,
                                        selected: _selected.contains(e.id),
                                        onTap: () => _toggleSelection(e.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- Description TextField ---
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
                                    hintStyle:
                                        AppTextStyles.subtextRegular.copyWith(
                                      color:
                                          AppColors.text3.withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(18),
                                    counterText: '',
                                  ),
                                  onChanged: (v) => ref
                                      .read(experienceTextProvider.notifier)
                                      .state = v,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- Next Button ---
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
                                        transitionsBuilder: (context, animation,
                                            secondary, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          var tween =
                                              Tween(begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
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
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ],)
    );
  }
}