part of 'activity_subcategory_bloc.dart';

abstract class ActivitySubCategoryEvent extends Equatable {
  const ActivitySubCategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSubCategories extends ActivitySubCategoryEvent {
  final String activityId;
  final String activityType;

  const LoadSubCategories({
    required this.activityId,
    required this.activityType,
  });

  @override
  List<Object> get props => [activityId, activityType];
} 