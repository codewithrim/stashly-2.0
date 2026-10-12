import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  static final BiometricService instance = BiometricService._internal();

  BiometricService._internal();

  /// Check if hardware supports biometrics and device has enrolled fingerprints/face
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate using Face ID, Fingerprint, or fallback device passcode
  Future<bool> authenticate({
    String reason = 'Please authenticate to unlock your Stashly vault',
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        // If biometrics are not enrolled or supported, allow entry gracefully
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
