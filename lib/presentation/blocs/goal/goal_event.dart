
import 'package:equatable/equatable.dart';
import 'package:orka_sports/data/models/goal_data/goal_data.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

// Event to trigger creating or updating a goal
class ManageGoal extends GoalEvent {
  final GoalData goalData;

  const ManageGoal(this.goalData);

  @override
  List<Object?> get props => [goalData];
}

// Event to trigger fetching goals for a user
class FetchGoals extends GoalEvent {
  final String userId;
  const FetchGoals(this.userId);

  @override
  List<Object?> get props => [userId];
}