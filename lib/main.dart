
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'package:get/get.dart';
import 'features/class_section/controllers/agora_live_class_controller.dart';
import 'package:school_student_app/features/class_section/views/dummy_agora_class_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(
    AgoraLiveClassController(),
    permanent: true,
  );

  runApp(const SchoolStudentApp());
}

class SchoolStudentApp extends StatelessWidget {
  const SchoolStudentApp({super.key});

  @override
  Widget build(BuildContext context) {

    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => const DummyAgoraClassView(),
    //   ),
    // );

    return GetMaterialApp(
      title: 'School Student App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.classSection,
      getPages: AppRoutes.pages,
    );
  }
}
