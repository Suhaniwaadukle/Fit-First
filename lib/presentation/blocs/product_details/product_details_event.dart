import 'package:equatable/equatable.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object> get props => [];
}

// ✅ Existing event – Do not modify
class LoadProductDetails extends ProductDetailsEvent {
  final String partnerId;
  final String subCategoryId;
  final String productName;

  const LoadProductDetails({
    required this.partnerId,
    required this.subCategoryId,
    required this.productName,
  });

  @override
  List<Object> get props => [partnerId, subCategoryId, productName];
}

// ✅ 🔁 New event – For loading variants based on selected weight
class LoadVariantsByWeight extends ProductDetailsEvent {
  final String partnerId;
  final String subCategoryId;
  final String productName;
  final String productWeight;

  const LoadVariantsByWeight({
    required this.partnerId,
    required this.subCategoryId,
    required this.productName,
    required this.productWeight,
  });

  @override
  List<Object> get props => [partnerId, subCategoryId, productName, productWeight];
}
