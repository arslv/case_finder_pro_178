part of 'main_paywall_bloc.dart';

@immutable
sealed class MainPaywallEvent {}

class GetMainPaywallEvent extends MainPaywallEvent {}