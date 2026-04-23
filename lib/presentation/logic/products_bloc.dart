import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'products_events.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository repository;
  List<Product> _allProducts = [];

  ProductsBloc({required this.repository, required ProductsState initialState})
      : super(initialState) {
    on<GetProductsEvent>((event, emit) async {
      await _loadProducts(emit, showLoading: true);
    });

    on<AddProductEvent>((event, emit) async {
      await repository.addProduct(event.product);
      await _loadProducts(emit, showLoading: false);
    });

    on<UpdateProductEvent>((event, emit) async {
      await repository.updateProduct(event.product);
      await _loadProducts(emit, showLoading: false);
    });

    on<DeleteProductEvent>((event, emit) async {
      if (state is ProductSuccessState) {
        final currentState = state as ProductSuccessState;
        final updatedProducts = currentState.products
            .where((p) => p.id != event.id)
            .toList();
        
        _allProducts = _allProducts.where((p) => p.id != event.id).toList();
        
        emit(ProductSuccessState(updatedProducts, isRefreshing: true));
      }

      await repository.deleteProduct(event.id);
      await _loadProducts(emit, showLoading: false);
    });

    on<RefreshProductsEvent>((event, emit) async {
      await _loadProducts(emit, showLoading: true);
    });

    on<SearchProductsEvent>((event, emit) {
      _searchProducts(event.query, emit);
    });

    on<ShowEmptyEvent>((event, emit) {
      emit(ProductSuccessState([]));
    });

    on<ShowErrorEvent>((event, emit) {
      emit(ProductErrorState("Manual Error Triggered"));
    });
  }

  Future<void> _loadProducts(Emitter<ProductsState> emit, {required bool showLoading}) async {
    if (showLoading) {
      emit(ProductLoadingState());
    } else if (state is ProductSuccessState) {
      emit(ProductSuccessState(_allProducts, isRefreshing: true));
    }
    try {
      _allProducts = await repository.getProducts();
      emit(ProductSuccessState(_allProducts, isRefreshing: false));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  void _searchProducts(String query, Emitter<ProductsState> emit) {
    if (query.isEmpty) {
      emit(ProductSuccessState(_allProducts));
    } else {
      final filteredProducts = _allProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      emit(ProductSuccessState(filteredProducts));
    }
  }
}
