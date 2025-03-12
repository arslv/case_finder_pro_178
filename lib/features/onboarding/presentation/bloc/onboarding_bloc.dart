import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import '../../domain/models/onboarding_model.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingCompleted extends OnboardingEvent {}

// States
class OnboardingState extends Equatable {
  final int currentPage;
  final List<OnboardingModel> pages;
  final bool isLastPage;

  const OnboardingState({
    required this.currentPage,
    required this.pages,
    required this.isLastPage,
  });

  factory OnboardingState.initial() {
    return OnboardingState(
      currentPage: 0,
      pages: const [
        OnboardingModel(
          title: 'User choice',
          subtitle: 'Bluetooth Device Finder',
          description: 'Find, track, and access the exact location of\nyour devices at any time.',
          image: 'assets/images/onb_1.png',
        ),
        OnboardingModel(
          title: 'We value',
          subtitle: 'Your feedback',
          description: 'Please share your opinion\nabout our app Pod Finder Pro',
          image: 'assets/images/onb_2.png',
        ),
        OnboardingModel(
          title: 'Use',
          subtitle: 'Case Finder',
          description: "Access Case Finder feature to easily\nlocate your earphone's case.",
          image: 'assets/images/onb_3.png',
        ),
        OnboardingModel(
          title: 'Unlimited',
          subtitle: 'Access',
          description: 'Try 3 days free then \$4,99 / week\nOr proceed with limited version',
          image: 'assets/images/onb_4.png',
        ),
      ],
      isLastPage: false,
    );
  }

  OnboardingState copyWith({
    int? currentPage,
    List<OnboardingModel>? pages,
    bool? isLastPage,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      pages: pages ?? this.pages,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }

  @override
  List<Object?> get props => [currentPage, pages, isLastPage];
}

// Bloc
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState.initial()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onPageChanged(OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    HapticFeedback.selectionClick();
    final isLastPage = event.pageIndex == state.pages.length - 1;
    emit(state.copyWith(
      currentPage: event.pageIndex,
      isLastPage: isLastPage,
    ));
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    HapticFeedback.mediumImpact();
  }
} 