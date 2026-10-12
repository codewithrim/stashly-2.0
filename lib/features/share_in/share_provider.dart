import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/share_parser.dart';

class ShareIntentState {
  final SharedPayload? pendingPayload;
  final String? errorMessage;

  const ShareIntentState({
    this.pendingPayload,
    this.errorMessage,
  });

  ShareIntentState copyWith({
    SharedPayload? pendingPayload,
    bool clearPayload = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShareIntentState(
      pendingPayload: clearPayload ? null : (pendingPayload ?? this.pendingPayload),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ShareIntentNotifier extends StateNotifier<ShareIntentState> {
  ShareIntentNotifier() : super(const ShareIntentState());

  void setSharedText(String text) {
    try {
      final payload = SharedPayload.parseText(text);
      if (payload == null) {
        state = state.copyWith(errorMessage: "Can't save empty content.");
      } else {
        state = state.copyWith(pendingPayload: payload, clearError: true);
      }
    } catch (_) {
      state = state.copyWith(errorMessage: "Can't save this content.");
    }
  }

  void consumePayload() {
    state = state.copyWith(clearPayload: true, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final shareIntentProvider = StateNotifierProvider<ShareIntentNotifier, ShareIntentState>((ref) {
  return ShareIntentNotifier();
});
