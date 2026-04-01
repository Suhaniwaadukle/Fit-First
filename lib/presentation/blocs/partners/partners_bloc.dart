import 'package:flutter_bloc/flutter_bloc.dart';
import 'partners_event.dart';
import 'partners_state.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  final ActivityRepository repository;

  PartnersBloc(this.repository) : super(PartnersInitial()) {
    on<LoadPartners>((event, emit) async {
      emit(PartnersLoading());
      try {
        final response = await repository.getPartnersForSubCategory(
          userId: event.userId,
          subcategoryId: event.subcategoryId,
        );
        emit(PartnersLoaded(response.data));
      } catch (e) {
        emit(PartnersError(e.toString()));
      }
    });
  }
}