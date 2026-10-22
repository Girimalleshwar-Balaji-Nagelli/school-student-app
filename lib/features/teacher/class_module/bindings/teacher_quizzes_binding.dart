import 'package:get/get.dart';

import '../controllers/teacher_quizzes_controller.dart';

class TeacherQuizzesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherQuizzesController>(
          () => TeacherQuizzesController(),
    );
  }
}