
import 'package:equatable/equatable.dart';
import 'package:orka_sports/data/models/goal_data/goal_data.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

// State when a goal has been successfully managed (created/updated)
class GoalManageSuccess extends GoalState {
  final ManageGoalResponse response;
  const GoalManageSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

// State when goals have been successfully loaded
class GoalsLoaded extends GoalState {
  final List<GoalData> goals;
  const GoalsLoaded(this.goals);

  @override
  List<Object?> get props => [goals];
}

// State when an operation (manage or fetch) fails
class GoalOperationFailure extends GoalState {
  final String error;
  const GoalOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}