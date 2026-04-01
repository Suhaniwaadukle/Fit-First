part of 'profile_bloc.dart';

// ✅ Modified abstract class with currentIndex
abstract class ProfileState extends Equatable {
  final int currentIndex;

  const ProfileState({this.currentIndex = 0});

  @override
  List<Object> get props => [currentIndex];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial({super.currentIndex});
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({super.currentIndex});
}

class ProfileLoaded extends ProfileState {
  final ProfileData profile;

  const ProfileLoaded(this.profile, {super.currentIndex});

  @override
  List<Object> get props => [profile, currentIndex];
}

class ProfileUpdating extends ProfileState {
  final ProfileData profile;

  const ProfileUpdating(this.profile, {super.currentIndex});

  @override
  List<Object> get props => [profile, currentIndex];
}

class ProfileUpdated extends ProfileState {
  final ProfileData profile;

  const ProfileUpdated(this.profile, {super.currentIndex});

  @override
  List<Object> get props => [profile, currentIndex];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message, {super.currentIndex});

  @override
  List<Object> get props => [message, currentIndex];
}
