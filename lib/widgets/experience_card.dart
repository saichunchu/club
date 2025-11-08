import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExperienceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            // ✅ No border when selected
            border: selected
                ? null
                : Border.all(
                    color: AppColors.border2,
                    width: 1.4,
                  ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: selected
                      ? CachedNetworkImage(
                          key: const ValueKey('color'),
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          height: 120,
                          width: 120,
                          placeholder: (context, _) =>
                              Container(color: AppColors.surfaceBlack3),
                          errorWidget: (context, _, __) => Container(
                            color: AppColors.surfaceBlack2,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : ColorFiltered(
                          key: const ValueKey('gray'),
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            height: 120,
                            width: 120,
                            placeholder: (context, _) =>
                                Container(color: AppColors.surfaceBlack3),
                            errorWidget: (context, _, __) => Container(
                              color: AppColors.surfaceBlack2,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                ),
              ),

              // ✅ Title label (always visible)
              // Positioned(
              //   bottom: 4,
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: Colors.black.withOpacity(0.4),
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: Text(
              //       title.toUpperCase(),
              //       style: AppTextStyles.body2Bold.copyWith(
              //         color: Colors.white,
              //         letterSpacing: 0.5,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
