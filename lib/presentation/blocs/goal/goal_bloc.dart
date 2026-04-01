import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/data/repositories/goal_repository_.dart';
import 'package:orka_sports/presentation/blocs/goal/goal_event.dart';
import 'package:orka_sports/presentation/blocs/goal/goal_state.dart' show GoalInitial, GoalLoading, GoalManageSuccess, GoalOperationFailure, GoalState, GoalsLoaded;



class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;

  GoalBloc({required this.goalRepository}) : super(GoalInitial()) {
    on<ManageGoal>(_onManageGoal);
    on<FetchGoals>(_onFetchGoals);
  }

  Future<void> _onManageGoal(
    ManageGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      // Basic client-side validation
      if (event.goalData.userId.isEmpty) {
        emit(const GoalOperationFailure("User ID is required."));
        return;
      }
      if (event.goalData.goalName.isEmpty) {
        emit(const GoalOperationFailure("Goal name cannot be empty."));
        return;
      }
      if (event.goalData.goalStep.isEmpty || int.tryParse(event.goalData.goalStep) == null) {
        emit(const GoalOperationFailure("Goal steps must be a valid number."));
        return;
      }
      if (event.goalData.goalKm.isEmpty || double.tryParse(event.goalData.goalKm) == null) {
        emit(const GoalOperationFailure("Goal kilometers must be a valid number."));
        return;
      }

      final response = await goalRepository.manageGoal(event.goalData);
      if (response.status.toLowerCase() == 'success') {
        emit(GoalManageSuccess(response));
        // Optionally, automatically refresh the goals list after a successful operation
        add(FetchGoals(event.goalData.userId));
      } else {
        emit(GoalOperationFailure(response.message));
      }
    } catch (e) {
      emit(GoalOperationFailure(e.toString()));
    }
  }

  Future<void> _onFetchGoals(
    FetchGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      if (event.userId.isEmpty) {
        emit(const GoalOperationFailure("User ID is required to fetch goals."));
        return;
      }
      
      final response = await goalRepository.getGoals(event.userId);
      if (response.status.toLowerCase() == 'success') {
        // API might return null for data if no goals, or an empty list
        emit(GoalsLoaded(response.data ?? []));
      } else {
        emit(GoalOperationFailure(response.message));
      }
    } catch (e) {
      emit(GoalOperationFailure(e.toString()));
    }
  }
}