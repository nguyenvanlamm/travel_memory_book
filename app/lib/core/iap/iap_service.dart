import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product IDs - Must match App Store Connect / Google Play Console
const String _kUnlockTravelBooksProductId = 'unlock_travel_books';
const String _kPrefsKeyUnlocked = 'travel_books_unlocked';
const String _kPrefsKeyBookCount = 'travel_books_created_count';

/// Service for managing In-App Purchases
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  late Stream<List<PurchaseDetails>> _purchaseStream;
  late Future<void> _initialization;

  // Callbacks
  Function(bool unlocked)? onUnlockStatusChanged;
  Function(String error)? onError;

  Future<void> initialize() async {
    _initialization = _initialize();
    return _initialization;
  }

  Future<void> _initialize() async {
    final bool available = await _iap.isAvailable();
    _isAvailable = available;

    if (!available) {
      debugPrint('IAP: Not available on this device');
      return;
    }

    // Listen to purchase updates
    _purchaseStream = _iap.purchaseStream;
    _purchaseStream.listen(_onPurchaseUpdate, onError: _onPurchaseError);

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await _restorePurchases();

    // Check local unlock status
    await _checkLocalUnlockStatus();
  }

  Future<void> _loadProducts() async {
    final Set<String> productIds = {_kUnlockTravelBooksProductId};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP: Products not found: ${response.notFoundIDs}');
      onError?.call('Product not configured in store');
    }

    _products.clear();
    _products.addAll(response.productDetails);
    debugPrint('IAP: Loaded ${_products.length} products');
  }

  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP: Restore failed: $e');
    }
  }

  Future<void> _checkLocalUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getBool(_kPrefsKeyUnlocked) ?? false;
    if (unlocked) {
      onUnlockStatusChanged?.call(true);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    _purchases.addAll(purchaseDetailsList);
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyPurchase(purchase);
          break;
        case PurchaseStatus.error:
          onError?.call(purchase.error!.message);
          break;
        case PurchaseStatus.canceled:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _onPurchaseError(Object error) {
    debugPrint('IAP: Purchase stream error: $error');
    onError?.call(error.toString());
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    if (purchase.productID == _kUnlockTravelBooksProductId) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefsKeyUnlocked, true);
      onUnlockStatusChanged?.call(true);
      debugPrint('IAP: Travel books unlocked!');
    }
  }

  Future<bool> buyUnlockTravelBooks() async {
    if (!_isAvailable) {
      onError?.call('In-app purchases not available');
      return false;
    }

    final product = _products.firstWhere(
      (p) => p.id == _kUnlockTravelBooksProductId,
      orElse: () => throw Exception('Product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  bool get isAvailable => _isAvailable;
  bool get isUnlocked => _purchases.any((p) =>
      p.productID == _kUnlockTravelBooksProductId &&
      (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored));
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  ProductDetails? get unlockProduct => _products.firstWhere(
      (p) => p.id == _kUnlockTravelBooksProductId,
      orElse: () => throw Exception('Product not found'));

  /// Track travel book creation count locally
  Future<int> getTravelBookCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPrefsKeyBookCount) ?? 0;
  }

  Future<void> incrementTravelBookCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kPrefsKeyBookCount) ?? 0) + 1;
    await prefs.setInt(_kPrefsKeyBookCount, count);
  }

  Future<void> resetTravelBookCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefsKeyBookCount, 0);
  }

  Future<bool> isUnlockedLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPrefsKeyUnlocked) ?? false;
  }

  void dispose() {
    _purchaseStream.drain();
  }
}