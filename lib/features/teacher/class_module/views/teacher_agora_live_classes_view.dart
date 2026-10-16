import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

import '../models/teacher_class_model.dart';
import '../../../class_section/controllers/agora_live_class_controller.dart';
import '../../../class_section/models/agora_live_class_model.dart';
import '../../../class_section/views/agora_video_call_view.dart';

class TeacherAgoraLiveClassesView extends StatefulWidget {
  const TeacherAgoraLiveClassesView({super.key});

  @override
  State<TeacherAgoraLiveClassesView> createState() =>
      _TeacherAgoraLiveClassesViewState();
}

class _TeacherAgoraLiveClassesViewState
    extends State<TeacherAgoraLiveClassesView> {
  final titleController = TextEditingController();

  late final AgoraLiveClassController controller;
  late final TeacherClassModel schoolClass;
  late final String subject;

  DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

  int durationMinutes = 40;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    schoolClass = args['schoolClass'] as TeacherClassModel;
    subject = args['subject'] as String;

    controller = Get.find<AgoraLiveClassController>();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (time == null || !mounted) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void scheduleClass() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Title required',
        'Please enter a class title.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!selectedDate.isAfter(DateTime.now())) {
      Get.snackbar(
        'Invalid time',
        'Please select a future date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    controller.scheduleClass(
      title: titleController.text,
      className: schoolClass.className,
      section: schoolClass.section,
      subject: subject,
      scheduledAt: selectedDate,
      durationMinutes: durationMinutes,
    );

    titleController.clear();

    Get.snackbar(
      'Class scheduled',
      'Your live class has been added.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$d/$m/${date.year} • $hour:$minute $period';
  }

  String statusText(AgoraClassStatus status) {
    switch (status) {
      case AgoraClassStatus.scheduled:
        return 'Scheduled';
      case AgoraClassStatus.live:
        return 'Live';
      case AgoraClassStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = controller.sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('Agora Live Classes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${schoolClass.className} • Section ${schoolClass.section}',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              subject,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),

            // Schedule form
            const Text(
              'Schedule a class',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Class title',
                hintText: 'e.g. Introduction to Algebra',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: selectDateTime,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(formatDate(selectedDate)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<int>(
              value: durationMinutes,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 20, child: Text('20 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 40, child: Text('40 minutes')),
                DropdownMenuItem(value: 60, child: Text('60 minutes')),
                DropdownMenuItem(value: 90, child: Text('90 minutes')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => durationMinutes = value);
                }
              },
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: scheduleClass,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Schedule Live Class'),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Your classes',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final filtered = controller.getSessions(
                className: schoolClass.className,
                section: schoolClass.section,
                subject: subject,
              );

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('No classes scheduled yet.')),
                );
              }

              return Column(
                children: filtered.map((session) {
                  final isScheduled =
                      session.status == AgoraClassStatus.scheduled;
                  final isLive = session.status == AgoraClassStatus.live;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(formatDate(session.scheduledAt)),
                          const SizedBox(height: 4),
                          Text('${session.durationMinutes} minutes'),
                          const SizedBox(height: 8),
                          Text(
                            statusText(session.status),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isLive ? Colors.green : Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isScheduled)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                // onPressed: () {
                                // controller.startClass(session.id);
                                //
                                // Get.snackbar(
                                // 'Mock session started',
                                // 'Agora video calling is not connected yet.',
                                // snackPosition: SnackPosition.BOTTOM,
                                // );
                                // },
                                onPressed: () {
                                  controller.startClass(session.id);

                                  // final channelName =
                                  //     'school_${session.className}_${session.section}_'
                                  //             '${session.subject}_${session.id}'
                                  //         .replaceAll(
                                  //           RegExp(r'[^a-zA-Z0-9_-]'),
                                  //           '_',
                                  //         );
                                  final channelName = 'school-demo-room';

                                  log("Channel Name"+channelName);
                                  log("Session title"+session.title);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AgoraVideoCallView(
                                        channelName: channelName,
                                        classTitle: session.title,
                                        isTeacher: true,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start Class'),
                              ),
                            )
                          else if (isLive)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  controller.completeClass(session.id);
                                },
                                icon: const Icon(Icons.stop_rounded),
                                label: const Text('Complete Class'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
