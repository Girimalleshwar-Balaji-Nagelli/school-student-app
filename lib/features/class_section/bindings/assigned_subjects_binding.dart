
import 'package:get/get.dart';

import '../controllers/assigned_subjects_controller.dart';

class AssignedSubjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignedSubjectsController>(
          () => AssignedSubjectsController(),
    );
  }
}
