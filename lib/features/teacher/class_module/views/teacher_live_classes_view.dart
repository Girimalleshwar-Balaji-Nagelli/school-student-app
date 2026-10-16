
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/teacher_live_classes_controller.dart';
import '../models/teacher_live_class_model.dart';
import '../models/google_meet_class_model.dart';
import '../../../class_section/views/agora_video_call_view.dart';

class TeacherLiveClassesView
    extends GetView<TeacherLiveClassesController> {
  const TeacherLiveClassesView({super.key});

  static const blue = Color(0xFF2459A9);
  static const background = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Live Classes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Schedule class'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final items = controller.filteredClasses;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${controller.schoolClass.className} • '
                  'Section ${controller.schoolClass.section}',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              controller.subject,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Scheduled', 'Live', 'Completed']
                    .map((filter) {
                  final selected =
                      controller.selectedFilter.value == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) =>
                      controller.selectedFilter.value = filter,
                      selectedColor: const Color(0xFFDCE9FF),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // if (items.isEmpty)
            //   const Padding(
            //     padding: EdgeInsets.only(top: 50),
            //     child: Center(child: Text('No live classes found.')),
            //   )
            // else
            //   ...items.map(_classCard),
            // const SizedBox(height: 80),

            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No Jitsi classes found.')),
              )
            else
              ...items.map(_classCard),

            const SizedBox(height: 28),

            const Row(
              children: [
                Icon(Icons.video_call_rounded, color: Color(0xFF4285F4)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Google Meet Online Classes',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              'Schedule and join classes using Google Meet links.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _showGoogleMeetDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Schedule Google Meet class'),
            ),

            const SizedBox(height: 12),

            if (controller.googleMeetClasses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('No Google Meet classes scheduled yet.'),
                ),
              )
            else
              ...controller.googleMeetClasses.map(_googleMeetCard),

            const SizedBox(height: 90),

          ],
        );
      }),
    );
  }

  Widget _classCard(TeacherLiveClassModel item) {
    final isLive = item.status == 'live';
    final isCompleted = item.status == 'completed';

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.video_camera_front_rounded, color: blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 16),
            _detail(Icons.calendar_today_outlined, _date(item.startTime)),
            const SizedBox(height: 8),
            _detail(
              Icons.access_time_rounded,
              '${_time(item.startTime)} • ${item.durationMinutes} minutes',
            ),
            const SizedBox(height: 8),
            _detail(
              Icons.school_outlined,
              '${item.className} - Section ${item.section}',
            ),
            const SizedBox(height: 18),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () {
                    if (isLive) {
                      controller.endClass(item);
                    } else if (item.status == 'scheduled') {
                      controller.startClass(item);
                    }
                  },
                  icon: Icon(
                    isLive ? Icons.stop_circle_outlined : Icons.video_call,
                  ),
                  label: Text(isLive ? 'End class' : 'Start class'),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _googleMeetCard(GoogleMeetClassModel item) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.video_call, color: Color(0xFF4285F4)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GOOGLE MEET',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _detail(Icons.calendar_today, _date(item.startTime)),
            const SizedBox(height: 8),
            _detail(
              Icons.access_time,
              '${_time(item.startTime)} • ${item.durationMinutes} minutes',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => controller.openGoogleMeet(item),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Google Meet'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _detail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: blue),
        const SizedBox(width: 9),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'live' => Colors.red,
      'completed' => Colors.green,
      _ => blue,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final now = DateTime.now();
    var selectedDate = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1),
    );
    var selectedTime = const TimeOfDay(hour: 10, minute: 0);
    var duration = 45;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Schedule live class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Class title',
                        hintText: 'e.g. Introduction to Algebra',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text('Start time'),
                      subtitle: Text(selectedTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                    ),
                    DropdownButtonFormField<int>(
                      value: duration,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                      ),
                      items: const [30, 45, 60, 90].map((minutes) {
                        return DropdownMenuItem(
                          value: minutes,
                          child: Text('$minutes minutes'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => duration = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final startTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    if (!startTime.isAfter(DateTime.now())) {
                      Get.snackbar(
                        'Invalid time',
                        'Choose a future date and time.',
                      );
                      return;
                    }

                    controller.createClass(
                      title: titleController.text,
                      startTime: startTime,
                      durationMinutes: duration,
                    );
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(titleController.dispose);
  }


  void _showGoogleMeetDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    final now = DateTime.now();
    var selectedDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    var selectedTime = const TimeOfDay(hour: 10, minute: 0);
    var duration = 45;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Schedule Google Meet class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Class title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Google Meet link',
                    hintText: 'https://meet.google.com/abc-defg-hij',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );

                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Start time'),
                  subtitle: Text(selectedTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );

                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: duration,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                  ),
                  items: const [30, 45, 60, 90]
                      .map(
                        (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes minutes'),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => duration = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final startTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                controller.createGoogleMeetClass(
                  title: titleController.text,
                  startTime: startTime,
                  durationMinutes: duration,
                  meetUrl: urlController.text,
                );
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      urlController.dispose();
    });
  }

}
