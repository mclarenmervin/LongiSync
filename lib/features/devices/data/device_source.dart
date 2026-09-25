import '../../health/models/health_measurement.dart';

enum DeviceKind { ring, band, patch }

class ConnectedDevice {
  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.kind,
    this.battery,
    this.firmware,
    this.lastSync,
  });
  final String id;
  final String name;
  final DeviceKind kind;
  final int? battery;
  final String? firmware;
  final DateTime? lastSync;
}

abstract interface class DeviceSource {
  DeviceKind get kind;
  Future<List<ConnectedDevice>> discover();
  Future<void> connect(String id);
  Future<List<HealthMeasurement>> sync({
    required DateTime from,
    required DateTime to,
  });
  Future<void> disconnect();
}

abstract base class LongiSyncBandAdapter implements DeviceSource {
  @override
  DeviceKind get kind => DeviceKind.band;
}

abstract base class LongiSyncPatchAdapter implements DeviceSource {
  @override
  DeviceKind get kind => DeviceKind.patch;
}
