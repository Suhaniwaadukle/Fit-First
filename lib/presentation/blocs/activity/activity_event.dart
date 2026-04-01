part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class AddActivity extends ActivityEvent {
  final ActivityData activityData;

  const AddActivity(this.activityData);

  @override
  List<Object?> get props => [activityData];
}

class FetchActivities extends ActivityEvent {
  final String userId;
  const FetchActivities(this.userId);

  @override
  List<Object?> get props => [userId];
}