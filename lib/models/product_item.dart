
class ProductItem {
  final String name;
  final String description;
  final double price;
  final String photo;
  final bool availability;

  ProductItem({
    required this.name,
    required this.description,
    required this.price,
    required this.photo,
    required this.availability,
  });

  factory ProductItem.fromFirestore(Map<String, dynamic> data) {
    return ProductItem(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      photo: data['image'] ?? '',
      availability: data['availability'] ?? false,
    );
  }
}
