import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsWidget extends StatefulWidget {
  @override
  _TtsWidgetState createState() => _TtsWidgetState();
}

class _TtsWidgetState extends State<TtsWidget> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'Enter text to speak',
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await flutterTts.speak(textController.text);
          },
          child: Text('Speak'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
