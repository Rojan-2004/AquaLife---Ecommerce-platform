import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Confirm your identity to place this order',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'locked_out' ||
          e.code == 'lockout' ||
          e.code == 'lockout_permanent') {
        throw BiometricException(
          'Too many failed attempts. Please try again later or use your device PIN.',
        );
      }
      if (e.code == 'not_enrolled') {
        throw BiometricException(
          'No biometric data enrolled on this device.',
        );
      }
      if (e.code == 'hardware_unavailable' || e.code == 'unavailable') {
        throw BiometricException(
          'Biometric hardware is not available on this device.',
        );
      }
      if (e.code == 'user_cancel' || e.code == 'user_fallback') {
        throw BiometricException('Authentication cancelled.');
      }
      throw BiometricException('Authentication failed: ${e.message}');
    } catch (e) {
      if (e is BiometricException) {
        rethrow;
      }
      throw BiometricException('Authentication failed. Please try again.');
    }
  }
}

class BiometricException implements Exception {
  final String message;
  const BiometricException(this.message);

  @override
  String toString() => message;
}