
import 'package:get/get.dart';
import 'package:school_student_app/features/teacher/class_module/views/teacher_login_view.dart';

import '../features/class_section/bindings/class_section_binding.dart';
import '../features/class_section/bindings/assigned_subjects_binding.dart';
import '../features/class_section/views/class_section_view.dart';
import '../features/class_section/views/subjects_view.dart';
import '../features/class_section/views/subject_details_view.dart';
import '../features/class_section/bindings/live_classes_binding.dart';
import '../features/class_section/views/live_classes_view.dart';
import '../features/class_section/bindings/quizzes_binding.dart';
import '../features/class_section/views/quizzes_view.dart';
import '../features/class_section/bindings/quiz_attempt_binding.dart';
import '../features/class_section/views/quiz_attempt_view.dart';
import '../features/class_section/views/quiz_result_view.dart';
import '../features/class_section/bindings/course_progress_binding.dart';
import '../features/class_section/views/course_progress_view.dart';

// Teacher side class
import '../features/teacher/class_module/bindings/teacher_classes_binding.dart';
import '../features/teacher/class_module/views/teacher_classes_view.dart';
import '../features/teacher/class_module/views/teacher_class_details_view.dart';
import '../features/teacher/class_module/views/teacher_subject_view.dart';
import '../features/teacher/class_module/bindings/teacher_live_classes_binding.dart';
import '../features/teacher/class_module/views/teacher_live_classes_view.dart';

import '../features/class_section/views/zoom_live_classes_view.dart';
import '../features/teacher/class_module/views/teacher_zoom_live_classes_view.dart';


import '../features/class_section/views/agora_live_classes_view.dart';
import '../features/teacher/class_module/views/teacher_agora_live_classes_view.dart';
// import '../features/teacher/class_module/views/teacher_chapter_folders_view.dart';
// import '../features/teacher/class_module/views/teacher_chapter_lectures_view.dart';
// import '../features/teacher/class_module/views/teacher_login_view.dart';
import 'package:school_student_app/features/teacher/class_module/bindings/teacher_quizzes_binding.dart';
import 'package:school_student_app/features/teacher/class_module/views/teacher_quizzes_view.dart';
import '../features/teacher/class_module/bindings/teacher_create_quiz_binding.dart';
import '../features/teacher/class_module/views/teacher_create_quiz_view.dart';
import '../features/teacher/class_module/views/teacher_manage_quiz_view.dart';


class AppRoutes {
  AppRoutes._();

  static const String classSection = '/class-section';
  static const String subjects = '/assigned-subjects';
  static const String subjectDetails = '/subject-details';
  static const String liveClasses = '/live-classes';

  static const String teacherClasses = '/teacher-classes';
  static const String teacherClassDetails = '/teacher-class-details';
  static const String teacherSubject = '/teacher-subject';
  static const String teacherLiveClasses = '/teacher-live-classes';

  static const String zoomLiveClasses = '/zoom-live-classes';
  static const String teacherZoomLiveClasses =
      '/teacher-zoom-live-classes';


  static const String agoraLiveClasses = '/agora-live-classes';
  static const String teacherAgoraLiveClasses =
      '/teacher-agora-live-classes';

  static const String teacherChapterFolders =
      '/teacher-chapter-folders';

  static const String teacherChapterLectures =
      '/teacher-chapter-lectures';
  static const String teacherLogin = '/teacher-login';
  static const String teacherQuizzes = '/teacher-quizzes';
  static const String teacherCreateQuiz = '/teacher-create-quiz';
  static const String teacherManageQuiz = '/teacher-manage-quiz';


  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: classSection,
      page: () => const ClassSectionView(),
      binding: ClassSectionBinding(),
    ),
    GetPage(
      name: subjects,
      page: () => const SubjectsView(),
      binding: AssignedSubjectsBinding(),
    ),
    GetPage(
      name: subjectDetails,
      page: () => const SubjectDetailsView(),
    ),
    GetPage(
      name: liveClasses,
      page: () => const LiveClassesView(),
      binding: LiveClassesBinding(),
    ),
    GetPage(
      name: '/quizzes',
      page: () => const QuizzesView(),
      binding: QuizzesBinding(),
    ),
    GetPage(
      name: '/quiz-attempt',
      page: () => const QuizAttemptView(),
      binding: QuizAttemptBinding(),
    ),
    GetPage(
      name: '/quiz-result',
      page: () => const QuizResultView(),
    ),
    GetPage(
      name: '/course-progress',
      page: () => const CourseProgressView(),
      binding: CourseProgressBinding(),
    ),
    GetPage(
      name: teacherClasses,
      page: () => const TeacherClassesView(),
      binding: TeacherClassesBinding(),
    ),
    GetPage(
      name: teacherClassDetails,
      page: () => const TeacherClassDetailsView(),
    ),
    GetPage(
      name: teacherSubject,
      page: () => const TeacherSubjectView(),
    ),
    GetPage(
      name: teacherLiveClasses,
      page: () => const TeacherLiveClassesView(),
      binding: TeacherLiveClassesBinding(),
    ),
    GetPage(
      name: zoomLiveClasses,
      page: () => const ZoomLiveClassesView(),
    ),
    GetPage(
      name: teacherZoomLiveClasses,
      page: () => const TeacherZoomLiveClassesView(),
    ),

    GetPage(
      name: AppRoutes.agoraLiveClasses,
      page: () => const AgoraLiveClassesView(),
    ),
    GetPage(
      name: AppRoutes.teacherAgoraLiveClasses,
      page: () => const TeacherAgoraLiveClassesView(),
    ),
    // GetPage(
    //   name: AppRoutes.teacherChapterFolders,
    //   page: () => const TeacherChapterFoldersView(),
    //
    // ),
    //   GetPage(
    //     // name: '/teacher-login',
    //     name: teacherLogin,
    //     page: () => TeacherLoginView(),
    //
    //   ),

      // Connect this route to your EXISTING teacher dashboard widget.
      // GetPage(
      //   name: '/teacher-dashboard',
      //   // name: AppRoutes.teacherLogin,
      //   page: () => const TeacherClassesView(),
      // ),
    GetPage(
      name: AppRoutes.teacherQuizzes,
      page: () => const TeacherQuizzesView(),
      binding: TeacherQuizzesBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherCreateQuiz,
      page: () => const TeacherCreateQuizView(),
      binding: TeacherCreateQuizBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherManageQuiz,
      page: () => const TeacherManageQuizView(),
    ),
    // GetPage(
    //   name: AppRoutes.teacherChapterLectures,
    //   page: () => const TeacherChapterLectureView(),
    // ),

  ];
}
