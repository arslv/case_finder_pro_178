import 'dart:developer';

import 'package:apphud/apphud.dart';
import 'package:apphud/models/apphud_models/apphud_composite_model.dart';
import 'package:apphud/models/apphud_models/apphud_paywalls.dart';
import 'package:apphud/models/apphud_models/apphud_user.dart';
import 'package:apphud/models/apphud_models/composite/apphud_purchase_result.dart';


class SubscriptionService  {
  late ApphudUser _user;
  final String apphudKey = 'app_hqQShJyXbavow9sXWJQKnH7TAcNGCX';
  bool hasPermission = false;

  Future<SubscriptionService> init() async {
    _user = await Apphud.start(apiKey: apphudKey);
    hasPermission = await hasPremiumAccess();
    return this;
  }

  Future<ApphudPaywalls?> getPaywalls() async {
    try {
      final paywalls = await Apphud.paywalls();
      log(paywalls.toString());

      return paywalls;
    } catch (e) {
      log('Подписки: $e');
    }
  }

  dynamic getOnboardingPaywall() async {
    try {
      final onboardingPaywall =
          (await Apphud.paywalls())!.paywalls.last;
      return onboardingPaywall;
    } catch (e) {
      log(e.toString());
    }
  }

  dynamic getMainPaywall() async {
    try {
      final mainPaywall =
          (await Apphud.paywalls())!.paywalls.first;
      return mainPaywall;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<ApphudComposite> restore() async {
    try {
      final res = await Apphud.restorePurchases();
      return res;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<ApphudPurchaseResult> purchase(String productId) async {
    try {
      final res = await Apphud.purchase(productId: productId);
      return res;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> hasPremiumAccess() async => await Apphud.hasPremiumAccess();

  Future<void> updatePermission() async {
    hasPermission = await hasPremiumAccess();
  }
}