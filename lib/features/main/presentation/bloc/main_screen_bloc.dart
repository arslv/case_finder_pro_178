import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class MainScreenEvent extends Equatable {
  const MainScreenEvent();

  @override
  List<Object?> get props => [];
}

class TabChanged extends MainScreenEvent {
  final int index;

  const TabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

// States
class MainScreenState extends Equatable {
  final int currentIndex;

  const MainScreenState({
    required this.currentIndex,
  });

  factory MainScreenState.initial() {
    return const MainScreenState(currentIndex: 0);
  }

  MainScreenState copyWith({
    int? currentIndex,
  }) {
    return MainScreenState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [currentIndex];
}

// Bloc
class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  MainScreenBloc() : super(MainScreenState.initial()) {
    on<TabChanged>(_onTabChanged);
  }

  void _onTabChanged(TabChanged event, Emitter<MainScreenState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }
} 