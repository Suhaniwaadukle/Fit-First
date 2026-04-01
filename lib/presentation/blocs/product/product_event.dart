// lib/presentation/blocs/product/product_event.dart
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProductsByPartner extends ProductEvent {
  final String partnerId;
  final String subcategoryId;

  LoadProductsByPartner({required this.partnerId, required this.subcategoryId});

  @override
  List<Object?> get props => [partnerId, subcategoryId];
}