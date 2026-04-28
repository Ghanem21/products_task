import '../../data/models/product.dart';

sealed class ProductsEvent {}

class GetProductsEvent extends ProductsEvent {}

class RefreshProductsEvent extends ProductsEvent {}

class ShowEmptyEvent extends ProductsEvent {}

class ShowErrorEvent extends ProductsEvent {}

class AddProductEvent extends ProductsEvent {
  final Product product;

  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductsEvent {
  final Product product;

  UpdateProductEvent(this.product);
}

class DeleteProductEvent extends ProductsEvent {
  final int id;

  DeleteProductEvent(this.id);
}

class SearchProductsEvent extends ProductsEvent {
  final String query;

  SearchProductsEvent(this.query);
}
