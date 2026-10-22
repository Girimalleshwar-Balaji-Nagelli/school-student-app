
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'package:get/get.dart';
import 'features/class_section/controllers/agora_live_class_controller.dart';
import 'package:school_student_app/features/class_section/views/dummy_agora_class_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(
    AgoraLiveClassController(),
    permanent: true,
  );

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
