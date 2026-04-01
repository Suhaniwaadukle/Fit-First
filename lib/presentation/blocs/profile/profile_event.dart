part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileData profile;

  const UpdateProfile(this.profile);

  @override
  List<Object> get props => [profile];
}

// ✅ New Event for Tab Index Change
class ChangeTabIndex extends ProfileEvent {
  final int index;

  const ChangeTabIndex(this.index);

  @override
  List<Object> get props => [index];
}
