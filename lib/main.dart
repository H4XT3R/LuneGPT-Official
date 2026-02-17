import 'package:flutter/material.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(home: LuneGPT(), debugShowCheckedModeBanner: false));

class LuneGPT extends StatefulWidget {
  const LuneGPT({super.key});
  @override
  _LuneGPTState createState() => _LuneGPTState();
}

class _LuneGPTState extends State<LuneGPT> {
  final LlamaController _llama = LlamaController();
  final TextEditingController _controller = TextEditingController();
  bool isLoaded = false;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/LuneGPT/brain.gguf";
    if (await File(path).exists()) {
      await _llama.loadModel(modelPath: path);
      setState(() => isLoaded = true);
    }
  }

  void _send() async {
    if (_controller.text.isEmpty || !isLoaded) return;
    String input = _controller.text;
    _controller.clear();

    setState(() {
      messages.add({"role": "user", "text": input});
      messages.add({"role": "lune", "text": "..."});
    });

    String fullText = "";
    // Standard prompt format that works across most Llama 3 models
    _llama.generate(
      prompt: "System: You are LuneGPT by Adam Aghnia.\nUser: $input\nAssistant: ",
    ).listen((token) {
      fullText += token;
      setState(() => messages.last["text"] = fullText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("LUNE GPT"), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(messages[i]["text"]!, style: TextStyle(color: messages[i]["role"] == "user" ? Colors.blue : Colors.white)),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, style: const TextStyle(color: Colors.white))),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _send),
              ],
            ),
          )
        ],
      ),
    );
  }
}
