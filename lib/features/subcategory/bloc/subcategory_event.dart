import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';

abstract class SubcategoryEvent {}

class LoadSubcategories extends SubcategoryEvent {}

class LoadMoreSubcategories extends SubcategoryEvent {}

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

class DeleteSubcategoryAttribute extends SubcategoryEvent {
  final String subcategoryId;
  final String attributeName;

  DeleteSubcategoryAttribute(this.subcategoryId, this.attributeName);
}

class CreateSubcategoryAttribute extends SubcategoryEvent {
  final String subcategoryId;
  final Map<String, dynamic> payload;

  CreateSubcategoryAttribute(this.subcategoryId, this.payload);
}

class UpdateSubcategoryAttribute extends SubcategoryEvent {
  final String subcategoryId;
  final String attributeName;
  final Map<String, dynamic> payload;

  UpdateSubcategoryAttribute(
    this.subcategoryId,
    this.attributeName,
    this.payload,
  );
}
