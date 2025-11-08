import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DataSyncSuccessScreen extends StatefulWidget {
  const DataSyncSuccessScreen({Key? key}) : super(key: key);

  @override
  State<DataSyncSuccessScreen> createState() => _DataSyncSuccessScreenState();
}

class _DataSyncSuccessScreenState extends State<DataSyncSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeTextAnimation;
  late Animation<Offset> _slideTextAnimation;
  late Animation<double> _fadeButtonAnimation;
  late Animation<Offset> _slideButtonAnimation;

  @override
  void initState() {
    super.initState();

    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    
    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    
    _fadeTextAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.9, curve: Curves.easeIn),
    );
    _slideTextAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    
    _fadeButtonAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );
    _slideButtonAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base1,
      body: SafeArea(
        child: Stack(
          children: [
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.base1,
                image: DecorationImage(
                  image: const AssetImage('assets/pattern.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.03,
                ),
              ),
            ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated checkmark with glow
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          final glow =
                              8 + (10 * _glowController.value); // subtle pulsing
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.4),
                                  blurRadius: glow,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primaryAccent.withOpacity(0.5),
                                      blurRadius: glow,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 52,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Success text animation
                    FadeTransition(
                      opacity: _fadeTextAnimation,
                      child: SlideTransition(
                        position: _slideTextAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Data Synced Successfully!',
                              style: AppTextStyles.h2Bold.copyWith(
                                fontSize: 26,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Your information has been saved.\nWe\'ll review your application shortly.',
                              style: AppTextStyles.body2Regular.copyWith(
                                color: AppColors.text3,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Button animation
                    FadeTransition(
                      opacity: _fadeButtonAnimation,
                      child: SlideTransition(
                        position: _slideButtonAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Text(
                              'Continue',
                              style: AppTextStyles.body1Bold.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
