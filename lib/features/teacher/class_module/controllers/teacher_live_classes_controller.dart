
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/teacher_class_model.dart';
import '../models/teacher_live_class_model.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/google_meet_class_model.dart';

class TeacherLiveClassesController extends GetxController {
  static const String _storageKey = 'teacher_live_classes_v1';

  static const String _googleMeetStorageKey =
      'teacher_google_meet_classes_v1';

  final RxList<GoogleMeetClassModel> googleMeetClasses =
      <GoogleMeetClassModel>[].obs;

  late TeacherClassModel schoolClass;
  late String subject;

  final RxList<TeacherLiveClassModel> classes =
      <TeacherLiveClassModel>[].obs;

  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    schoolClass = args['schoolClass'] as TeacherClassModel;
    subject = args['subject'] as String;

    loadClasses();
    loadGoogleMeetClasses();
  }

  Future<void> loadClasses() async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);

      if (stored == null) {
        classes.clear();
      } else {
        final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;

        final restored = decoded
            .map(
              (item) => TeacherLiveClassModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
            .where(
              (item) =>
          item.classId == schoolClass.id &&
              item.subject == subject,
        )
            .toList();

        classes.assignAll(restored);
      }
    } catch (error) {
      Get.snackbar(
        'Storage error',
        'Could not load saved classes. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<TeacherLiveClassModel> get filteredClasses {
    if (selectedFilter.value == 'All') {
      return classes.toList();
    }

    return classes
        .where(
          (item) =>
      item.status == selectedFilter.value.toLowerCase(),
    )
        .toList();
  }

  Future<void> _saveClasses() async {
    final prefs = await SharedPreferences.getInstance();

    // Preserve schedules belonging to other classes and subjects.
    final stored = prefs.getString(_storageKey);
    final List<dynamic> allItems =
    stored == null ? [] : jsonDecode(stored) as List<dynamic>;

    final otherItems = allItems.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return map['classId'] != schoolClass.id ||
          map['subject'] != subject;
    }).toList();

    otherItems.addAll(classes.map((item) => item.toJson()));

    final success = await prefs.setString(
      _storageKey,
      jsonEncode(otherItems),
    );

    if (!success) {
      throw Exception('Unable to save scheduled classes.');
    }
  }

  Future<void> createClass({
    required String title,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Required', 'Enter a class title.');
      return;
    }

    if (!startTime.isAfter(DateTime.now())) {
      Get.snackbar('Invalid time', 'Choose a future date and time.');
      return;
    }

    if (durationMinutes <= 0) {
      Get.snackbar('Invalid duration', 'Choose a valid duration.');
      return;
    }

    final id = 'class_${DateTime.now().microsecondsSinceEpoch}';

    final liveClass = TeacherLiveClassModel(
      id: id,
      classId: schoolClass.id,
      className: schoolClass.className,
      section: schoolClass.section,
      subject: subject,
      title: title.trim(),
      startTime: startTime,
      durationMinutes: durationMinutes,
      status: 'scheduled',
      roomId: //'school_class8_sectionb_math_class5',  // It is added newly
      'school_${schoolClass.id}_${subject.toLowerCase()}_$id',
    );

    classes.insert(0, liveClass);

    try {
      await _saveClasses();
      Get.back();
      Get.snackbar('Success', 'Live class scheduled and saved.');
    } catch (error) {
      classes.removeWhere((item) => item.id == id);
      Get.snackbar(
        'Save failed',
        'The class could not be saved. Please try again.',
      );
    }
  }

  Future<void> startClass(TeacherLiveClassModel liveClass) async {
    if (liveClass.status != 'scheduled') {
      Get.snackbar('Unavailable', 'This class cannot be started.');
      return;
    }

    final index = classes.indexWhere((item) => item.id == liveClass.id);
    if (index == -1) return;

    classes[index] = liveClass.copyWith(status: 'live');

    try {
      await _saveClasses();
      await joinTeacherMeeting(liveClass);
      // Get.snackbar(
      //   'Class started',
      //   'Saved locally. Jitsi connection will be added next.',
      // );
    } catch (error) {
      classes[index] = liveClass;
      Get.snackbar('Error', 'Could not save the class status.');
    }
  }

  Future<void> endClass(TeacherLiveClassModel liveClass) async {
    final index = classes.indexWhere((item) => item.id == liveClass.id);
    if (index == -1 || liveClass.status != 'live') return;

    classes[index] = liveClass.copyWith(status: 'completed');

    try {
      await _saveClasses();
      Get.snackbar('Class ended', liveClass.title);
    } catch (error) {
      classes[index] = liveClass;
      Get.snackbar('Error', 'Could not save the class status.');
    }
  }

  Future<void> cancelClass(TeacherLiveClassModel liveClass) async {
    if (liveClass.status != 'scheduled') {
      Get.snackbar(
        'Unavailable',
        'Only scheduled classes can be cancelled.',
      );
      return;
    }

    final index = classes.indexWhere((item) => item.id == liveClass.id);
    if (index == -1) return;

    classes.removeAt(index);

    try {
      await _saveClasses();
      Get.snackbar('Cancelled', 'Scheduled class cancelled.');
    } catch (error) {
      classes.insert(index, liveClass);
      Get.snackbar('Error', 'Could not cancel the class.');
    }
  }

  Future<void> joinTeacherMeeting(
      TeacherLiveClassModel liveClass,
      ) async {
    if (liveClass.roomId.trim().isEmpty) {
      Get.snackbar(
        'Unable to start',
        'Meeting room ID is missing.',
      );
      return;
    }

    try {
      await JitsiMeet().join(
        JitsiMeetConferenceOptions(
          serverURL: 'https://meet.jit.si',
          room: liveClass.roomId,
          userInfo: JitsiMeetUserInfo(
            displayName: 'Teacher',
          ),
          configOverrides: {
            'subject': liveClass.title,
            'startWithAudioMuted': false,
            'startWithVideoMuted': false,
          },
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Meeting Error',
        'Could not open the meeting. Please try again.',
      );
      debugPrint('Jitsi meeting error: $e');
    }
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

      googleMeetClasses.assignAll(
        decoded.map(
              (item) => GoogleMeetClassModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Storage error',
        'Could not load Google Meet classes.',
      );
    }
  }

  Future<void> _saveGoogleMeetClasses() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _googleMeetStorageKey,
      jsonEncode(
        googleMeetClasses.map((item) => item.toJson()).toList(),
      ),
    );
  }

  Future<void> createGoogleMeetClass({
    required String title,
    required DateTime startTime,
    required int durationMinutes,
    required String meetUrl,
  }) async {
    final uri = Uri.tryParse(meetUrl.trim());

    if (title.trim().isEmpty) {
      Get.snackbar('Required', 'Enter a class title.');
      return;
    }

    if (!startTime.isAfter(DateTime.now())) {
      Get.snackbar('Invalid time', 'Choose a future date and time.');
      return;
    }

    if (durationMinutes <= 0) {
      Get.snackbar('Invalid duration', 'Choose a valid duration.');
      return;
    }

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.toLowerCase() != 'meet.google.com' ||
        uri.pathSegments.isEmpty) {
      Get.snackbar(
        'Invalid link',
        'Paste a valid Google Meet link, such as '
            'https://meet.google.com/abc-defg-hij',
      );
      return;
    }

    final item = GoogleMeetClassModel(
      id: 'meet_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      startTime: startTime,
      durationMinutes: durationMinutes,
      meetUrl: uri.toString(),
      classId: schoolClass.id,
      className: schoolClass.className,
      section: schoolClass.section,
      subject: subject,
    );

    googleMeetClasses.insert(0, item);

    try {
      await _saveGoogleMeetClasses();
      Get.back();
      Get.snackbar('Success', 'Google Meet class scheduled.');
    } catch (e) {
      googleMeetClasses.removeWhere((value) => value.id == item.id);
      Get.snackbar('Error', 'Could not save the Google Meet class.');
    }
  }

  Future<void> openGoogleMeet(GoogleMeetClassModel item) async {
    final uri = Uri.parse(item.meetUrl);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        Get.snackbar('Unable to open', 'Could not open the meeting link.');
      }
    } catch (e) {
      Get.snackbar('Unable to open', 'Could not open the meeting link.');
    }
  }

}
