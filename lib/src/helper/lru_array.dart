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

class LastNPingPong {
  final int max;
  late List<PingPong> array = [];
  LastNPingPong({required this.max});
  void newRequest(PingPong value) {
    array = array.sublist(1, max);
    array.add(value);
  }

  void update(int request, PingPongStatus newStatus) {
    array = array.map((element) {
      if (element.request == request) {
        return element.update(newStatus);
      }
      return element;
    }).toList();
  }

  bool isDeviceFailedToRespond() {
    if (array.length < 2) {
      return false;
    }
    final [last, beforeLast] = array.reversed.toList();
    return last.status == PingPongStatus.failed &&
        beforeLast.status == PingPongStatus.failed;
  }

  bool isDeviceShowingStale() {
    if (array.length < 2) {
      return false;
    }
    final [last, beforeLast] = array.reversed.toList();
    return last.status == PingPongStatus.requested &&
        beforeLast.status == PingPongStatus.failed;
  }
}
