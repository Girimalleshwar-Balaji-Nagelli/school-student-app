import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controllers/teacher_video_lectures_controller.dart';
import '../models/teacher_video_lecture_models.dart';

class TeacherChapterLectureView extends StatefulWidget {
  final TeacherLectureChapter chapter;

  const TeacherChapterLectureView({
    super.key,
    required this.chapter,
  });

  @override
  State<TeacherChapterLectureView> createState() =>
      _TeacherChapterLectureViewState();
}

class _TeacherChapterLectureViewState
    extends State<TeacherChapterLectureView> {
  late final TeacherVideoLecturesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TeacherVideoLecturesController>()
        ? Get.find<TeacherVideoLecturesController>()
        : Get.put(
      TeacherVideoLecturesController(),
      permanent: true,
    );
  }

  Future<void> _showLectureDialog({
    TeacherRecordedLecture? lecture,
  }) async {
    final titleController = TextEditingController(
      text: lecture?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: lecture?.description ?? '',
    );

    String? selectedPath = lecture?.videoPath;
    String? selectedName = lecture?.videoFileName;

    await Get.dialog<void>(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(
              lecture == null ? 'Add Recorded Lecture' : 'Edit Lecture',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Lecture title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                        allowMultiple: false,
                        withData: false,
                      );

                      if (result == null || result.files.isEmpty) return;

                      final file = result.files.single;
                      if (file.path == null) {
                        Get.snackbar(
                          'Cannot access video',
                          'Choose a video file that can be accessed locally.',
                        );
                        return;
                      }

                      setDialogState(() {
                        selectedPath = file.path;
                        selectedName = file.name;
                      });
                    },
                    icon: const Icon(Icons.video_library_outlined),
                    label: Text(
                      selectedName == null
                          ? 'Choose video'
                          : 'Change video',
                    ),
                  ),
                  if (selectedName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        selectedName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final title = titleController.text.trim();

                  if (title.isEmpty) {
                    Get.snackbar('Required', 'Enter a lecture title.');
                    return;
                  }

                  if (selectedPath == null || selectedName == null) {
                    Get.snackbar('Required', 'Choose a video file.');
                    return;
                  }

                  if (!await File(selectedPath!).exists()) {
                    Get.snackbar(
                      'Video unavailable',
                      'The selected file cannot be found.',
                    );
                    return;
                  }

                  if (lecture == null) {
                    controller.addLecture(
                      chapterId: widget.chapter.id,
                      title: title,
                      description: descriptionController.text,
                      videoPath: selectedPath!,
                      videoFileName: selectedName!,
                    );
                  } else {
                    controller.updateLecture(
                      lecture.id,
                      title: title,
                      description: descriptionController.text,
                      videoPath: selectedPath,
                      videoFileName: selectedName,
                    );
                  }

                  Get.back();
                },
                child: Text(lecture == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteLecture(TeacherRecordedLecture lecture) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete lecture?'),
        content: Text('Delete "${lecture.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteLecture(lecture.id);
    }
  }

  void _playLecture(TeacherRecordedLecture lecture) {
    final path = lecture.videoPath;

    if (!File(path).existsSync()) {
      Get.snackbar(
        'Video unavailable',
        'The local video file cannot be found on this device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
          () => TeacherLecturePlayerScreen(
        title: lecture.title,
        videoPath: path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLectureDialog(),
        icon: const Icon(Icons.video_call_outlined),
        label: const Text('Add Lecture'),
      ),
      body: Obx(() {
        final lectures =
        controller.lecturesForChapter(widget.chapter.id);

        if (lectures.isEmpty) {
          return const Center(
            child: Text('No recorded lectures yet. Tap Add Lecture.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: lectures.length,
          itemBuilder: (context, index) {
            final lecture = lectures[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.play_circle_outline),
                ),
                title: Text(lecture.title),
                subtitle: Text(
                  lecture.description.isEmpty
                      ? lecture.videoFileName
                      : lecture.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _playLecture(lecture),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showLectureDialog(lecture: lecture);
                    } else if (value == 'delete') {
                      _deleteLecture(lecture);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class TeacherLecturePlayerScreen extends StatefulWidget {
  final String title;
  final String videoPath;

  const TeacherLecturePlayerScreen({
    super.key,
    required this.title,
    required this.videoPath,
  });

  @override
  State<TeacherLecturePlayerScreen> createState() =>
      _TeacherLecturePlayerScreenState();
}

class _TeacherLecturePlayerScreenState
    extends State<TeacherLecturePlayerScreen> {
  late final VideoPlayerController player;
  late final Future<void> initializePlayer;

  @override
  void initState() {
    super.initState();
    player = VideoPlayerController.file(File(widget.videoPath));
    initializePlayer = player.initialize().then((_) {
      player.play();
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String _time(Duration duration) {
    final minutes = duration.inMinutes.remainder(60)
        .toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60)
        .toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<void>(
        future: initializePlayer,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to play this video.'));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: player.value.aspectRatio > 0
                    ? player.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(player),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: player,
                builder: (context, value, _) {
                  final max = value.duration.inMilliseconds
                      .toDouble()
                      .clamp(1.0, double.infinity);
                  final position = value.position.inMilliseconds
                      .toDouble()
                      .clamp(0.0, max);

                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(_time(value.position)),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: max,
                              value: position,
                              onChanged: (next) {
                                player.seekTo(
                                  Duration(milliseconds: next.round()),
                                );
                              },
                            ),
                          ),
                          Text(_time(value.duration)),
                        ],
                      ),
                      IconButton.filled(
                        iconSize: 32,
                        onPressed: () {
                          value.isPlaying ? player.pause() : player.play();
                        },
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}