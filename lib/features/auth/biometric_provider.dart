import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/biometric_service.dart';

class BiometricLockState {
  final bool isBiometricEnabled;
  final bool isUnlocked;

  const BiometricLockState({
    this.isBiometricEnabled = false,
    this.isUnlocked = false,
  });

  BiometricLockState copyWith({
    bool? isBiometricEnabled,
    bool? isUnlocked,
  }) {
    return BiometricLockState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class BiometricLockNotifier extends StateNotifier<BiometricLockState> {
  BiometricLockNotifier() : super(const BiometricLockState());

  void setBiometricEnabled(bool enabled) {
    state = state.copyWith(isBiometricEnabled: enabled, isUnlocked: !enabled);
  }

  Future<bool> promptUnlock() async {
    if (!state.isBiometricEnabled) {
      state = state.copyWith(isUnlocked: true);
      return true;
    }

    final success = await BiometricService.instance.authenticate();
    if (success) {
      state = state.copyWith(isUnlocked: true);
    }
    return success;
  }

  void lockVault() {
    if (state.isBiometricEnabled) {
      state = state.copyWith(isUnlocked: false);
    }
  }
}

final biometricLockProvider =
    StateNotifierProvider<BiometricLockNotifier, BiometricLockState>((ref) {
  return BiometricLockNotifier();
});
