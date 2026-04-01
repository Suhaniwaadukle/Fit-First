
import 'package:equatable/equatable.dart';

abstract class ActivityListEvent extends Equatable {
  const ActivityListEvent();

  @override
  List<Object> get props => [];
}

class LoadActivityList extends ActivityListEvent {} 