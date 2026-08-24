import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/usecases/get_menu_items_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_events.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenuItemsUseCase getMenuItemsUseCase;

  MenuBloc({required this.getMenuItemsUseCase})
    : super(const MenuInitialState()) {
      on<FetchMenuItemsEvent>(
        _onFetchMenuItems,
        transformer: restartable()
        );
    }

  Future<void> _onFetchMenuItems(
    FetchMenuItemsEvent event,
    Emitter<MenuState> emit,
  ) async {
    //Emit loading state before fetching data
    emit(MenuLoadingState());

    // Call the use case
    final result = await getMenuItemsUseCase();

    result.fold(
      (failure) => emit(MenuErrorState(message: failure.message)),
      (items) => emit(MenuLoadedState(menuItems: items)),
    );
  }
}
