class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    int? stock,
    String? imageUrl,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
