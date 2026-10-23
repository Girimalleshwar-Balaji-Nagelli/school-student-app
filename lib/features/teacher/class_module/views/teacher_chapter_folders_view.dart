import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/teacher_video_lectures_controller.dart';
import '../models/teacher_video_lecture_models.dart';
import 'teacher_chapter_lectures_view.dart';
import 'teacher_lecture_analytics_view.dart';

class TeacherChapterFoldersView extends StatefulWidget {
  final String className;
  final String subject;

  const TeacherChapterFoldersView({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  State<TeacherChapterFoldersView> createState() =>
      _TeacherChapterFoldersViewState();
}

class _TeacherChapterFoldersViewState
    extends State<TeacherChapterFoldersView> {
  late final TeacherVideoLecturesController controller;

  final Set<String> expandedChapters = <String>{};

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<TeacherVideoLecturesController>()) {
      controller = Get.find<TeacherVideoLecturesController>();
    } else {
      controller = Get.put(
        TeacherVideoLecturesController(),
        permanent: true,
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: const Color(0xFF13A390),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final allChapters = controller.chapters.toList();
        final allLectures = controller.lectures.toList();

        final chapters = allChapters.where((chapter) {
          return chapter.className.toLowerCase() ==
              widget.className.toLowerCase() &&
              chapter.subject.toLowerCase() == widget.subject.toLowerCase();
        }).toList();

        if (chapters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No chapters yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a chapter and add video lectures to it.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _showCreateChapterDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Chapter'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF13A390),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${widget.className} • ${widget.subject}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Course content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...chapters.map((chapter) {
              final lectures = allLectures
                  .where((lecture) => lecture.chapterId == chapter.id)
                  .toList();

              return _buildChapterCard(
                chapter: chapter,
                lectures: lectures,
                isExpanded: expandedChapters.contains(chapter.id),
              );
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showCreateChapterDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Another Chapter'),
            ),
            const SizedBox(height: 80),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        // onPressed: _showCreateChapterDialog,
        onPressed: () { Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherLectureAnalyticsView(),
          ),
        );
          },
        backgroundColor: const Color(0xFF13A390),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Add Chapter'),
      ),
    );
  }

  Widget _buildChapterCard({
    required TeacherLectureChapter chapter,
    required List<TeacherRecordedLecture> lectures,
    required bool isExpanded,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: isExpanded ? 'Collapse chapter' : 'Expand chapter',
                  onPressed: () => _toggleChapter(chapter.id),
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _toggleChapter(chapter.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (chapter.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              chapter.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${lectures.length} '
                                '${lectures.length == 1 ? 'lecture' : 'lectures'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add video lecture',
                  onPressed: () => _showAddVideoDialog(chapter),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF13A390),
                    size: 28,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditChapterDialog(chapter);
                    } else if (value == 'delete') {
                      _confirmDeleteChapter(chapter);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit chapter'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete chapter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            if (lectures.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.video_library_outlined,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'No videos yet. Tap + to add a lecture.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showAddVideoDialog(chapter),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              )
            else
              ...lectures.map((lecture) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      leading: const Icon(
                        Icons.play_circle_outline,
                        color: Color(0xFF13A390),
                        size: 28,
                      ),
                      title: Text(
                        lecture.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        lecture.videoFileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'play') {
                            _playLecture(lecture);
                          } else if (value == 'edit') {
                            _showEditLectureDialog(lecture);
                          } else if (value == 'delete') {
                            _confirmDeleteLecture(lecture);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'play',
                            child: Text('Play video'),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit lecture'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete lecture'),
                          ),
                        ],
                      ),
                      onTap: () => _playLecture(lecture),
                    ),
                    const Divider(height: 1, indent: 20),
                  ],
                );
              }),
          ],
        ],
      ),
    );
  }

  void _toggleChapter(String chapterId) {
    if (!mounted) return;

    setState(() {
      if (expandedChapters.contains(chapterId)) {
        expandedChapters.remove(chapterId);
      } else {
        expandedChapters.add(chapterId);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Dialog launchers
  // ---------------------------------------------------------------------------

  Future<void> _showCreateChapterDialog() async {
    final result = await showDialog<_NameDescription>(
      context: context,
      builder: (_) => const _ChapterDialog(
        title: 'Create Chapter',
        confirmLabel: 'Create',
      ),
    );

    if (result == null || !mounted) return;

    controller.addChapter(
      name: result.name,
      description: result.description,
      className: widget.className,
      subject: widget.subject,
    );

    _showMessage('Chapter created successfully.');
  }

  Future<void> _showEditChapterDialog(TeacherLectureChapter chapter) async {
    final result = await showDialog<_NameDescription>(
      context: context,
      builder: (_) => _ChapterDialog(
        title: 'Edit Chapter',
        confirmLabel: 'Save',
        initialName: chapter.name,
        initialDescription: chapter.description,
      ),
    );

    if (result == null || !mounted) return;

    controller.updateChapter(
      chapter.id,
      name: result.name,
      description: result.description,
    );
  }

  Future<void> _showAddVideoDialog(TeacherLectureChapter chapter) async {
    final result = await showDialog<_VideoResult>(
      context: context,
      builder: (_) => _AddVideoDialog(chapterName: chapter.name),
    );

    if (result == null || !mounted) return;

    setState(() {
      expandedChapters.add(chapter.id);
    });

    controller.addLecture(
      chapterId: chapter.id,
      title: result.title,
      description: result.description,
      videoPath: result.path,
      videoFileName: result.fileName,
    );

    _showMessage('Video added under ${chapter.name}.');
  }

  Future<void> _showEditLectureDialog(TeacherRecordedLecture lecture) async {
    final result = await showDialog<_NameDescription>(
      context: context,
      builder: (_) => _EditLectureDialog(
        initialTitle: lecture.title,
        initialDescription: lecture.description,
        fileName: lecture.videoFileName,
      ),
    );

    if (result == null || !mounted) return;

    controller.updateLecture(
      lecture.id,
      title: result.name,
      description: result.description,
    );
  }

  Future<void> _confirmDeleteChapter(TeacherLectureChapter chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete chapter?'),
        content: Text(
          'Delete "${chapter.name}" and all its video lectures?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    controller.deleteChapter(chapter.id);

    setState(() {
      expandedChapters.remove(chapter.id);
    });
  }

  Future<void> _confirmDeleteLecture(TeacherRecordedLecture lecture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete lecture?'),
        content: Text('Delete "${lecture.title}" from this chapter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    controller.deleteLecture(lecture.id);
  }

  void _playLecture(TeacherRecordedLecture lecture) {
    if (!File(lecture.videoPath).existsSync()) {
      _showMessage('The selected video file is no longer accessible.');
      return;
    }

    Get.to(
          () => TeacherLecturePlayerScreen(
        title: lecture.title,
        videoPath: lecture.videoPath,
      ),
    );
  }
}

// =============================================================================
// Dialog result models
// =============================================================================

class _NameDescription {
  final String name;
  final String description;

  const _NameDescription(this.name, this.description);
}

class _VideoResult {
  final String title;
  final String description;
  final String path;
  final String fileName;

  const _VideoResult({
    required this.title,
    required this.description,
    required this.path,
    required this.fileName,
  });
}

// =============================================================================
// Create / Edit chapter dialog
// =============================================================================

class _ChapterDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final String initialDescription;

  const _ChapterDialog({
    required this.title,
    required this.confirmLabel,
    this.initialName = '',
    this.initialDescription = '',
  });

  @override
  State<_ChapterDialog> createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<_ChapterDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a chapter title');
      return;
    }
    Navigator.pop(
      context,
      _NameDescription(name, _descriptionController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
                labelText: 'Chapter title',
                hintText: 'e.g. Introduction',
                errorText: _nameError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF13A390),
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// =============================================================================
// Add video dialog
// =============================================================================

class _AddVideoDialog extends StatefulWidget {
  final String chapterName;

  const _AddVideoDialog({required this.chapterName});

  @override
  State<_AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<_AddVideoDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedPath;
  String? _selectedFileName;
  String? _titleError;
  String? _fileError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );

    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path;

    if (path == null) {
      setState(() {
        _fileError = 'Please select a video available on this device.';
      });
      return;
    }

    setState(() {
      _selectedPath = path;
      _selectedFileName = file.name;
      _fileError = null;
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final path = _selectedPath;

    var hasError = false;

    if (title.isEmpty) {
      _titleError = 'Please enter a video name';
      hasError = true;
    }

    if (path == null) {
      _fileError = 'Please choose a video file';
      hasError = true;
    } else if (!File(path).existsSync()) {
      _fileError = 'File not found. Please select the video again.';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    Navigator.pop(
      context,
      _VideoResult(
        title: title,
        description: _descriptionController.text.trim(),
        path: path!,
        fileName: _selectedFileName ?? 'video',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Video Lecture'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chapter: ${widget.chapterName}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                labelText: 'Video name',
                hintText: 'e.g. Introduction to Algebra',
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file_outlined),
              label: Text(
                _selectedFileName ?? 'Choose video file',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_fileError != null) ...[
              const SizedBox(height: 6),
              Text(
                _fileError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            if (_selectedPath != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Selected video',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _selectedPath!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF13A390),
          ),
          child: const Text('Save Video'),
        ),
      ],
    );
  }
}

// =============================================================================
// Edit lecture dialog
// =============================================================================

class _EditLectureDialog extends StatefulWidget {
  final String initialTitle;
  final String initialDescription;
  final String fileName;

  const _EditLectureDialog({
    required this.initialTitle,
    required this.initialDescription,
    required this.fileName,
  });

  @override
  State<_EditLectureDialog> createState() => _EditLectureDialogState();
}

class _EditLectureDialogState extends State<_EditLectureDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter a video name');
      return;
    }
    Navigator.pop(
      context,
      _NameDescription(title, _descriptionController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Video Lecture'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                labelText: 'Video name',
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'File: ${widget.fileName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF13A390),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}