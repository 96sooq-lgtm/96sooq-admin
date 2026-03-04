import 'package:_96sooq_admin/features/home/bloc/dashboard_event.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_state.dart';
import 'package:_96sooq_admin/features/home/services/dashboard_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService dashboardService;

  DashboardBloc(this.dashboardService) : super(DashboardInitial()) {
    on<LoadDashboardMetrics>(_onLoadDashboardMetrics);
  }

  Future<void> _onLoadDashboardMetrics(
    LoadDashboardMetrics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final metrics = await dashboardService.fetchDashboardMetrics();
      emit(DashboardLoaded(metrics: metrics));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
