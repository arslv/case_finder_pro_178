part of 'main_paywall_bloc.dart';

@immutable
sealed class MainPaywallState {
  final List<ApphudProduct>? products;

  const MainPaywallState({this.products});
}

final class MainPaywallInitial extends MainPaywallState {
  const MainPaywallInitial({super.products});
}

final class LoadMainPaywallState extends MainPaywallState {
  final String title;
  final String tryFreeButton;
  final String continueButton;
  final String purchaseButton;

  const LoadMainPaywallState({
    super.products,
    required this.title,
    required this.tryFreeButton,
    required this.continueButton,
    required this.purchaseButton,
  });
}

final class LoadingState extends MainPaywallState {
  const LoadingState() : super();
}

final class ErrorState extends MainPaywallState {
  const ErrorState() : super();
}
