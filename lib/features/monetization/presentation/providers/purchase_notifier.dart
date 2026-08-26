import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';

const String kProMonthlyId = 'subguard_pro_monthly';
const String kProAnnualId = 'subguard_pro_annual';
const String kProStorageKey = 'subguard_is_pro_user';

class PurchaseState {
  final bool isPro;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<ProductDetails> products;

  const PurchaseState({
    this.isPro = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.products = const [],
  });

  PurchaseState copyWith({
    bool? isPro,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<ProductDetails>? products,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PurchaseState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      products: products ?? this.products,
    );
  }

  ProductDetails? get monthlyProduct =>
      products.where((p) => p.id == kProMonthlyId).firstOrNull;

  ProductDetails? get annualProduct =>
      products.where((p) => p.id == kProAnnualId).firstOrNull;
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SecureStorageService _storage;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PurchaseNotifier(this._storage) : super(const PurchaseState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Load cached Pro entitlement
      final cachedPro = await _storage.read(kProStorageKey);
      state = state.copyWith(isPro: cachedPro == 'true');

      // 2. Listen to Google Play Purchase Stream
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          logger.error('IAP Stream error', error);
          state = state.copyWith(errorMessage: error.toString());
        },
      );

      // 3. Query Store Products
      await loadProducts();
    } catch (e) {
      logger.error('IAP initialization error', e);
    }
  }

  Future<void> loadProducts() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        logger.debug('InAppPurchase is not available on this device/store');
        return;
      }

      final response = await _iap.queryProductDetails({
        kProMonthlyId,
        kProAnnualId,
      });

      if (response.notFoundIDs.isNotEmpty) {
        logger.debug('Products not found in store: ${response.notFoundIDs}');
      }

      state = state.copyWith(products: response.productDetails);
    } catch (e) {
      logger.error('Failed to query IAP products', e);
    }
  }

  Future<void> purchase(ProductDetails product) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initiate purchase: $e',
      );
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _iap.restorePurchases();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Purchases restored successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to restore purchases: $e',
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Unlock Pro
        await _storage.write(kProStorageKey, 'true');
        state = state.copyWith(
          isPro: true,
          isLoading: false,
          successMessage: 'SubGuard Pro unlocked successfully!',
        );

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
        );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Developer / sandbox toggle to enable/disable Pro status
  Future<void> setMockPro(bool value) async {
    await _storage.write(kProStorageKey, value ? 'true' : 'false');
    state = state.copyWith(isPro: value);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
      return PurchaseNotifier(secureStorage);
    });
