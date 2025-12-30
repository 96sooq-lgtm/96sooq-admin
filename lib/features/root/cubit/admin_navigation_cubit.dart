import 'package:flutter_bloc/flutter_bloc.dart';

class AdminNavigationCubit extends Cubit<int> {
  AdminNavigationCubit() : super(0);

  void changePage(int index) => emit(index);
}
