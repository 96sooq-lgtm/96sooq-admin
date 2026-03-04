import 'package:_96sooq_admin/features/user_management/bloc/user_event.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_state.dart';
import 'package:_96sooq_admin/features/user_management/services/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService;
  int _currentPage = 1;
  final int _limit = 20;
  bool _isFetchingMore = false;

  UserBloc(this._userService) : super(const UserState()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<LoadUserDetails>(_onLoadUserDetails);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    _isFetchingMore = false;
    emit(state.copyWith(status: UserStatus.loading, isFetchingMore: false));
    try {
      _currentPage = 1;
      final response = await _userService.fetchUsers(
        page: _currentPage,
        limit: _limit,
      );
      emit(
        state.copyWith(
          status: UserStatus.loaded,
          users: response.users,
          hasReachedMax: response.page >= response.pages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: UserStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UserState> emit,
  ) async {
    if (state.status == UserStatus.loading || state.hasReachedMax) return;
    if (_isFetchingMore) return;

    _isFetchingMore = true;
    emit(state.copyWith(isFetchingMore: true));

    _currentPage++;
    try {
      final response = await _userService.fetchUsers(
        page: _currentPage,
        limit: _limit,
      );

      if (response.users.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, isFetchingMore: false));
      } else {
        emit(
          state.copyWith(
            status: UserStatus.loaded,
            users: List.of(state.users)..addAll(response.users),
            hasReachedMax: response.page >= response.pages,
            isFetchingMore: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.error,
          errorMessage: e.toString(),
          isFetchingMore: false,
        ),
      );
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(detailStatus: UserDetailStatus.loading, clearDetail: true),
    );
    try {
      final detail = await _userService.fetchUserDetails(event.id);
      emit(
        state.copyWith(
          detailStatus: UserDetailStatus.loaded,
          userDetail: detail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: UserDetailStatus.error,
          detailErrorMessage: e.toString(),
        ),
      );
    }
  }
}
