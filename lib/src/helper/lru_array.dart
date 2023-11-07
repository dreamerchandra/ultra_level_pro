import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PingPongStatus {
  requested,
  received,
  failed,
}

class PingPong {
  final PingPongStatus status;
  final int request;
  const PingPong({required this.status, required this.request});

  PingPong update(PingPongStatus status) {
    return PingPong(status: status, request: request);
  }
}

class LastNPingPong extends StateNotifier<List<PingPong>> {
  final int max;
  List<PingPong> _array = [];

  @override
  get state {
    return _array;
  }

  LastNPingPong({required this.max}) : super([]);

  void newRequest(PingPong value) {
    _array.add(value);
    _array = _array.length > max ? _array.sublist(1, max + 1) : _array;
    debugPrint("last 5 values, ${_array.map((e) => e.request).toList()}");
  }

  void update(int request, PingPongStatus newStatus) {
    _array = _array.map((element) {
      if (element.request == request) {
        return element.update(newStatus);
      }
      return element;
    }).toList();
  }

  bool isDeviceFailedToRespond() {
    if (state.length <= 3) {
      return false;
    }
    final reversedArray = _array.reversed.toList();
    final last = reversedArray.first;
    final beforeLast = reversedArray[1];
    final beforeBeforeLast = reversedArray[2];
    if (last.status != PingPongStatus.requested) {
      return last.status == PingPongStatus.failed &&
          beforeLast.status == PingPongStatus.failed;
    }
    return beforeBeforeLast.status == PingPongStatus.failed &&
        beforeLast.status == PingPongStatus.failed;
  }

  bool isDeviceShowingStale() {
    if (_array.length <= 2) {
      return false;
    }
    final reversedArray = _array.reversed.toList();
    final last = reversedArray.first;
    final beforeLast = reversedArray[1];
    return last.status == PingPongStatus.requested &&
        beforeLast.status == PingPongStatus.failed;
  }
}
