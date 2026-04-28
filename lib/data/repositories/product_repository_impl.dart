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
    try {
      // Prefer server-created product so local DB keeps the same id as remote.
      final created = await remoteDataSource.createProduct(product);
      return await localDataSource.addProduct(created);
    } catch (e) {
      log("Remote create failed: $e. Saving locally only.");
      return await localDataSource.addProduct(product);
    }
  }

  @override
  Future<int> updateProduct(Product product) async {
    final localResult = await localDataSource.updateProduct(product);
    if (product.id == null) return localResult;

    try {
      await remoteDataSource.updateProduct(product);
    } catch (e) {
      log("Remote update failed: $e. Kept local update.");
    }
    return localResult;
  }

  @override
  Future<int> deleteProduct(int id) async {
    final localResult = await localDataSource.deleteProduct(id);
    try {
      await remoteDataSource.deleteProduct(id);
    } catch (e) {
      log("Remote delete failed: $e. Kept local delete.");
    }
    return localResult;
  }
}
