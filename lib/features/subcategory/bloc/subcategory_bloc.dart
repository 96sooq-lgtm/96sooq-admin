import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/services/subcategory_service.dart';
import 'subcategory_event.dart';
import 'subcategory_state.dart';

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  final SubcategoryService service;

  SubcategoryBloc(this.service) : super(SubcategoryInitial()) {
    on<LoadSubcategories>(_loadAll);
    on<CreateSubcategory>(_create);
    on<UpdateSubcategory>(_update);
    on<DeleteSubcategory>(_delete);
  }

  Future<void> _loadAll(
    LoadSubcategories event,
    Emitter<SubcategoryState> emit,
  ) async {
    emit(SubcategoryLoading());
    try {
      final list = await service.fetchAllSubcategories();
      emit(SubcategoryLoaded(list));
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _create(
    CreateSubcategory event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.createSubcategory(event.model);
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _update(
    UpdateSubcategory event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.updateSubcategory(event.id, event.model);
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _delete(
    DeleteSubcategory event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.deleteSubcategory(event.id);
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }
}
