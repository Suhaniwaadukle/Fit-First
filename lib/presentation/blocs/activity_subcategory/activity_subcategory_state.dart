part of 'activity_subcategory_bloc.dart';

abstract class ActivitySubCategoryState extends Equatable {
  const ActivitySubCategoryState();

  @override
  List<Object> get props => [];
}

class ActivitySubCategoryInitial extends ActivitySubCategoryState {}

class ActivitySubCategoryLoading extends ActivitySubCategoryState {}

class ActivitySubCategoryLoaded extends ActivitySubCategoryState {
  final List<ActivitySubCategory> subCategories;

  const ActivitySubCategoryLoaded(this.subCategories);

  @override
  List<Object> get props => [subCategories];
}

class ActivitySubCategoryError extends ActivitySubCategoryState {
  final String message;

  const ActivitySubCategoryError(this.message);

  @override
  List<Object> get props => [message];
} 