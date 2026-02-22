import 'package:_96sooq_admin/features/category/services/category_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryServices repository;
  static const int _pageSize = 10;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>(_loadCategories);
    on<LoadMoreCategories>(_loadMoreCategories);
    on<LoadCategoriesPage>(_loadCategoriesPage);
    on<CreateCategory>(_createCategory);
    on<UpdateCategory>(_updateCategory);
    on<DeleteCategory>(_deleteCategory);
  }

  Future<void> _loadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    await _loadCategoriesPage(
      LoadCategoriesPage(skip: 0, limit: _pageSize),
      emit,
    );
  }

  Future<void> _loadCategoriesPage(
    LoadCategoriesPage event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.fetchCategories(
        skip: event.skip,
        limit: event.limit,
      );
      emit(
        CategoryLoaded(categories, hasMore: categories.length == event.limit),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _loadMoreCategories(
    LoadMoreCategories event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(
      CategoryLoaded(
        currentState.categories,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final next = await repository.fetchCategories(
        skip: currentState.categories.length,
        limit: _pageSize,
      );
      final combined = [...currentState.categories, ...next];
      emit(CategoryLoaded(combined, hasMore: next.length == _pageSize));
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
      add(LoadCategories());
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
      add(LoadCategories());
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
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
