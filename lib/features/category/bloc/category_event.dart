import 'package:_96sooq_admin/features/category/model/category_model.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final CategoryModel category;

  CreateCategory(this.category);
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final CategoryModel category;

  UpdateCategory(this.id, this.category);
}

class DeleteCategory extends CategoryEvent {
  final String id;

  DeleteCategory(this.id);
}
