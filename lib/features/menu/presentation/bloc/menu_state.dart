import 'package:equatable/equatable.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/entities/menu_item.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

// Initial state of the MenuState
class MenuInitialState extends MenuState {
  const MenuInitialState();
}

// -- SIDE EFFECT STATES --

/// Loading
class MenuLoadingState extends MenuState {
  const MenuLoadingState();
}

/// Loaded data
class MenuLoadedState extends MenuState {
  final List<MenuItem> menuItems;

  const MenuLoadedState({required this.menuItems});

  @override
  List<Object?> get props => [menuItems];
}

/// Error state
class MenuErrorState extends MenuState {
  final String message;

  const MenuErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
