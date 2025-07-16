import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class CustomAudioPlayer extends StatefulWidget {
  final String audioUrl; // Can also be local file path
  const CustomAudioPlayer(String s, {super.key, required this.audioUrl});

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final PlayerController _waveController = PlayerController();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _initialize();
    _waveController.preparePlayer(
      path: widget.audioUrl,
      shouldExtractWaveform: true,
    );
  }

  Future<void> _initialize() async {
    await _player.setUrl(widget.audioUrl);
    _duration = _player.duration ?? Duration.zero;

    _player.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _waveController
      ..preparePlayer(path: widget.audioUrl, shouldExtractWaveform: true);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Circular shape
              border: Border.all(color: Colors.black), // Black border
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                size: 32,
              ),
              onPressed: _togglePlayPause,
              color: Colors.black,
              splashRadius: 24, // Optional: control splash size
            ),
          ),
          Expanded(
            child: AudioFileWaveforms(
              size: const Size(double.infinity, 40),
              playerController: _waveController,
              enableSeekGesture: true,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: const PlayerWaveStyle(
                showBottom: true,
                showTop: false,
                // gradient: LinearGradient(colors: [Colors.blue, Colors.green]),
                // inactiveColor: Colors.grey,
                liveWaveColor: Colors.blue,
              ),
            ),
          ),

          const SizedBox(width: 8),
          Text(
            _formatDuration(_duration - _position),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
