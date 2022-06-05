import 'package:demo/connect/connect.dart'
    if (dart.library.html) 'package:demo/connect/connect_web.dart'
    if (dart.library.io) 'package:demo/connect/connect_native.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

const defaultInput = "wss://echo.websocket.events/";

void main() {
  connect(defaultInput, (data) {
    print(data);
  });
}

void connect(String url, Function(String) handler) {
  final WebSocketChannel channel;
  channel = connectAutoPlatform(url);
  final sink = channel.sink;
  final stream = channel.stream;

  stream.listen((message) {
    message as String;
    handler(message);
    if (message == "close") {
      sink.close(status.normalClosure);
    }
  });
  sink.add('hello,');
  sink.add('close');
}
