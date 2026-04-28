import '../../data/models/product.dart';

sealed class ProductsState {}

class ProductLoadingState extends ProductsState {}

class ProductSuccessState extends ProductsState {
  final List<Product> products;
  final bool isRefreshing;

  ProductSuccessState(this.products, {this.isRefreshing = false});
}

class ProductErrorState extends ProductsState {
  final String errorMessage;

  ProductErrorState(this.errorMessage);
}
