import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/products_bloc.dart';
import '../logic/products_events.dart';
import '../logic/add_product_cubit.dart';

class AddProductBottomSheet extends StatelessWidget {
  const AddProductBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddProductCubit(),
      child: BlocBuilder<AddProductCubit, AddProductFormState>(
        builder: (context, state) {
          final cubit = context.read<AddProductCubit>();
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: cubit.updateName,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                  ),
                  TextField(
                    onChanged: cubit.updateType,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  TextField(
                    onChanged: cubit.updatePrice,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    onChanged: cubit.updateImageUrl,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isValid 
                      ? () {
                          context.read<ProductsBloc>().add(AddProductEvent(cubit.toProduct()));
                          Navigator.pop(context);
                        }
                      : null,
                    child: const Text('Add Product'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
