import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';

class AddProductFormState {
  final String name;
  final String type;
  final String price;
  final String imageUrl;
  final bool isSubmitting;

  AddProductFormState({
    this.name = '',
    this.type = '',
    this.price = '',
    this.imageUrl = '',
    this.isSubmitting = false,
  });

  AddProductFormState copyWith({
    String? name,
    String? type,
    String? price,
    String? imageUrl,
    bool? isSubmitting,
  }) {
    return AddProductFormState(
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get isValid =>
      name.isNotEmpty &&
      type.isNotEmpty &&
      double.tryParse(price) != null &&
      imageUrl.isNotEmpty;
}

class AddProductCubit extends Cubit<AddProductFormState> {
  AddProductCubit() : super(AddProductFormState());

  void updateName(String name) => emit(state.copyWith(name: name));

  void updateType(String type) => emit(state.copyWith(type: type));

  void updatePrice(String price) => emit(state.copyWith(price: price));

  void updateImageUrl(String imageUrl) =>
      emit(state.copyWith(imageUrl: imageUrl));

  Product toProduct() => Product(
    name: state.name,
    type: state.type,
    price: double.tryParse(state.price) ?? 0.0,
    imageUrl: state.imageUrl,
  );
}
