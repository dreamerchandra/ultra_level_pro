import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble_ping_pong.g.dart';

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

@immutable
class LastNPingPongMeta {
  final int max;
  final List<PingPong> pingPongs;

  const LastNPingPongMeta({required this.max, required this.pingPongs});

  LastNPingPongMeta newRequest(PingPong value) {
    return LastNPingPongMeta(
      pingPongs: pingPongs.isEmpty ? [value] : pingPongs.sublist(1, max + 1)
        ..add(value),
      max: max,
    );
  }

  LastNPingPongMeta update(int request, PingPongStatus newStatus) {
    final newArray = pingPongs.map((element) {
      if (element.request == request) {
        return element.update(newStatus);
      }
      return element;
    }).toList();
    return LastNPingPongMeta(max: max, pingPongs: newArray);
  }

  bool isDeviceFailedToRespond() {
    if (pingPongs.length <= 3) {
      return false;
    }
    final reversedArray = pingPongs.reversed.toList();
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
    if (pingPongs.length <= 2) {
      return false;
    }
    final reversedArray = pingPongs.reversed.toList();
    final last = reversedArray.first;
    final beforeLast = reversedArray[1];
    return last.status == PingPongStatus.requested &&
        beforeLast.status == PingPongStatus.failed;
  }
}

@riverpod
class LastNPingPong extends _$LastNPingPong {
  @override
  LastNPingPongMeta build(int max) {
    return LastNPingPongMeta(max: max, pingPongs: const []);
  }

  get _pingPongs {
    return state.pingPongs;
  }
}
