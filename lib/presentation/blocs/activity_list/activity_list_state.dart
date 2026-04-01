
import 'package:equatable/equatable.dart';
import 'package:orka_sports/data/models/activity_model/activity_list_model.dart';

abstract class ActivityListState extends Equatable {
  const ActivityListState();

  @override
  List<Object> get props => [];
}

class ActivityListInitial extends ActivityListState {}

class ActivityListLoading extends ActivityListState {}

class ActivityListLoaded extends ActivityListState {
  final List<ActivityListItem> activities;

  const ActivityListLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class ActivityListError extends ActivityListState {
  final String message;

  const ActivityListError(this.message);

  @override
  List<Object> get props => [message];
} 