import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  connect("http://localhost:3000", (data) {
    print(data);
  });
}

void connect(String url, Function(String) handler) {
  var socket = io.io(url, <String, dynamic>{
    'transports': ['websocket']
  });
  socket.onConnect((_) {
    handler('connect');
    socket.emit('msg', 'test');
  });
  socket.onConnecting((data) => handler("connecting: $data"));
  socket.onConnectError((data) => handler("connect error: $data"));
  socket.onConnectTimeout((data) => handler("connect timeout: $data"));
  socket.on('event', (data) => handler("event: $data"));
  socket.onDisconnect((_) => handler('disconnect'));
  socket.on('close', (_) => socket.disconnect());
  socket.open();
}