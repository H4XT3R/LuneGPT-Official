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
  // Using the controller from llama_flutter_android
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
    // In version 0.1.1, ensure the path is correct
    final dir = await getApplicationDocumentsDirectory(); 
    final path = "${dir.path}/LuneGPT/brain.gguf";
    
    if (await File(path).exists()) {
      try {
        await _llama.loadModel(modelPath: path);
        setState(() => isLoaded = true);
      } catch (e) {
        debugPrint("Error loading brain: $e");
      }
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

    final systemPrompt = "You are LuneGPT, an Elite Intelligence and logical peer optimized by Adam Aghnia. Tone: Calm, professional.";

    String response = "";
    // Note: If generateChat template fails, version 0.1.1 uses basic generate
    _llama.generate(
      prompt: "<|system|>\n$systemPrompt\n<|user|>\n$userMsg\n<|assistant|>\n",
      temperature: 0.3,
    ).listen((token) {
      response += token;
      setState(() => allChats[currentChatKey]!.last["text"] = response);
    }, onDone: () => setState(() => isTyping = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020205),
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: const Text("LUNE GPT", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [Icon(Icons.circle, color: isLoaded ? Colors.green : Colors.red, size: 10), const SizedBox(width: 20)],
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          if (isTyping) const LinearProgressIndicator(color: Colors.deepPurpleAccent, backgroundColor: Colors.transparent),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F1A),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text("HISTORY", style: TextStyle(letterSpacing: 2)),
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
      padding: const EdgeInsets.all(20),
      itemCount: allChats[currentChatKey]!.length,
      itemBuilder: (context, i) {
        var msg = allChats[currentChatKey]![i];
        bool isUser = msg["role"] == "user";
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(msg["text"]!, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Message...", border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF6C63FF)), onPressed: _sendMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
