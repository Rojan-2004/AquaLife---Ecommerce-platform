import 'dart:async';
import 'package:light_sensor/light_sensor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LightSensorService {
  Stream<int> getLuxStream() => LightSensor.luxStream();

  bool isDarkFromLux(int lux) => lux <= 10;
}

final lightSensorServiceProvider = Provider<LightSensorService>((ref) {
  return LightSensorService();
});

final luxStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(lightSensorServiceProvider);
  return service.getLuxStream();
});
