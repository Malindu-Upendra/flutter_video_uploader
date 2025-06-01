import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
      appBar: AppBar(
        title: Center(
          child: Text("Upload Video", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child:
            _videUrl != null
                ? _videoPreviewWidget()
                : Text("No Video Selected"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _videoPicker,
        child: Icon(Icons.video_library),
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
          ElevatedButton(onPressed: _uploadVideo, child: Text("Upload")),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
