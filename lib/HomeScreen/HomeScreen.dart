import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../ResponseScreen/ResponseScreen.dart';
import '../Utils/firebase_configuration.dart';
import '../Utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _videUrl;
  String? _downloadUrl;

  VideoPlayerController? _controller;
  bool _isLoading = false;

  void _handleTranslate() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to ResponseScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResponseScreen()),
      );
    });
  }

  void _videoPicker() async {
    _videUrl = await pickVideo();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videUrl!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  void _uploadVideo() async {
    _downloadUrl = await StoreData().uploadVideo(_videUrl!);
    await StoreData().saveVideoData(_downloadUrl!);

    setState(() {
      _videUrl = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child:
                            _videUrl != null
                                ? _videoPreviewWidget()
                                : const Text("No Video Selected"),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _videoPicker,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFFFBAC00),
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0xFFFBAC00),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "Select Video",
                              style: TextStyle(
                                color: Color(0xFFFBAC00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed "Translate" button at the bottom
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTranslate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBAC00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Translate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (_isLoading) ...const [
                          const SizedBox(width: 12),
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          // ElevatedButton(onPressed: _uploadVideo, child: Text("Upload")),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
