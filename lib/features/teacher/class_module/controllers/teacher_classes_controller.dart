import 'package:get/get.dart';
import '../models/teacher_class_model.dart';
import '../../../../routes/app_pages.dart';

class TeacherClassesController extends GetxController {
  final RxList<TeacherClassModel> classes = <TeacherClassModel>[
    const TeacherClassModel(
      id: 'class_8_b',
      className: 'Class 8',
      section: 'B',
      academicYear: '2026–27',
      studentCount: 35,
      subjects: ['Mathematics', 'Physics', 'Biology'],
    ),
    const TeacherClassModel(
      id: 'class_9_a',
      className: 'Class 9',
      section: 'A',
      academicYear: '2026–27',
      studentCount: 32,
      subjects: ['Mathematics', 'Physics'],
    ),
  ].obs;

  void openClass(TeacherClassModel schoolClass) {
    Get.toNamed(
      AppRoutes.teacherClassDetails,
      arguments: schoolClass,
    );
  }
}