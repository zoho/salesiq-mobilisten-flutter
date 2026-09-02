import 'package:flutter/material.dart';

/// Colour family used for a product's placeholder image tile.
enum ProductTint { primary, secondary, accent }

class Product {
  final String id;
  final String name;
  final int price;
  final int? oldPrice;
  final double rating;
  final int reviews;
  final String blurb;
  final IconData icon;
  final ProductTint tint;
  const Product(this.id, this.name, this.price, this.oldPrice, this.rating,
      this.reviews, this.blurb, this.icon, this.tint);
}

class Order {
  final String id;
  final String productId;
  final String status; // Processing | Shipped | Delivered
  final String placed;
  final String eta;
  const Order(this.id, this.productId, this.status, this.placed, this.eta);
}

const products = <Product>[
  Product(
      'ZY-HP1',
      'Wireless headphones',
      129,
      159,
      4.6,
      2318,
      'Active noise cancellation, 30-hour battery, USB-C fast charge.',
      Icons.headphones,
      ProductTint.primary),
  Product(
      'ZY-WT2',
      'Smart watch',
      199,
      null,
      4.4,
      1102,
      'AMOLED display, GPS, heart-rate and SpO2 tracking, 7-day battery.',
      Icons.watch,
      ProductTint.secondary),
  Product(
      'ZY-SP3',
      'Bluetooth speaker',
      89,
      99,
      4.7,
      845,
      '360° sound, IP67 waterproof, 20-hour playtime.',
      Icons.speaker,
      ProductTint.accent),
  Product(
      'ZY-EB4',
      'Wireless earbuds',
      59,
      null,
      4.3,
      3760,
      'Compact, sweat-resistant, wireless charging case.',
      Icons.earbuds,
      ProductTint.primary),
  Product(
      'ZY-PC5',
      'Phone case',
      19,
      null,
      4.1,
      512,
      'Shock-absorbing bumper with a matte finish.',
      Icons.smartphone,
      ProductTint.secondary),
  Product(
      'ZY-CM6',
      'Action camera',
      249,
      279,
      4.5,
      289,
      '4K60 video, stabilization, waterproof to 10m.',
      Icons.camera_alt,
      ProductTint.accent),
];

const orders = <Order>[
  Order('A-1024', 'ZY-HP1', 'Shipped', 'Jul 3', 'Arriving Jul 9'),
  Order('A-1009', 'ZY-SP3', 'Delivered', 'Jun 21', 'Delivered Jun 25'),
];

Product? productById(String id) {
  for (final p in products) {
    if (p.id == id) return p;
  }
  return null;
}

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
}

/// In-memory cart shared across the store screens.
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (n, i) => n + i.qty);
  int get total => _items.fold(0, (s, i) => s + i.product.price * i.qty);

  void add(Product p) {
    for (final i in _items) {
      if (i.product.id == p.id) {
        i.qty++;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(p, 1));
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.product.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final cart = CartModel();
