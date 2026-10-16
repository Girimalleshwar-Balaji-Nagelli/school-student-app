
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../models/subject_model.dart';
import '../../../routes/app_pages.dart';

class SubjectDetailsView extends StatelessWidget {
  const SubjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SubjectModel subject = Get.arguments as SubjectModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLASS 8  •  SECTION B',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subject.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Learning Activities',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              // const SizedBox(height: 14),

              // _buildFeatureCard(
              //   icon: Icons.video_camera_front_rounded,
              //   title: 'Live Classes',
              //   description:
              //   '${subject.liveClassCount} scheduled or available sessions',
              //   count: subject.liveClassCount,
                // onTap: () {
                //   Get.snackbar(
                //     'Live Classes',
                //     'We will implement the Live Classes screen next.',
                //     snackPosition: SnackPosition.BOTTOM,
                //   );
                // },
              //   onTap: () {
              //     Get.toNamed(
              //       AppRoutes.liveClasses,
              //       arguments: subject,
              //     );
              //   },
              // ),

              const SizedBox(height: 14),

              _buildFeatureCard(
                icon: Icons.quiz_rounded,
                title: 'Online Quiz',
                description:
                '${subject.availableQuizCount} assigned or available quizzes',
                count: subject.availableQuizCount,
                onTap: () {
                  Get.toNamed(
                    '/quizzes',
                    arguments: subject,
                  );
                },
              ),
              // _buildFeatureCard(
              //   icon: Icons.video_call_rounded,
              //   title: 'Zoom Live Classes',
              //   description: 'Join interactive classes using Zoom',
              //   count: subject.liveClassCount,
              //   onTap: () {
              //     Get.toNamed(
              //       AppRoutes.zoomLiveClasses,
              //       arguments: subject,
              //     );
              //   },
              // ),


              const SizedBox(height: 14),

              _buildFeatureCard(
                icon: Icons.video_camera_front_rounded,
                title: 'Agora Live Classes',
                description: 'Join live classes powered by Agora',
                count: subject.liveClassCount,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.agoraLiveClasses,
                    arguments: subject,
                  );
                },
              ),


              const SizedBox(height: 28),



              // _buildProgressCard(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View details  →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildProgressCard() {
  //   // Temporary mock progress.
  //   const double progress = 0.60;
  //
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: AppTheme.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: AppTheme.border),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 44,
  //               height: 44,
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFEAF1FF),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Icon(
  //                 Icons.trending_up_rounded,
  //                 color: AppTheme.primaryBlue,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             const Expanded(
  //               child: Text(
  //                 'Course Progress',
  //                 style: TextStyle(
  //                   fontSize: 17,
  //                   fontWeight: FontWeight.w700,
  //                   color: AppTheme.textPrimary,
  //                 ),
  //               ),
  //             ),
  //             const Text(
  //               '60%',
  //               style: TextStyle(
  //                 fontSize: 21,
  //                 fontWeight: FontWeight.bold,
  //                 color: AppTheme.primaryBlue,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 18),
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(10),
  //           child: const LinearProgressIndicator(
  //             value: progress,
  //             minHeight: 8,
  //             backgroundColor: Color(0xFFE2E8F0),
  //             valueColor: AlwaysStoppedAnimation<Color>(
  //               AppTheme.primaryBlue,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         const Text(
  //           'Keep learning and completing your activities.',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: AppTheme.textSecondary,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
