
import 'package:get/get.dart';

import '../models/subject_model.dart';
import '../../../routes/app_pages.dart';

class AssignedSubjectsController extends GetxController {
  final RxList<SubjectModel> subjects = <SubjectModel>[
    const SubjectModel(
      id: 'subject_1',
      name: 'Mathematics',
      description: 'Numbers, algebra and geometry',
      liveClassCount: 2,
      availableQuizCount: 1,
    ),
    const SubjectModel(
      id: 'subject_2',
      name: 'Biology',
      description: 'Living organisms and life sciences',
      liveClassCount: 1,
      availableQuizCount: 1,
    ),
    const SubjectModel(
      id: 'subject_3',
      name: 'Physics',
      description: 'Motion, energy and forces',
      liveClassCount: 2,
      availableQuizCount: 2,
    ),
  ].obs;

  void openSubject(SubjectModel subject) {
    Get.toNamed(
      AppRoutes.subjectDetails,
      arguments: subject,
    );
  }
}
