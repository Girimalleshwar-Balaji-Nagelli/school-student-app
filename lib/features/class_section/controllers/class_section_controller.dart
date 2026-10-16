
import 'package:get/get.dart';

import '../models/class_section_model.dart';
import '../../../routes/app_pages.dart';

class ClassSectionController extends GetxController {
  final Rxn<ClassSectionModel> classSection =
  Rxn<ClassSectionModel>();

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadClassSection();
  }

  void loadClassSection() {
    // Temporary mock data until the Laravel API is available.
    classSection.value = const ClassSectionModel(
      className: 'Class 8',
      sectionName: 'Section B',
      academicYear: '2026–27',
      assignedSubjectCount: 3,
    );
  }

  void openAssignedSubjects() {
    Get.toNamed(AppRoutes.subjects);
  }
}
