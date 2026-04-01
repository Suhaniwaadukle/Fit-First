
part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityAddedSuccess extends ActivityState {
  final InsertActivityResponse response;
  const ActivityAddedSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ActivitiesLoaded extends ActivityState {
  final List<ActivityData> activities;
  const ActivitiesLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivityOperationFailure extends ActivityState {
  final String error;
  const ActivityOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}