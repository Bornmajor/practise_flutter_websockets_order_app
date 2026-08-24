import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

// Events

/// Fetching menu items event
class FetchMenuItemsEvent extends MenuEvent {}
