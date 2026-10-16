
import 'package:get/get.dart';

import '../models/live_class_model.dart';
import '../models/subject_model.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../teacher/class_module/models/google_meet_class_model.dart';

class LiveClassesController extends GetxController {
  late final SubjectModel subject;

  final RxList<LiveClassModel> classes = <LiveClassModel>[].obs;
  final RxInt selectedFilter = 0.obs;

  static const String _googleMeetStorageKey =
      'teacher_google_meet_classes_v1';

  final RxList<GoogleMeetClassModel> googleMeetClasses =
      <GoogleMeetClassModel>[].obs;


  final filters = const [
    'All',
    'Upcoming',
    'Live',
    'Completed',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();

    subject = Get.arguments as SubjectModel;
    loadMockClasses();
    loadGoogleMeetClasses();
  }

  void loadMockClasses() {
    // Temporary demonstration data.
    // These dates are examples, not the actual school timetable.
    final now = DateTime.now();

    final sampleClasses = <LiveClassModel>[
      LiveClassModel(
        id: 'class_1',
        roomId: 'school_class8_sectionb_math_class5',
        subjectId: subject.id,
        title: 'Introduction to ${subject.name}',
        teacherName: 'Mr. Sharma',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        status: 'upcoming',
      ),
      LiveClassModel(
        id: 'class_2',
        roomId: 'school_class8_sectionb_math_class5',
        subjectId: subject.id,
        title: '${subject.name} - Practice Session',
        teacherName: 'Mrs. Patel',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 1)),
        status: 'upcoming',
      ),
      LiveClassModel(
        id: 'class_3',
        roomId: 'school_class8_sectionb_math_class5',
        subjectId: subject.id,
        title: '${subject.name} - Revision',
        teacherName: 'Mr. Sharma',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2, hours: -1)),
        status: 'completed',
      ),
      LiveClassModel(
        id: 'class_4',
        roomId: 'school_class8_sectionb_math_class5',
        subjectId: subject.id,
        title: '${subject.name} - Extra Class',
        teacherName: 'Mrs. Patel',
        startTime: now.add(const Duration(days: 3)),
        endTime: now.add(const Duration(days: 3, hours: 1)),
        status: 'cancelled',
      ),
      LiveClassModel(
        id: 'class_5',
        roomId: 'school_class8_sectionb_math_class5',
        subjectId: subject.id,
        title: '${subject.name} - Live Classroom',
        teacherName: 'Mr. Sharma',
        startTime: now.subtract(const Duration(minutes: 15)),
        endTime: now.add(const Duration(minutes: 45)),
        status: 'live',
      ),
    ];

    classes.assignAll(sampleClasses);
  }


  Future<void> loadGoogleMeetClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_googleMeetStorageKey);

      if (stored == null) {
        googleMeetClasses.clear();
        return;
      }

      final decoded = jsonDecode(stored) as List<dynamic>;

      final restored = decoded.map((item) {
        return GoogleMeetClassModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).where((item) {
        return item.subject.trim().toLowerCase() ==
            subject.name.trim().toLowerCase();
      }).toList();

      googleMeetClasses.assignAll(restored);
    } catch (e) {
      debugPrint('Could not load Google Meet classes: $e');

      Get.snackbar(
        'Loading error',
        'Could not load Google Meet classes.',
      );
    }
  }

  Future<void> joinGoogleMeet(GoogleMeetClassModel item) async {
    final uri = Uri.tryParse(item.meetUrl);

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.toLowerCase() != 'meet.google.com') {
      Get.snackbar(
        'Invalid link',
        'This Google Meet link is not valid.',
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        Get.snackbar(
          'Unable to join',
          'Could not open the Google Meet link.',
        );
      }
    } catch (e) {
      debugPrint('Google Meet launch error: $e');

      Get.snackbar(
        'Unable to join',
        'Please try opening the meeting again.',
      );
    }
  }


  List<LiveClassModel> get filteredClasses {
    final selected = filters[selectedFilter.value].toLowerCase();

    if (selected == 'all') {
      return classes.toList();
    }

    return classes
        .where((item) => item.status == selected)
        .toList();
  }

  void selectFilter(int index) {
    selectedFilter.value = index;
  }


  Future<void> openClass(LiveClassModel liveClass) async {
    if (liveClass.status == 'cancelled') {
      Get.snackbar(
        'Class Cancelled',
        'This session is no longer available.',
      );
      return;
    }

    if (liveClass.status == 'completed') {
      Get.snackbar(
        'Class Completed',
        'This session has already ended.',
      );
      return;
    }

    if (liveClass.status != 'live') {
      Get.snackbar(
        'Class Not Started',
        'You can join when the teacher starts the session.',
      );
      return;
    }

    // Prototype room name.
    // In production, obtain a unique room name from Laravel.
    // final roomName =
    //     'school_class8_sectionb_${liveClass.subjectId}_${liveClass.id}';

    final roomName = liveClass.roomId;

    try {
      final jitsiMeet = JitsiMeet();

      final options = JitsiMeetConferenceOptions(
        serverURL: 'https://meet.jit.si',
        room: roomName,
        userInfo: JitsiMeetUserInfo(
          displayName: 'Student',
        ),
        configOverrides: {
          'subject': liveClass.title,
          'startWithAudioMuted': true,
          'startWithVideoMuted': true,
        },
      );
      await jitsiMeet.join(options);
    } catch (error) {
      Get.snackbar(
        'Unable to Join Class',
        'Please check your internet connection and try again.',
      );

      debugPrint('Jitsi meeting error: $error');
    }
  }
}
