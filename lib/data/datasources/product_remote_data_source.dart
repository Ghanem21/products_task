import 'package:dio/dio.dart';

import '../models/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(int id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Product>> getProducts() async {
    final res = await dio.get("/products");

    return (res.data as List).map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product> getProduct(int id) async {
    final res = await dio.get("/products/$id");
    return Product.fromJson(res.data);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final res = await dio.post("/products", data: product.toJson());

    return Product.fromJson(res.data);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final res = await dio.put(
      "/products/${product.id}",
      data: product.toJson(),
    );

    return Product.fromJson(res.data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await dio.delete("/products/$id");
  }
}
