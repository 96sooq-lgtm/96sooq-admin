import 'package:_96sooq_admin/features/user_management/model/user_detail_model.dart';
import 'package:_96sooq_admin/features/user_management/model/user_model.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { initial, loading, loaded, error }

enum UserDetailStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  final UserStatus status;
  final List<UserModel> users;
  final bool hasReachedMax;
  final String? errorMessage;
  final bool isFetchingMore;

  final UserDetailStatus detailStatus;
  final UserDetailModel? userDetail;
  final String? detailErrorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.users = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.isFetchingMore = false,
    this.detailStatus = UserDetailStatus.initial,
    this.userDetail,
    this.detailErrorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    List<UserModel>? users,
    bool? hasReachedMax,
    String? errorMessage,
    bool? isFetchingMore,
    UserDetailStatus? detailStatus,
    UserDetailModel? userDetail,
    String? detailErrorMessage,
    bool clearDetail = false,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      detailStatus: clearDetail
          ? UserDetailStatus.initial
          : (detailStatus ?? this.detailStatus),
      userDetail: clearDetail ? null : (userDetail ?? this.userDetail),
      detailErrorMessage: clearDetail
          ? null
          : (detailErrorMessage ?? this.detailErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    hasReachedMax,
    errorMessage,
    isFetchingMore,
    detailStatus,
    userDetail,
    detailErrorMessage,
  ];
}
