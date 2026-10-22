import 'package:get/get.dart';

import '../controllers/teacher_create_quiz_controller.dart';

class TeacherCreateQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherCreateQuizController>(
          () => TeacherCreateQuizController(),
    );
  }
}