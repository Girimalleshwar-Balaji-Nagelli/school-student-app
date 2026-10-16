
import 'package:get/get.dart';

import '../controllers/live_classes_controller.dart';

class LiveClassesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveClassesController>(
          () => LiveClassesController(),
    );
  }
}
