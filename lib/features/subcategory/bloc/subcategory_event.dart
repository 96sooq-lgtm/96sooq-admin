import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';

abstract class SubcategoryEvent {}

class LoadSubcategories extends SubcategoryEvent {}

class CreateSubcategory extends SubcategoryEvent {
  final SubcategoryModel model;

  CreateSubcategory(this.model);
}

class UpdateSubcategory extends SubcategoryEvent {
  final String id;
  final SubcategoryModel model;

  UpdateSubcategory(this.id, this.model);
}

class DeleteSubcategory extends SubcategoryEvent {
  final String id;

  DeleteSubcategory(this.id);
}
