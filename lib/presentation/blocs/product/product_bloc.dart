// lib/presentation/blocs/product/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart'; // Assuming the repository is here

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ActivityRepository repository; // Or a dedicated ProductRepository

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProductsByPartner>((event, emit) async {
      emit(ProductLoading());
      try {
        final response = await repository.getProductsByPartner(
          partnerId: event.partnerId,
          subcategoryId: event.subcategoryId,
        );
        emit(ProductLoaded(response.data));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}