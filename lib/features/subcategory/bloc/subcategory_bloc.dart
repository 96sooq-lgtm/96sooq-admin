import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/services/subcategory_service.dart';
import 'subcategory_event.dart';
import 'subcategory_state.dart';

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  final SubcategoryService service;
  static const int _pageSize = 10;

  SubcategoryBloc(this.service) : super(SubcategoryInitial()) {
    on<LoadSubcategories>(_loadAll);
    on<LoadMoreSubcategories>(_loadMore);
    on<CreateSubcategory>(_create);
    on<UpdateSubcategory>(_update);
    on<DeleteSubcategory>(_delete);
    on<DeleteSubcategoryAttribute>(_deleteAttribute);
    on<CreateSubcategoryAttribute>(_createAttribute);
    on<UpdateSubcategoryAttribute>(_updateAttribute);
  }

  Future<void> _loadAll(
    LoadSubcategories event,
    Emitter<SubcategoryState> emit,
  ) async {
    emit(SubcategoryLoading());
    try {
      final list = await service.fetchAllSubcategories(
        skip: 0,
        limit: _pageSize,
      );
      emit(SubcategoryLoaded(list, hasMore: list.length == _pageSize));
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _loadMore(
    LoadMoreSubcategories event,
    Emitter<SubcategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SubcategoryLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(
      SubcategoryLoaded(
        currentState.subcategories,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final next = await service.fetchAllSubcategories(
        skip: currentState.subcategories.length,
        limit: _pageSize,
      );
      final combined = [...currentState.subcategories, ...next];
      emit(SubcategoryLoaded(combined, hasMore: next.length == _pageSize));
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

  Future<void> _deleteAttribute(
    DeleteSubcategoryAttribute event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.deleteAttribute(event.subcategoryId, event.attributeName);
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _createAttribute(
    CreateSubcategoryAttribute event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.createAttribute(event.subcategoryId, event.payload);
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }

  Future<void> _updateAttribute(
    UpdateSubcategoryAttribute event,
    Emitter<SubcategoryState> emit,
  ) async {
    try {
      await service.updateAttribute(
        event.subcategoryId,
        event.attributeName,
        event.payload,
      );
      add(LoadSubcategories());
      emit(SubcategorySuccess());
    } catch (e) {
      emit(SubcategoryError(e.toString()));
    }
  }
}
