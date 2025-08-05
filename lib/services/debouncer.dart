import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Throttler {
  final int milliseconds;
  final _controller = StreamController<VoidCallback>();
  late final StreamSubscription _subscription;

  Throttler({required this.milliseconds}) {
    _subscription = _controller.stream.throttleTime(Duration(milliseconds: milliseconds), trailing: false).listen((action) => action());
  }

  void run(VoidCallback action) {
    _controller.add(action);
  }

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
