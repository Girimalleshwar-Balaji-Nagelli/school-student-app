import 'package:get/get.dart';
import '../controllers/teacher_classes_controller.dart';

class TeacherClassesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherClassesController>(
          () => TeacherClassesController(),
    );
  }
}