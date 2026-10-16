
import 'package:get/get.dart';

import '../controllers/course_progress_controller.dart';

class CourseProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseProgressController>(
          () => CourseProgressController(),
    );
  }
}
