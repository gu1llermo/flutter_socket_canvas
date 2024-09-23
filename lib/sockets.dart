import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Sockets {
  late IO.Socket socket;

  late StreamController<Offset?> _paintStreamController;
  late StreamController<bool> _clearStreamController;

  bool isConnected = false;

  static final _singleton = Sockets._internal();

  factory Sockets() {
    return _singleton;
  }

  Sockets._internal() {
    socket = IO.io(socketUrl(), <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      debugPrint('Conectado!!!');
      isConnected = true;
    });

    socket.onDisconnect((_) {
      debugPrint('Se ha desconectado del servidor');
      isConnected = false;
    });

    socket.on('connect_error', (data) => debugPrint('connect_error: $data'));
    socket.on(
        'reconnect_attempt', (data) => debugPrint('reconnect_attempt $data'));
    socket.on(
        'reconnect_failed', (data) => debugPrint('reconnect_failed $data'));

    _paintStreamController = StreamController<Offset?>.broadcast();
    _clearStreamController = StreamController<bool>.broadcast();

    socket.on('draw', (data) {
      final offset = jsonDecode(data);

      _paintStreamController.add(Offset(offset['dx'], offset['dy']));
    });

    socket.on('endLine', (data) => _paintStreamController.add(null));

    socket.on('cleaningCanvas', (_) {
      _clearStreamController.add(true);
    });
  }

  String socketUrl() {
    return "http://192.168.100.20:3000";
    // Es la dirección ip donde está corriendo el server
    // si usas windows, desde cmd puedes escribir ipconfig y allí puedes encontrar
    // esa dirección, es mejor configurarla estatica, para que el router
    // no se la asigne automaticamente cada vez que se conecta
  }

  emitPaint(double dx, double dy) {
    if (isConnected) {
      socket.emit('canvas', '{"dx": $dx, "dy": $dy}');
    }
  }

  emitEndLine() {
    if (isConnected) {
      socket.emit('endLine');
    }
  }

  emitClearCanvas() {
    if (isConnected) {
      socket.emit('clearCanvas', '');
    }
  }

  Stream<Offset?> recivedPaint() {
    return _paintStreamController.stream;
  }

  Stream<bool> clearCanvas() {
    return _clearStreamController.stream;
  }
}
