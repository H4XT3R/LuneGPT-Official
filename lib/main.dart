import 'package:flutter/material.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
  home: LuneGPT(),
));

class LuneGPT extends StatefulWidget {
  @override
  _LuneGPTState createState() => _LuneGPTState();
}

class _LuneGPTState extends State<LuneGPT> {
  final LlamaController _llama = LlamaController();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Map<String, List<Map<String, String>>> allChats = {
    "Default Chat": [{"role": "lune", "text": "LuneGPT Neuro-Sync Active. Connect brain to begin."}],
  };
  
  String currentChatKey = "Default Chat";
  bool isLoaded = false;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadBrain();
  }

  void _loadBrain() async {
    // Looks for the file you moved from Google Drive
    final dir = await getExternalStorageDirectory(); 
    final path = "${dir!.path}/LuneGPT/brain.gguf";
    
    if (await File(path).exists()) {
      await _llama.loadModel(modelPath: path);
      setState(() => isLoaded = true);
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty || !isLoaded) return;
    
    String userMsg = _controller.text;
    _controller.clear();

    setState(() {
      allChats[currentChatKey]!.add({"role": "user", "text": userMsg});
      allChats[currentChatKey]!.add({"role": "lune", "text": "..."});
      isTyping = true;
    });

    // 🌙 YOUR COLAB SYSTEM PROMPT
    final systemPrompt = "You are LuneGPT, an Elite Intelligence and logical peer optimized by Adam Aghnia. "
        "PATTERN RECOGNITION | LOGICAL VALIDATION | CLARITY REFINEMENT. "
        "Tone: Calm, brilliant, professional. No slang. Conciseness is key.";

    String response = "";
    _llama.generateChat(
      messages: [
        ChatMessage(role: 'system', content: systemPrompt),
        ChatMessage(role: 'user', content: userMsg),
      ],
      template: 'chatml',
      temperature: 0.3,
    ).listen((token) {
      response += token;
      setState(() => allChats[currentChatKey]!.last["text"] = response);
    }, onDone: () => setState(() => isTyping = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020205),
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: Text("LUNE GPT", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [Icon(Icons.circle, color: isLoaded ? Colors.green : Colors.red, size: 10), SizedBox(width: 20)],
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          if (isTyping) LinearProgressIndicator(color: Colors.deepPurpleAccent, backgroundColor: Colors.transparent),
          _buildInput(),
        ],
      ),
    );
  }

  // UI Components (Sidebar, Chat List, Input) follow the premium design...
  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: Color(0xFF0F0F1A),
      child: Column(
        children: [
          SizedBox(height: 60),
          Text("HISTORY", style: TextStyle(letterSpacing: 2)),
          Expanded(
            child: ListView(
              children: allChats.keys.map((k) => ListTile(
                title: Text(k),
                onTap: () { setState(() => currentChatKey = k); Navigator.pop(context); },
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(20),
      itemCount: allChats[currentChatKey]!.length,
      itemBuilder: (context, i) {
        var msg = allChats[currentChatKey]![i];
        bool isUser = msg["role"] == "user";
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUser ? Color(0xFF6C63FF) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(msg["text"]!, style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "Message...", border: InputBorder.none))),
                IconButton(icon: Icon(Icons.send, color: Color(0xFF6C63FF)), onPressed: _sendMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
