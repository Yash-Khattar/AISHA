import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(
    home: CallingScreen(),
  ));
}

class CallingScreen extends StatefulWidget {
  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  int _seconds = 0;
  Timer? _timer;
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = "";
  double _confidence = 1.0;
  String _sessionId = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _sessionId = const Uuid().v4(); // Generate new UUID for session
    _requestPermissions();
    _startTimer();

    _flutterTts.setStartHandler(() {
      _speech.stop(); // Stop listening when TTS starts
    });

    _flutterTts.setCompletionHandler(() {
      _listenContinuously(); // Resume listening when TTS finishes
    });
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }

    _listenContinuously();
  }

  void _listenContinuously() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) {
        print('onError: $val');
        _listenContinuously();
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (val) async {
          setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          });
          if (val.finalResult) {
            _speech.stop();
            String aiResponse = await _getAIResponse(_text);
            await _speak(aiResponse);
          }
        },
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<String> _getAIResponse(String text) async {
    final response = await http.post(
      Uri.parse('https://aisha-bi2e.onrender.com/chat/invoke'),
      body: jsonEncode({
        "input": [
          {
            "content": text,
            "additional_kwargs": {},
            "response_metadata": {},
            "type": "string",
            "name": "string",
            "id": "string"
          }
        ],
        "config": {
          "configurable": {"session_id": _sessionId}
        },
        "kwargs": {}
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data['output']);
      return data['output'];
    } else {
      print(response.body);
      throw Exception('Failed to load AI response');
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 80),
              Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://static.vecteezy.com/system/resources/previews/019/896/012/original/female-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AISHA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.mic_off, color: Colors.grey),
                      iconSize: 40,
                      onPressed: () {
                        // Mute functionality
                      },
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      iconSize: 40,
                      onPressed: () {
                        // End call functionality
                      },
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.grey),
                      iconSize: 40,
                      onPressed: () {
                        // Speaker functionality
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
