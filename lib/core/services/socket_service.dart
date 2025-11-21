import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static const String _baseUrl = 'https://rescueeats.onrender.com';
  late IO.Socket _socket;

  void connect(String userId, String userType) {
    _socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to Socket.IO');
      _socket.emit('joinRoom', {'type': userType, 'id': userId});
    });

    _socket.onDisconnect((_) => print('Disconnected from Socket.IO'));
    _socket.onError((data) => print('Socket Error: $data'));
  }

  void disconnect() {
    _socket.disconnect();
  }

  void onOrderStatusUpdated(Function(dynamic) callback) {
    _socket.on('order:status_updated', (data) {
      callback(data);
    });
  }

  void onOrderCreated(Function(dynamic) callback) {
    _socket.on('order:created', (data) {
      callback(data);
    });
  }
}
