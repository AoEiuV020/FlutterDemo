import 'package:socket_io/socket_io.dart';

void start() {
  var io = Server();
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
  io.listen(3000);
}
