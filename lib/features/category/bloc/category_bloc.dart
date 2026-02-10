import 'package:_96sooq_admin/features/category/services/category_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryServices repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>(_loadCategories);
    on<CreateCategory>(_createCategory);
    on<UpdateCategory>(_updateCategory);
    on<DeleteCategory>(_deleteCategory);
  }

  Future<void> _loadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.fetchCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _createCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.createCategory(event.category);
      final currentState = state;
      if (currentState is CategoryLoaded) {
        emit(CategoryLoaded([event.category, ...currentState.categories]));
      } else {
        emit(CategoryLoaded([event.category]));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _updateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.updateCategory(event.id, event.category);
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updated = currentState.categories
            .map((c) => c.id == event.id ? event.category : c)
            .toList();
        emit(CategoryLoaded(updated));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _deleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.deleteCategory(event.id);
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updated = currentState.categories
            .where((c) => c.id != event.id)
            .toList();
        emit(CategoryLoaded(updated));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
