import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  late StreamController _streamController;

  WebSocketProvider() {
    _streamController = StreamController.broadcast();
  }

  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel?.stream.listen((event) {
        _streamController.add(event);
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
    _streamController.stream.listen((data) {print(data);});
    print("Connected to $url");
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    notifyListeners();
  }

  void onMessage(Function(dynamic) callback) {
    _streamController.stream.listen(callback);
  }

  //clear a specific listener
  void removeOnMessage(Function(dynamic) callback) {
    _streamController.stream.listen(callback).cancel();
  }

  void sendMessage(String message) {
    print("sending message: $message");
    _channel?.sink.add(message);
  }

  @override
  void dispose() {
    _channel?.sink.close(status.goingAway);
    _streamController.close();
    super.dispose();
  }
}