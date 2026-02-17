import 'package:flutter/material.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: LuneGPT()));

class LuneGPT extends StatefulWidget {
  @override
  _LuneGPTState createState() => _LuneGPTState();
}

class _LuneGPTState extends State<LuneGPT> {
  final LlamaController _llama = LlamaController();
  final TextEditingController _controller = TextEditingController();
  List<String> messages = ["System: Welcome, Adam. Move your GGUF file to Documents/LuneGPT/brain.gguf to start."];
  bool isLoaded = false;

  void loadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/LuneGPT/brain.gguf";
    if (await File(path).exists()) {
      await _llama.loadModel(modelPath: path, nThreads: 4);
      setState(() => isLoaded = true);
    }
  }

  void sendMessage() async {
    String text = _controller.text;
    _controller.clear();
    setState(() => messages.add("You: $text"));
    
    String response = "";
    _llama.generate(prompt: text).listen((token) {
      response += token;
      setState(() => messages[messages.length - 1] = "Lune: $response");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LuneGPT Offline"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, i) => ListTile(title: Text(messages[i])),
          )),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller)),
              IconButton(icon: Icon(Icons.send), onPressed: isLoaded ? sendMessage : loadModel),
            ]),
          )
        ],
      ),
    );
  }
}
