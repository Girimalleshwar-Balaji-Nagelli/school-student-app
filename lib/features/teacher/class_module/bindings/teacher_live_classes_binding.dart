
import 'package:get/get.dart';
import '../controllers/teacher_live_classes_controller.dart';

class TeacherLiveClassesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherLiveClassesController>(
          () => TeacherLiveClassesController(),
    );
  }
}
