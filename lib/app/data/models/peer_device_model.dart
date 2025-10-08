enum ConnectionStatus { found, connecting, connected, failed, disconnected }

class PeerDevice {
  final String id;
  final String name;
  final ConnectionStatus status;

  PeerDevice({
    required this.id,
    required this.name,
    this.status = ConnectionStatus.found,
  });

  // Helper method to create a copy with a new status
  PeerDevice copyWith({ConnectionStatus? status}) {
    return PeerDevice(id: id, name: name, status: status ?? this.status);
  }
}
