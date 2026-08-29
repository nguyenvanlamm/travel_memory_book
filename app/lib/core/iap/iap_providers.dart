import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/src/types/product_details.dart';
import 'iap_service.dart';

final iapServiceProvider = Provider<IAPService>((ref) {
  final service = IAPService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for unlock status
final travelBooksUnlockedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(iapServiceProvider);
  await service.initialize();
  return service.isUnlockedLocally();
});

/// Provider for travel book count
final travelBookCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(iapServiceProvider);
  return service.getTravelBookCount();
});

/// Provider for unlock product details
final unlockProductProvider = FutureProvider<ProductDetails?>((ref) async {
  final service = ref.watch(iapServiceProvider);
  await service.initialize();
  if (service.products.isEmpty) return null;
  return service.unlockProduct;
});

/// State notifier for purchase flow
class PurchaseState {
  final bool isLoading;
  final String? error;
  final bool success;

  PurchaseState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  PurchaseState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final IAPService _service;

  PurchaseNotifier(this._service) : super(PurchaseState());

  Future<bool> purchaseUnlockTravelBooks() async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final success = await _service.buyUnlockTravelBooks();

    if (success) {
      state = state.copyWith(isLoading: false, success: true);
    } else {
      state = state.copyWith(
          isLoading: false, error: 'Purchase failed. Please try again.');
    }
    return success;
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    await _service.restorePurchases();
    state = state.copyWith(isLoading: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  final service = ref.watch(iapServiceProvider);
  return PurchaseNotifier(service);
});