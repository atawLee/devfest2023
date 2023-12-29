import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

abstract class ChatClient {
  Future<void> connect();
  Future<void> sendMessage(String user, String content);
  void setReceiveMessage(
      Function(String user, String message) onReceiveMessage);
  void close();
}

class SignalRChatClient extends ChatClient {
  late HubConnection hubConnection;
  String url;

  SignalRChatClient({required this.url});

  @override
  Future<void> connect() async {
    hubConnection = HubConnectionBuilder()
        .withUrl("$url/Chat")
        .withAutomaticReconnect()
        .build();

    await hubConnection.start();
  }

  @override
  Future<void> sendMessage(String user, String content) async {
    await hubConnection.send('SendMessage', args: [user, content]);
  }

  @override
  void setReceiveMessage(
      Function(String user, String message) onReceiveMessage) {
    hubConnection.on('ReceiveMessage', (arguments) {
      String user = arguments![0] as String;
      String message = arguments[1] as String;
      onReceiveMessage(user, message);
    });
  }

  @override
  void close() {
    hubConnection.stop();
  }
}
