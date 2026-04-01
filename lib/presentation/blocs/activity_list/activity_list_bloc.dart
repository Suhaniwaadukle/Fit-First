import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_state.dart';
import '../../../data/repositories/activity_repository.dart';

class ActivityListBloc extends Bloc<ActivityListEvent, ActivityListState> {
  final ActivityRepository activityRepository;

   // ✅ ADD THIS FLAG
  bool _hasActivitiesLoaded = false;


  ActivityListBloc({required this.activityRepository}) : super(ActivityListInitial()) {
    on<LoadActivityList>(_onLoadActivityList);
  }

  Future<void> _onLoadActivityList(
    LoadActivityList event,
    Emitter<ActivityListState> emit,
  ) async {
    // ✅ CHECK FLAG FIRST - PREVENT DUPLICATE CALLS
    if (_hasActivitiesLoaded) return;
    
    emit(ActivityListLoading());
    try {
      final response = await activityRepository.getActivitiesList();
      if (response.status == 'success' && response.data != null) {
        _hasActivitiesLoaded = true; // ✅ SET FLAG ON SUCCESS
        emit(ActivityListLoaded(response.data!));
      } else {
        emit(ActivityListError(response.message));
      }
    } catch (e) {
      _hasActivitiesLoaded = false; // ✅ RESET ON ERROR FOR RETRY
      emit(ActivityListError(e.toString()));
    }
  }
}