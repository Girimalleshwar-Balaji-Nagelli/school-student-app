import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/config/agora_config.dart';

class AgoraVideoCallView extends StatefulWidget {
  final String channelName;
  final String classTitle;
  final bool isTeacher;
  final int uid;
  final String? token;

  const AgoraVideoCallView({
    super.key,
    required this.channelName,
    required this.classTitle,
    required this.isTeacher,
    this.uid = 0,
    this.token,
  });

  @override
  State<AgoraVideoCallView> createState() => _AgoraVideoCallViewState();
}

class _AgoraVideoCallViewState extends State<AgoraVideoCallView> {
  late final RtcEngineEx _engine;

  bool _initialized = false;
  bool _joined = false;
  bool _micOn = true;
  bool _cameraOn = true;
  bool _joining = true;

  int? _remoteUid;
  String? _error;

  int _localUid = 0;
  int? _dataStreamId;

  final Set<int> _remoteUids = {};
  final Set<int> _raisedHands = {};

  // Screen streams use a separate Agora UID: participant UID + 100000.
  final Set<int> _remoteScreenSharing = {};
  final Set<int> _remoteScreenUids = {};
  final Set<int> _remoteCameraOffUids = {};
  final Set<int> _remoteMicOffUids = {};
  bool _screenConnectionJoined = false;
  bool _showingScreenShare = true;

  final ValueNotifier<List<Map<String, dynamic>>> _messages =
  ValueNotifier([]);

  final TextEditingController _chatController =
  TextEditingController();

  bool _isScreenSharing = false;
  bool _screenRequestPending = false;
  bool _screenShareAllowed = false;
  final ValueNotifier<int> _participantsRevision = ValueNotifier(0);
  int _unreadMessages = 0;
  int _unreadHands = 0;
  bool _isChatOpen = false;

  Widget _iconWithBadge(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -10,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _screenUidFor(int participantUid) => participantUid + 100000;

  String _participantName(int uid) {
    if (uid == 1001) return 'Teacher';
    if (uid == 1002) return 'Student';
    return 'Participant $uid';
  }


  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    try {
      if (AgoraConfig.appId.trim().isEmpty ||
          AgoraConfig.appId == 'PASTE_YOUR_AGORA_APP_ID_HERE') {
        throw Exception('Configure your Agora App ID.');
      }

      final permissions = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraGranted =
          permissions[Permission.camera]?.isGranted ?? false;
      final microphoneGranted =
          permissions[Permission.microphone]?.isGranted ?? false;

      if (!cameraGranted || !microphoneGranted) {
        throw Exception(
          'Camera and microphone permissions are required. '
              'Enable them in Android Settings > Apps > School Student App > Permissions.',
        );
      }

      _engine = createAgoraRtcEngineEx();

      await _engine.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile:
          ChannelProfileType.channelProfileCommunication,
        ),
      );

      _initialized = true;

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          // onJoinChannelSuccess: (connection, elapsed) {
          //   if (!mounted) return;
          //
          //   setState(() {
          //     _joined = true;
          //     _joining = false;
          //     _error = null;
          //   });
          // },
          // onUserJoined: (connection, remoteUid, elapsed) {
          //   if (!mounted) return;
          //   setState(() => _remoteUid = remoteUid);
          // },
          // onUserOffline: (connection, remoteUid, reason) {
          //   if (!mounted) return;
          //   setState(() => _remoteUid = null);
          // },

          // single teacher - student
          // onJoinChannelSuccess: (connection, elapsed) {
          //   debugPrint(
          //     'JOIN SUCCESS: channel=${connection.channelId}, '
          //         'uid=${connection.localUid}',
          //   );
          //
          //   if (!mounted) return;
          //
          //   setState(() {
          //     _joined = true;
          //     _joining = false;
          //     _error = null;
          //   });
          // },
          //
          // onUserJoined: (connection, remoteUid, elapsed) {
          //   debugPrint('REMOTE USER JOINED: uid=$remoteUid');
          //
          //   if (!mounted) return;
          //   setState(() => _remoteUid = remoteUid);
          // },
          //
          // onUserOffline: (connection, remoteUid, reason) {
          //   debugPrint('REMOTE USER LEFT: uid=$remoteUid');
          //
          //   if (!mounted) return;
          //   setState(() => _remoteUid = null);
          // },
          // onError: (err, message) {
          //   debugPrint('Agora error $err: $message');
          //
          //   if (!mounted) return;
          //   setState(() {
          //     _error = 'Agora error $err: $message';
          //     _joining = false;
          //   });
          // },

          onJoinChannelSuccess: (connection, elapsed) async {
            final joinedUid = connection.localUid ?? widget.uid;
            debugPrint(
              'JOIN SUCCESS: channel=${connection.channelId}, uid=$joinedUid',
            );

            // The screen stream is a second logical UID on this same engine.
            // Only the main call connection should create the chat data stream
            // and update the main call's joined state.
            if (_localUid != 0 && joinedUid == _screenUidFor(_localUid)) {
              debugPrint('Screen-share connection joined as UID $joinedUid.');
              return;
            }

            try {
              _dataStreamId = await _engine.createDataStream(
                const DataStreamConfig(
                  syncWithAudio: false,
                  ordered: true,
                ),
              );
              debugPrint('Agora class data stream created: $_dataStreamId');
            } catch (e) {
              debugPrint('Could not create class data stream: $e');
            }

            if (!mounted) return;
            setState(() {
              _localUid = joinedUid;
              _joined = true;
              _joining = false;
              _error = null;
            });
            // Publish initial device states so existing participants see them too.
            unawaited(_sendClassMessage({'type': 'mic', 'enabled': _micOn}));
            unawaited(_sendClassMessage({'type': 'camera', 'enabled': _cameraOn}));
          },

          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('REMOTE USER JOINED: uid=$remoteUid');
            if (!mounted) return;

            setState(() {
              if (remoteUid >= 100000) {
                // The screen stream is listed as a separate temporary participant.
                _remoteScreenUids.add(remoteUid);
                _remoteScreenSharing.add(remoteUid - 100000);
              } else {
                _remoteUids.add(remoteUid);
                _remoteUid ??= remoteUid;
              }
              _participantsRevision.value++;
            });
          },

          onUserOffline: (connection, remoteUid, reason) {
            debugPrint('REMOTE USER LEFT: uid=$remoteUid');
            if (!mounted) return;

            setState(() {
              if (remoteUid >= 100000) {
                _remoteScreenUids.remove(remoteUid);
                _remoteScreenSharing.remove(remoteUid - 100000);
              } else {
                _remoteUids.remove(remoteUid);
                _raisedHands.remove(remoteUid);
                _remoteScreenSharing.remove(remoteUid);
                _remoteScreenUids.remove(_screenUidFor(remoteUid));
                if (_remoteUid == remoteUid) {
                  _remoteUid =
                  _remoteUids.isEmpty ? null : _remoteUids.first;
                }
              }
              _unreadHands = _raisedHands.length;
              if (_remoteScreenUids.isEmpty && !_isScreenSharing) {
                _showingScreenShare = false;
              }
              _participantsRevision.value++;
            });
          },

          onStreamMessage: (
              connection,
              remoteUid,
              streamId,
              data,
              length,
              sentTs,
              ) {
            try {
              final decoded = jsonDecode(utf8.decode(data));
              if (decoded is! Map) return;

              final type = decoded['type']?.toString();
              if (!mounted) return;

              if (type == 'chat') {
                final text = decoded['text']?.toString() ?? '';
                if (text.isEmpty) return;

                _messages.value = [
                  ..._messages.value,
                  {
                    'uid': remoteUid,
                    'name': _participantName(remoteUid),
                    'text': text,
                    'time': DateTime.now(),
                  },
                ];

                if (!_isChatOpen) {
                  setState(() => _unreadMessages++);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          'New message from ${_participantName(remoteUid)}',
                        ),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OPEN',
                          onPressed: _showChat,
                        ),
                      ),
                    );
                }
              } else if (type == 'hand') {
                final raised = decoded['raised'] == true;
                setState(() {
                  if (raised) {
                    _raisedHands.add(remoteUid);
                  } else {
                    _raisedHands.remove(remoteUid);
                  }
                  // Badge represents currently raised hands, not old events.
                  _unreadHands = _raisedHands.length;
                  _participantsRevision.value++;
                });

                if (raised) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_participantName(remoteUid)} raised their hand',
                        ),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'PEOPLE',
                          onPressed: _showParticipants,
                        ),
                      ),
                    );
                }
              } else if (type == 'camera') {
                final enabled = decoded['enabled'] == true;

                setState(() {
                  if (enabled) {
                    _remoteCameraOffUids.remove(remoteUid);
                  } else {
                    _remoteCameraOffUids.add(remoteUid);
                  }
                });
              } else if (type == 'mic') {
                final enabled = decoded['enabled'] == true;
                setState(() {
                  if (enabled) {
                    _remoteMicOffUids.remove(remoteUid);
                  } else {
                    _remoteMicOffUids.add(remoteUid);
                  }
                });
              } else if (type == 'screen') {
                final sharing = decoded['sharing'] == true;
                final screenUid = decoded['screenUid'] is int
                    ? decoded['screenUid'] as int
                    : _screenUidFor(remoteUid);

                setState(() {
                  if (sharing) {
                    _remoteScreenSharing.add(remoteUid);
                    _remoteScreenUids.add(screenUid);
                    _showingScreenShare = true;
                  } else {
                    _remoteScreenSharing.remove(remoteUid);
                    _remoteScreenUids.remove(screenUid);
                    if (!_isScreenSharing && _remoteScreenUids.isEmpty) {
                      _showingScreenShare = false;
                    }
                  }
                  _participantsRevision.value++;
                });

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        sharing
                            ? '${_participantName(remoteUid)} started sharing their screen'
                            : '${_participantName(remoteUid)} stopped sharing their screen',
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
              } else if (type == 'screen_request') {
                if (widget.isTeacher) {
                  unawaited(_handleScreenShareRequest(remoteUid));
                }
              } else if (type == 'screen_permission') {
                final targetUid = decoded['targetUid'];
                if (targetUid == _localUid) {
                  final approved = decoded['approved'] == true;
                  setState(() {
                    _screenRequestPending = false;
                    _screenShareAllowed = approved;
                  });
                  if (approved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Screen sharing approved. Starting…')),
                    );
                    unawaited(_startScreenSharing());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Teacher declined screen sharing.')),
                    );
                  }
                }
              }
            } catch (e) {
              debugPrint('Could not process class message: $e');
            }
          },

          onError: (err, message) {
            debugPrint('Agora error $err: $message');
            if (!mounted) return;
            setState(() {
              _error = 'Agora error $err: $message';
              _joining = false;
            });
          },
        ),
      );

      await _engine.enableAudio();
      await _engine.enableVideo();

      await _engine.startPreview();

      // await _engine.joinChannel(
      //   token: AgoraConfig.token,
      //   channelId: widget.channelName,
      //   uid: 0,
      //   options: const ChannelMediaOptions(
      //     channelProfile:
      //     ChannelProfileType.channelProfileCommunication,
      //     clientRoleType: ClientRoleType.clientRoleBroadcaster,
      //     publishCameraTrack: true,
      //     publishMicrophoneTrack: true,
      //     autoSubscribeAudio: true,
      //     autoSubscribeVideo: true,
      //   ),
      // );
      await _engine.joinChannel(
        token: widget.token ?? AgoraConfig.token,
        channelId: widget.channelName,
        uid: widget.uid,
        options: const ChannelMediaOptions(
          channelProfile:
          ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Agora initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _joining = false;
      });
    }
  }

  Future<void> _toggleMic() async {
    if (!_initialized) return;

    final next = !_micOn;
    await _engine.muteLocalAudioStream(!next);

    if (mounted) setState(() => _micOn = next);
    await _sendClassMessage({'type': 'mic', 'enabled': next});
  }

  Future<void> _toggleCamera() async {
    if (!_initialized) return;

    final next = !_cameraOn;

    await _engine.muteLocalVideoStream(!next);

    if (mounted) {
      setState(() => _cameraOn = next);
    }

    await _sendClassMessage({
      'type': 'camera',
      'enabled': next,
    });
  }

  Future<void> _switchCamera() async {
    if (_initialized) {
      await _engine.switchCamera();
    }
  }

  Future<void> _leaveCall() async {
    if (_initialized) {
      if (_isScreenSharing) {
        await _stopScreenSharing(sendNotification: false);
      }
      await _engine.leaveChannel();
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _releaseEngine() async {
    if (!_initialized) return;

    try {
      if (_isScreenSharing) {
        await _stopScreenSharing(sendNotification: false);
      }
      await _engine.leaveChannel();
      _engine.unregisterEventHandler(RtcEngineEventHandler());
      await _engine.release();
    } catch (_) {
      // The engine may already have been released.
    }
  }

  @override
  void dispose() {
    unawaited(_releaseEngine());
    _chatController.dispose();
    _messages.dispose();
    _participantsRevision.dispose();
    super.dispose();
  }

  int get _participantCount {
    final ids = <int>{_localUid, ..._remoteUids};
    if (_isScreenSharing) ids.add(_screenUidFor(_localUid));
    ids.addAll(_remoteScreenUids);
    return ids.length;
  }

  @override
  Widget build(BuildContext context) {
    // Keep each camera and screen stream as its own tile, like Meet/Zoom.
    final activeScreenUid = _remoteScreenUids.isNotEmpty
        ? (_remoteScreenUids.toList()..sort()).first
        : (_isScreenSharing ? _screenUidFor(_localUid) : null);
    final activeScreenIsLocal =
        activeScreenUid != null && activeScreenUid == _screenUidFor(_localUid);
    final hasActiveScreen = activeScreenUid != null;
    final tiles = <Map<String, dynamic>>[
      {'uid': _localUid, 'local': true, 'screen': false},
      ...(_remoteUids.toList()..sort()).map(
            (uid) => {'uid': uid, 'local': false, 'screen': false},
      ),
      if (_isScreenSharing)
        {'uid': _screenUidFor(_localUid), 'local': true, 'screen': true},
      ...(_remoteScreenUids.toList()..sort()).map(
            (uid) => {'uid': uid, 'local': false, 'screen': true},
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        title: Text(
          widget.classTitle,
          style: const TextStyle(color: Color(0xFF172033)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_participantCount} people',
                style: const TextStyle(
                  color: Color(0xFF657086),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _joining && !_joined
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Connecting to class...'),
                  ],
                ),
              )
                  : (hasActiveScreen && _showingScreenShare)
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF111827)),
                  if (_initialized)
                    AgoraVideoView(
                      key: ValueKey('active-screen-$activeScreenUid'),
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: VideoCanvas(
                          uid: activeScreenUid,
                          sourceType: VideoSourceType.videoSourceScreen,
                          renderMode: RenderModeType.renderModeFit,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.68),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.screen_share_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_participantName(activeScreenUid >= 100000 ? activeScreenUid - 100000 : activeScreenUid)} is sharing',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _showingScreenShare = false),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Participants'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.72),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                itemCount: tiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: tiles.length <= 1 ? 1 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: tiles.length <= 1 ? 0.95 : 0.78,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  final uid = tile['uid'] as int;
                  final isLocal = tile['local'] as bool;
                  final isScreen = tile['screen'] as bool;
                  final cameraOff = !isScreen && (isLocal
                      ? !_cameraOn
                      : _remoteCameraOffUids.contains(uid));
                  final name = isScreen
                      ? '${_participantName(uid >= 100000 ? uid - 100000 : uid)} · Screen'
                      : '${_participantName(isLocal ? _localUid : uid)}${isLocal ? ' (You)' : ''}';

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: const Color(0xFFF1F4F8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_initialized && !cameraOff)
                            AgoraVideoView(
                              key: ValueKey('video-$uid-$isScreen'),
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: VideoCanvas(
                                  uid: isLocal && !isScreen ? 0 : uid,
                                  sourceType: isScreen
                                      ? VideoSourceType.videoSourceScreen
                                      : VideoSourceType.videoSourceCamera,
                                  renderMode: isScreen
                                      ? RenderModeType.renderModeFit
                                      : RenderModeType.renderModeHidden,
                                ),
                              ),
                            )
                          else
                            Center(
                              child: isScreen
                                  ? const Icon(
                                Icons.screen_share_rounded,
                                color: Color(0xFF657086),
                                size: 42,
                              )
                                  : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      '${isLocal ? _localUid : uid}',
                                      style: const TextStyle(
                                        color: Color(0xFF172033),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF344054),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.62),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  if (isScreen) ...[
                                    const Icon(
                                      Icons.screen_share_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (!isScreen && (isLocal ? !_micOn : _remoteMicOffUids.contains(uid))) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.mic_off_rounded, color: Colors.white, size: 15),
                                  ],
                                  if (!isScreen && (isLocal ? !_cameraOn : _remoteCameraOffUids.contains(uid))) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.videocam_off_rounded, color: Colors.white, size: 15),
                                  ],
                                  if (!isScreen &&
                                      !isLocal &&
                                      _raisedHands.contains(uid))
                                    const Icon(
                                      Icons.back_hand_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hasActiveScreen && !_showingScreenShare)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showingScreenShare = true),
                    icon: const Icon(Icons.screen_share_rounded),
                    label: const Text('View shared screen'),
                  ),
                ),
              ),
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showParticipants,
                    icon: _iconWithBadge(Icons.people, _unreadHands),
                    label: Text('People ($_participantCount)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _toggleRaiseHand,
                    icon: Icon(
                      _raisedHands.contains(_localUid)
                          ? Icons.back_hand
                          : Icons.front_hand,
                    ),
                    label: Text(
                      _raisedHands.contains(_localUid)
                          ? 'Lower hand'
                          : 'Raise hand',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showChat,
                    icon: _iconWithBadge(Icons.chat, _unreadMessages),
                    label: const Text('Chat'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _toggleScreenSharing,
                    icon: Icon(
                      _isScreenSharing
                          ? Icons.stop_screen_share
                          : Icons.screen_share,
                    ),
                    label: Text(
                      _isScreenSharing
                          ? 'Stop sharing'
                          : (_screenRequestPending
                          ? 'Requesting…'
                          : (widget.isTeacher
                          ? 'Share screen'
                          : 'Request screen share')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(
                    icon: _micOn ? Icons.mic : Icons.mic_off,
                    label: _micOn ? 'Mute' : 'Unmute',
                    onPressed: _toggleMic,
                  ),
                  _controlButton(
                    icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
                    label: _cameraOn ? 'Camera off' : 'Camera on',
                    onPressed: _toggleCamera,
                  ),
                  _controlButton(
                    icon: Icons.cameraswitch_rounded,
                    label: 'Switch',
                    onPressed: _switchCamera,
                  ),
                  _controlButton(
                    icon: Icons.call_end_rounded,
                    label: 'Leave',
                    color: Colors.red,
                    onPressed: _leaveCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Future<void> Function() onPressed,
    Color color = const Color(0xFFE8EEF7),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: () => unawaited(onPressed()),
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: const Color(0xFF172033),
            fixedSize: const Size(54, 54),
          ),
          icon: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF344054), fontSize: 11)),
      ],
    );
  }

  Future<void> _sendClassMessage(Map<String, dynamic> payload) async {
    final streamId = _dataStreamId;

    if (!_joined || streamId == null) {
      debugPrint('Cannot send message: not connected to class.');
      return;
    }

    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(payload)),
    );

    try {
      await _engine.sendStreamMessage(
        streamId: streamId,
        data: bytes,
        length: bytes.length,
      );
    } catch (e) {
      debugPrint('Failed to send class message: $e');
    }
  }

  Future<void> _toggleRaiseHand() async {
    final next = !_raisedHands.contains(_localUid);

    // Update the local UI immediately.
    setState(() {
      if (next) {
        _raisedHands.add(_localUid);
      } else {
        _raisedHands.remove(_localUid);
      }
      _unreadHands = _raisedHands.length;
      _participantsRevision.value++;
    });

    await _sendClassMessage({
      'type': 'hand',
      'raised': next,
    });
  }

  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();

    _messages.value = [
      ..._messages.value,
      {
        'uid': _localUid,
        'name': _participantName(_localUid),
        'text': text,
        'time': DateTime.now(),
      },
    ];

    await _sendClassMessage({
      'type': 'chat',
      'text': text,
    });
  }

  Future<void> _toggleScreenSharing() async {
    if (!_initialized || !_joined || _localUid == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join the class before sharing your screen.')),
        );
      }
      return;
    }

    if (_isScreenSharing) {
      await _stopScreenSharing();
      return;
    }

    // Teacher can share immediately. A student must first be approved by the teacher.
    if (!widget.isTeacher && !_screenShareAllowed) {
      if (_screenRequestPending) return;
      setState(() => _screenRequestPending = true);
      await _sendClassMessage({'type': 'screen_request'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen-share request sent to the teacher.')),
        );
      }
      return;
    }

    await _startScreenSharing();
  }

  Future<void> _handleScreenShareRequest(int requesterUid) async {
    if (!mounted || !widget.isTeacher) return;

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Screen-share request'),
        content: Text('${_participantName(requesterUid)} wants to share their screen. Allow it?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Decline'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    ) ?? false;

    await _sendClassMessage({
      'type': 'screen_permission',
      'targetUid': requesterUid,
      'approved': approved,
    });
  }

  Future<void> _startScreenSharing() async {
    if (_isScreenSharing || !_initialized || !_joined) return;

    final screenUid = _screenUidFor(_localUid);
    final connection = RtcConnection(
      channelId: widget.channelName,
      localUid: screenUid,
    );

    try {
      debugPrint('Starting screen share: channel=${widget.channelName}, uid=$screenUid');

      // Join the temporary screen-stream connection before starting Android capture.
      await _engine.joinChannelEx(
        token: widget.token ?? AgoraConfig.token,
        connection: connection,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenTrack: false,
          publishSecondaryScreenTrack: false,
          publishScreenCaptureAudio: false,
          publishScreenCaptureVideo: false,
        ),
      );
      _screenConnectionJoined = true;

      // Android will request projection permission. The user must approve each new capture session.
      await _engine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: false,
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 1280, height: 720),
            frameRate: 15,
            bitrate: 1200,
          ),
        ),
      );

      await _engine.updateChannelMediaOptionsEx(
        connection: connection,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenTrack: false,
          publishSecondaryScreenTrack: false,
          publishScreenCaptureAudio: false,
          publishScreenCaptureVideo: true,
        ),
      );

      if (!mounted) return;
      setState(() {
        _isScreenSharing = true;
        _showingScreenShare = true;
        _screenShareAllowed = false;
        _screenRequestPending = false;
        _participantsRevision.value++;
      });

      await _sendClassMessage({
        'type': 'screen',
        'sharing': true,
        'screenUid': screenUid,
      });
      debugPrint('Screen capture publishing under UID $screenUid.');
    } catch (e, stackTrace) {
      debugPrint('Screen sharing failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      await _cleanupScreenShareConnection(connection);
      if (mounted) {
        setState(() {
          _isScreenSharing = false;
          _screenRequestPending = false;
          _participantsRevision.value++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screen sharing failed: $e')),
        );
      }
    }
  }

  Future<void> _cleanupScreenShareConnection(RtcConnection connection) async {
    // Stop capture first so the local projection surface is released before leaving the extra UID.
    try {
      await _engine.stopScreenCapture();
    } catch (e) {
      debugPrint('stopScreenCapture during cleanup: $e');
    }

    try {
      await _engine.updateChannelMediaOptionsEx(
        connection: connection,
        options: const ChannelMediaOptions(
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenTrack: false,
          publishSecondaryScreenTrack: false,
          publishScreenCaptureAudio: false,
          publishScreenCaptureVideo: false,
        ),
      );
    } catch (e) {
      debugPrint('Disabling screen publication during cleanup: $e');
    }

    if (_screenConnectionJoined) {
      try {
        await _engine.leaveChannelEx(connection: connection);
      } catch (e) {
        debugPrint('Leaving screen connection during cleanup: $e');
      }
      _screenConnectionJoined = false;
    }
  }

  Future<void> _stopScreenSharing({bool sendNotification = true}) async {
    final screenUid = _screenUidFor(_localUid);
    final connection = RtcConnection(
      channelId: widget.channelName,
      localUid: screenUid,
    );

    // Notify peers while the main connection/data stream is still alive.
    if (sendNotification) {
      await _sendClassMessage({
        'type': 'screen',
        'sharing': false,
        'screenUid': screenUid,
      });
    }

    await _cleanupScreenShareConnection(connection);

    if (mounted) {
      setState(() {
        _isScreenSharing = false;
        if (_remoteScreenUids.isEmpty) _showingScreenShare = false;
        _screenShareAllowed = false;
        _screenRequestPending = false;
        _remoteScreenSharing.remove(_localUid);
        _participantsRevision.value++;
      });
    }
    debugPrint('Screen share stopped; the main camera/microphone connection remains active.');
  }

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ValueListenableBuilder<int>(
          valueListenable: _participantsRevision,
          builder: (context, revision, _) {
            final ids = <int>{_localUid, ..._remoteUids};
            if (_isScreenSharing) ids.add(_screenUidFor(_localUid));
            ids.addAll(_remoteScreenUids);
            final sortedIds = ids.toList()..sort();

            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Participants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  for (final uid in sortedIds)
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          uid >= 100000
                              ? Icons.screen_share_rounded
                              : (_raisedHands.contains(uid)
                              ? Icons.back_hand
                              : Icons.person),
                        ),
                      ),
                      title: Text(uid >= 100000
                          ? '${_participantName(uid - 100000)} (sharing screen)'
                          : '${_participantName(uid)}${uid == _localUid ? ' (You)' : ''}'),
                      subtitle: Text(uid >= 100000
                          ? 'Screen stream'
                          : (_raisedHands.contains(uid) ? 'Hand raised' : 'In classroom')),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChat() {
    setState(() {
      _isChatOpen = true;
      _unreadMessages = 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: 400,
              child: Column(
                children: [
                  const Text(
                    'Class chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ValueListenableBuilder<
                        List<Map<String, dynamic>>>(
                      valueListenable: _messages,
                      builder: (context, messages, _) {
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text('No messages yet'),
                          );
                        }

                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ListTile(
                              dense: true,
                              title: Text(message['name'].toString()),
                              subtitle: Text(message['text'].toString()),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                          ),
                          onSubmitted: (_) => _sendChatMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendChatMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() => _isChatOpen = false);
    });
  }

}