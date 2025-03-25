import 'dart:developer';
import 'package:apphud/models/apphud_models/apphud_product.dart';
import 'package:flutter/cupertino.dart';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:pod_finder_pro_178/core/services/subscription_service.dart';

part 'main_paywall_event.dart';
part 'main_paywall_state.dart';

class MainPaywallBloc extends Bloc<MainPaywallEvent, MainPaywallState> {
  MainPaywallBloc() : super(const MainPaywallInitial()) {
    on<GetMainPaywallEvent>(_getMainPaywallHandler);

    add(GetMainPaywallEvent());
  }

  final _subscriptionService = GetIt.instance<SubscriptionService>();

  void _getMainPaywallHandler(
      GetMainPaywallEvent event, Emitter<MainPaywallState> emit) async {
    try {
      emit(const LoadingState());
      var mainPaywall = await _subscriptionService.getMainPaywall();
      final title = mainPaywall.json['title'];
      final tryFreeButton = mainPaywall.json['tryFreeButton'];
      final continueButton = mainPaywall.json['continueButton'];
      final purchaseButton = mainPaywall.json['purchaseButton'];

      var products = mainPaywall.products!;
      emit(LoadMainPaywallState(
        tryFreeButton: tryFreeButton,
        continueButton: continueButton,
        purchaseButton: purchaseButton,
        title: title,
        products: products,
      ));
      print('emmmited');
    } catch (e) {
      log(e.toString());
      emit(const ErrorState());
    }
  }
}
