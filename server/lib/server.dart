import 'package:socket_io/socket_io.dart';

void start() {
  var server = Server();
  var io = server.of("sub");
  io.on('connection', (client) {
    print('connection');
    client.on('msg', (data) {
      print('data: $data');
      client.emit('close');
    });
    client.emit('event', "hello");
    client.on('disconnect', (data) {
      print('disconnect');
    });
  });
  server.listen(3000);
}
