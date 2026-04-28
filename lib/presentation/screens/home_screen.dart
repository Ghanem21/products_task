import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'empty_screen.dart';
import 'error_screen.dart';
import 'loading_screen.dart';
import '../logic/products_bloc.dart';
import '../logic/products_events.dart';
import 'products_screen.dart';
import '../logic/products_state.dart';
import '../logic/search_cubit.dart';
import '../widgets/add_product_bottom_sheet.dart';
import '../../core/database/database_helper.dart';
import '../../data/datasources/product_local_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../core/Remote/dio_client.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddProductBottomSheet(BuildContext context, ProductsBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const AddProductBottomSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductsBloc(
            repository: ProductRepositoryImpl(
              localDataSource: ProductLocalDataSourceImpl(
                dbHelper: DatabaseHelper.instance,
              ),
              remoteDataSource: ProductRemoteDataSourceImpl(DioClient().dio),
            ),
            initialState: ProductLoadingState(),
          )..add(GetProductsEvent()),
        ),
        BlocProvider(create: (context) => SearchCubit()),
      ],
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, searchState) {
          final productsBloc = context.read<ProductsBloc>();
          final searchCubit = context.read<SearchCubit>();

          return Scaffold(
            appBar: AppBar(
              title: searchState.isSearching
                  ? TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      onChanged: (query) {
                        searchCubit.updateQuery(query);
                        productsBloc.add(SearchProductsEvent(query));
                      },
                    )
                  : const Text('Products'),
              leading: searchState.isSearching
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        searchCubit.closeSearch();
                        productsBloc.add(SearchProductsEvent(''));
                      },
                    )
                  : const Icon(Icons.menu),
              actions: [
                searchState.isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          if (searchState.query.isEmpty) {
                            searchCubit.closeSearch();
                          } else {
                            searchCubit.clearSearch();
                            productsBloc.add(SearchProductsEvent(''));
                          }
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          searchCubit.toggleSearch();
                        },
                      ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'empty') {
                      productsBloc.add(ShowEmptyEvent());
                    } else if (value == 'error') {
                      productsBloc.add(ShowErrorEvent());
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'empty',
                        child: Text('Show Empty'),
                      ),
                      const PopupMenuItem(
                        value: 'error',
                        child: Text('Show Error'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: _buildBody(state, productsBloc),
                      ),
                      if (state is ProductSuccessState && state.isRefreshing)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'refresh',
                  onPressed: () {
                    productsBloc.add(RefreshProductsEvent());
                  },
                  child: const Icon(Icons.sync),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () =>
                      _showAddProductBottomSheet(context, productsBloc),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProductsState state, ProductsBloc bloc) {
    if (state is ProductLoadingState) {
      return const LoadingScreen();
    } else if (state is ProductErrorState) {
      return ErrorScreen(
        title: 'Something went wrong!',
        message:
            'We couldn\'t load the products.\nPlease check your connection and try again.',
        buttonText: 'Retry',
        onRetry: () => bloc.add(GetProductsEvent()),
      );
    } else if (state is ProductSuccessState) {
      if (state.products.isEmpty) {
        return EmptyScreen(onRefresh: () => bloc.add(GetProductsEvent()));
      }
      return ProductsScreen(products: state.products);
    }
    return const SizedBox.shrink();
  }
}
