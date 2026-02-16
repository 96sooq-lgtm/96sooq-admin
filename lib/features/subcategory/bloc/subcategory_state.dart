import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';

abstract class SubcategoryState {}

class SubcategoryInitial extends SubcategoryState {}

class SubcategoryLoading extends SubcategoryState {}

class SubcategoryLoaded extends SubcategoryState {
  final List<SubcategoryModel> subcategories;
  SubcategoryLoaded(this.subcategories);
}

class SubcategorySuccess extends SubcategoryState {}

class SubcategoryError extends SubcategoryState {
  final String message;
  SubcategoryError(this.message);
}
