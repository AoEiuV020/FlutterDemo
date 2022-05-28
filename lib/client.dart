import 'package:socket_io_client/socket_io_client.dart' as io;

main() {
  // Dart client
  var socket = io.io('http://localhost:3000', <String, dynamic>{
    'transports': ['websocket']
  });
  socket.onConnect((_) {
    print('connect');
    socket.emit('msg', 'test');
  });
  socket.onConnecting((data) => print("connecting: $data"));
  socket.onConnectError((data) => print("connect error: $data"));
  socket.onConnectTimeout((data) => print("connect timeout: $data"));
  socket.on('event', (data) => print("event: $data"));
  socket.onDisconnect((_) => print('disconnect'));
  socket.on('close', (_) => socket.disconnect());
}