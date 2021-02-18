import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProviderModelInApp with ChangeNotifier {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool available = true;
  StreamSubscription subscription;
  final String partyquestionpack = 'party_questionpack';
  final String adultquestionpack = '18plus_questionpack';
  final String psychoquestionpack = 'psycho_questionpack';
  final List<String> myProductList = [
    'party_questionpack',
    '18plus_questionpack',
    'psycho_questionpack'
  ];

  bool _isPurchased = false;
  //bool _isPurchasedAdult = false;
  //bool _isPurchasedPsycho = false;
  bool get isPurchased => _isPurchased;
  set isPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }

  List _purchases = [];
  List get purchases => _purchases;
  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }

  List _products = [];
  List get products => _products;
  set products(List value) {
    _products = value;
    notifyListeners();
  }

  void initialize() async {
    available = await _iap.isAvailable();
    if (available) {
      await _getProducts();
      await _getPastPurchases();
      verifyPurchase();
      subscription = _iap.purchaseUpdatedStream.listen((data) {
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }

  void verifyPurchase() {
    PurchaseDetails purchase = hasPurchased(partyquestionpack);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        isPurchased = true;
      }
    }
  }

  //Selbst erstellter Check
  bool checkPurchase(String productID) {
    bool check;
    PurchaseDetails purchase = hasPurchased(productID);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        check = true;
      } else {
        check = false;
      }
    } else {
      check = false;
    }
    return check;
  }

  PurchaseDetails hasPurchased(String productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  Future<void> _getProducts() async {
    //Set<String> ids = Set.from([partyquestionpack]);
    Set<String> ids = {
      partyquestionpack,
      adultquestionpack,
      psychoquestionpack
    };
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    products = response.productDetails;
  }

  //Selbst geschrieben
  Future<ProductDetails> getProduct(String productID) async {
    Set<String> ids = Set.from([productID]);

    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    ProductDetails product = response.productDetails.first;
    return product;
  }

  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        _iap.consumePurchase(purchase);
      }
    }
    purchases = response.pastPurchases;
  }
}
