
import 'package:flutter/material.dart';

import 'agora_video_call_view.dart';

class DummyAgoraClassView extends StatefulWidget {
  const DummyAgoraClassView({super.key});

  @override
  State<DummyAgoraClassView> createState() =>
      _DummyAgoraClassViewState();
}

class _DummyAgoraClassViewState
    extends State<DummyAgoraClassView> {
  final _channelController =
      TextEditingController(text: 'school-demo-room');
  final _uidController = TextEditingController(text: '1001');
  final _tokenController = TextEditingController();

  bool _isTeacher = true;

  @override
  void dispose() {
    _channelController.dispose();
    _uidController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Test Class')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Temporary two-device test',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Teacher'),
                icon: Icon(Icons.cast_for_education),
              ),
              ButtonSegment(
                value: false,
                label: Text('Student'),
                icon: Icon(Icons.school),
              ),
            ],
            selected: {_isTeacher},
            onSelectionChanged: (values) {
              setState(() {
                _isTeacher = values.first;
                _uidController.text =
                    _isTeacher ? '1001' : '1002';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              labelText: 'Channel name',
              hintText: 'school-demo-room',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _uidController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Numeric UID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'RTC token',
              hintText: 'Paste token for this channel and UID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use a token generated for this exact channel '
            'and UID. Leave it blank only if your Agora '
            'project permits tokenless joining.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.video_call),
            label: const Text('Join test class'),
            onPressed: () {
              final channel = _channelController.text.trim();
              final uid = int.tryParse(_uidController.text);
              final token = _tokenController.text.trim();

              if (channel.isEmpty || uid == null || uid <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter a channel name and a positive numeric UID.',
                    ),
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AgoraVideoCallView(
                    channelName: channel,
                    classTitle: _isTeacher
                        ? 'Teacher Test Class'
                        : 'Student Test Class',
                    isTeacher: _isTeacher,
                    uid: uid,
                    token: token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
