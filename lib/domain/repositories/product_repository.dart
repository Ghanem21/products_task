import '../../data/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<int> addProduct(Product product);

  Future<int> updateProduct(Product product);

  Future<int> deleteProduct(int id);
}
