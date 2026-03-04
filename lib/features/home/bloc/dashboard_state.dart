import 'package:_96sooq_admin/features/home/model/dashboard_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel metrics;
  DashboardLoaded({required this.metrics});
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
