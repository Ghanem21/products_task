import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../widgets/product_card.dart';
import '../logic/animation_cubit.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimationCubit()..startFadeIn(duration: const Duration(milliseconds: 800)),
      child: BlocBuilder<AnimationCubit, double>(
        builder: (context, animationValue) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (BuildContext context, int index) {
              // Calculate interval manually since we aren't using AnimationController
              // Stagger the items but cap the start time so later items don't wait too long
              final double begin = (index * 0.1).clamp(0, 0.6);
              final double t = ((animationValue - begin) / (1.0 - begin)).clamp(0.0, 1.0);
              final double curveValue = Curves.easeOutCubic.transform(t);

              return Opacity(
                opacity: curveValue,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - curveValue)),
                  child: ProductCard(product: products[index]),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 12);
            },
            itemCount: products.length,
          );
        },
      ),
    );
  }
}
