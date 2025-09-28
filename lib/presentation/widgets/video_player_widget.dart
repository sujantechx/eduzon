// lib/presentation/screens/dashboard/video_player_screen.dart

import 'package:eduzon/presentation/widgets/watermark_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/enums/screen_mode.dart'; // Import the enum
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../services/secure_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final ScreenMode mode; // Add this parameter

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.mode, // Make it required
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint("Attempting to play video with ID: ${widget.videoId}");

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        forceHD: true,
        showLiveFullscreenButton: false,
      ),
    );
    // Only secure the screen for students
    if (widget.mode == ScreenMode.student) {
      // SecureService.secureScreen();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Only unsecure if it was previously secured
    if (widget.mode == ScreenMode.student) {
      // SecureService.unsecureScreen();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.mode == ScreenMode.admin
          ? AppBar(title: const Text("Admin Preview")) // Show AppBar for admin
          : null, // No AppBar for students
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    player,
                    // Only show watermark for students
                    if (widget.mode == ScreenMode.student)
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is Authenticated) {
                            return WatermarkWidget(text: state.userModel.email);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),
              ),
              // Only show security message for students
              if (widget.mode == ScreenMode.student)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'For your security, screenshots and screen recording are disabled for this content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}