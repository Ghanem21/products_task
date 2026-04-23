class Product {
  final int? id;
  final String imageUrl;
  final String name;
  final String type;
  final double price;

  Product({
    this.id,
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'type': type,
      'price': price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      type: map['type'],
      price: map['price'],
    );
  }

  Product copyWith({
    int? id,
    String? imageUrl,
    String? name,
    String? type,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
    );
  }
}
