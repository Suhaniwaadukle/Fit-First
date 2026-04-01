import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/profile/profile_model.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  // ✅ ADD THIS FLAG
  bool _hasProfileLoaded = false;

  ProfileBloc({required this.profileRepository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangeTabIndex>(_onChangeTabIndex); // ✅ Added
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // ✅ CHECK FLAG FIRST - PREVENT DUPLICATE CALLS
    if (_hasProfileLoaded) return;
    
    emit(const ProfileLoading());
    try {
      final response = await profileRepository.getProfile();

      if (response.success && response.data != null) {
        _hasProfileLoaded = true; // ✅ SET FLAG ON SUCCESS
        emit(ProfileLoaded(response.data!));
      } else {
        emit(ProfileError(response.message));
      }
    } catch (e) {
      _hasProfileLoaded = false; // ✅ RESET ON ERROR FOR RETRY
      emit(ProfileError(e.toString()));
    }
  }

Future<void> _onUpdateProfile(
  UpdateProfile event,
  Emitter<ProfileState> emit,
) async {
  final currentState = state;
  
  // Only emit ProfileUpdating if we're not already updating
  if (currentState is! ProfileUpdating) {
    emit(ProfileUpdating(event.profile));
  }
  
  try {
    await profileRepository.updateProfile(event.profile);
    
    // ✅ FIX: Emit ProfileLoaded instead of ProfileUpdated
    // This prevents the cascade of state changes that freeze the app
    emit(ProfileLoaded(event.profile, currentIndex: currentState.currentIndex));
    
    print('✅ Profile updated successfully - returned to ProfileLoaded state');
  } catch (e) {
    // Return to previous state on error instead of ProfileError
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(currentState.profile, currentIndex: currentState.currentIndex));
    } else {
      emit(ProfileError(e.toString(), currentIndex: currentState.currentIndex));
    }
    print('❌ Profile update failed: $e');
  }
}


  // ✅ New handler for tab index change
  void _onChangeTabIndex(
    ChangeTabIndex event,
    Emitter<ProfileState> emit,
  ) {
    final currentIndex = event.index;
    final currentState = state;

    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(currentState.profile, currentIndex: currentIndex));
    } else if (currentState is ProfileUpdated) {
      emit(ProfileUpdated(currentState.profile, currentIndex: currentIndex));
    } else if (currentState is ProfileUpdating) {
      emit(ProfileUpdating(currentState.profile, currentIndex: currentIndex));
    } else if (currentState is ProfileError) {
      emit(ProfileError(currentState.message, currentIndex: currentIndex));
    } else {
      emit(ProfileInitial(currentIndex: currentIndex));
    }
  }
}
