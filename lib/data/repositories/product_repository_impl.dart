import 'dart:developer';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      log("Attempting to fetch products from remote...");
      final remoteProducts = await remoteDataSource.getProducts();
      return remoteProducts;
    } catch (e) {
      log("Remote fetch failed: $e. Falling back to local database.");
      return await localDataSource.getProducts();
    }
  }

  @override
  Future<int> addProduct(Product product) async {
    return await localDataSource.addProduct(product);
  }

  @override
  Future<int> updateProduct(Product product) async {
    return await localDataSource.updateProduct(product);
  }

  @override
  Future<int> deleteProduct(int id) async {
    return await localDataSource.deleteProduct(id);
  }
}
