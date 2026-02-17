import 'package:flutter/material.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(MaterialApp(
  theme: ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurpleAccent,
    scaffoldBackgroundColor: Color(0xFF0F0F1A),
  ),
  home: LuneGPT(),
));

class LuneGPT extends StatefulWidget {
  @override
  _LuneGPTState createState() => _LuneGPTState();
}

class _LuneGPTState extends State<LuneGPT> {
  final LlamaController _llama = LlamaController();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chat = [];
  bool isLoaded = false;
  bool isTyping = false;

  void loadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/LuneGPT/brain.gguf";
    if (await File(path).exists()) {
      await _llama.loadModel(modelPath: path);
      setState(() => isLoaded = true);
    }
  }

  void sendMessage() async {
    if (_controller.text.isEmpty) return;
    String userMsg = _controller.text;
    _controller.clear();

    setState(() {
      _chat.add({"role": "user", "text": userMsg});
      _chat.add({"role": "lune", "text": "..."});
      isTyping = true;
    });

    String response = "";
    _llama.generate(prompt: userMsg).listen((token) {
      response += token;
      setState(() => _chat[_chat.length - 1]["text"] = response);
    }, onDone: () => setState(() => isTyping = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LUNE GPT", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isLoaded ? Icons.bolt : Icons.sync_disabled, color: isLoaded ? Colors.yellow : Colors.red),
            onPressed: loadModel,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: _chat.length,
              itemBuilder: (context, i) {
                bool isUser = _chat[i]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurpleAccent : Color(0xFF252535),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: isUser ? Radius.circular(15) : Radius.circular(0),
                        bottomRight: isUser ? Radius.circular(0) : Radius.circular(15),
                      ),
                    ),
                    child: Text(_chat[i]["text"]!, style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (isTyping) LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.deepPurpleAccent),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(color: Color(0xFF1A1A2E)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask LuneGPT anything...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: isLoaded ? Colors.deepPurpleAccent : Colors.grey,
                  onPressed: isLoaded ? sendMessage : loadModel,
                  child: Icon(Icons.arrow_upward),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
