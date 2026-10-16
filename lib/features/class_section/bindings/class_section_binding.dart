
import 'package:get/get.dart';

import '../controllers/class_section_controller.dart';

class ClassSectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClassSectionController>(
          () => ClassSectionController(),
    );
  }
}
