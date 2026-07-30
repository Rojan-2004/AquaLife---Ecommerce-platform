import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LightSensorService {
  static const _channel = EventChannel('aqua_life/light_sensor');

  Stream<int> getLuxStream() {
    final controller = StreamController<int>();
    Timer? pendingTimer;
    int? latestValue;
    bool done = false;

    _channel.receiveBroadcastStream().listen(
      (event) {
        final value = (event as int?) ?? 0;
        latestValue = value;
        pendingTimer?.cancel();
        pendingTimer = Timer(const Duration(milliseconds: 500), () {
          if (latestValue != null && !done) {
            controller.add(latestValue!);
            latestValue = null;
          }
        });
      },
      onError: controller.addError,
      onDone: () {
        done = true;
        pendingTimer?.cancel();
        if (latestValue != null) {
          controller.add(latestValue!);
        }
        controller.close();
      },
    );

    return controller.stream;
  }

  bool isDarkFromLux(int lux) => lux <= 10;
}

final lightSensorServiceProvider = Provider<LightSensorService>((ref) {
  return LightSensorService();
});

final luxStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(lightSensorServiceProvider);
  return service.getLuxStream();
});
