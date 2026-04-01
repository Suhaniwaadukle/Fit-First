import 'package:equatable/equatable.dart';
import 'package:orka_sports/data/models/product_details_model/product_details_model.dart';
import 'package:orka_sports/data/models/product_details_model/weight_variant_model.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object> get props => [];
}

// ✅ Existing states — do not modify
class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  final List<ProductDetailsModel> products;

  const ProductDetailsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

// ✅ New state — Loaded variants for selected weight
class ProductVariantsByWeightLoaded extends ProductDetailsState {
  final List<WeightVariantModel> variants;
  final List<String> allWeights;

  const ProductVariantsByWeightLoaded(this.variants, this.allWeights);

  @override
  List<Object> get props => [variants, allWeights];
}
