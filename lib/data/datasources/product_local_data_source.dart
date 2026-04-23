import '../../core/database/database_helper.dart';
import '../models/product.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getProducts();

  Future<int> addProduct(Product product);

  Future<int> updateProduct(Product product);

  Future<int> deleteProduct(int id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper dbHelper;

  ProductLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<Product>> getProducts() async {
    return await dbHelper.readAllProducts();
  }

  @override
  Future<int> addProduct(Product product) async {
    return await dbHelper.create(product);
  }

  @override
  Future<int> updateProduct(Product product) async {
    return await dbHelper.update(product);
  }

  @override
  Future<int> deleteProduct(int id) async {
    return await dbHelper.delete(id);
  }
}
