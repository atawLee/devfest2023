import 'package:flutter/material.dart';
import 'package:flutter_chat/chat.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;
void main() {
  setupLocator();
  runApp(const MyApp());
}

void setupLocator() {
  getIt.registerFactory<ChatClient>(
      () => SignalRChatClient(url: "http://127.0.0.1:5000"));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState() {
    _chatClient = getIt<ChatClient>();
  }

  late ChatClient _chatClient;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _initChatClient();
  }

  @override
  void dispose() {
    super.dispose();
    _chatClient.close();
  }

  _initChatClient() async {
    await _chatClient.connect();
    _chatClient.setReceiveMessage((user, message) => setState(() {
          messages.add("$user : $message");
        }));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => Text(messages[index])),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
              ),
            ),
            IconButton(
              onPressed: () =>
                  _chatClient.sendMessage('flutterUser', controller.text),
              icon: Icon(Icons.send),
            )
          ],
        )
      ]),
    );
  }
}
