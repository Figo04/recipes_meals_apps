import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favorites => _favoriteIds;

  FavoritProvider() {
    loadFavorites();
  }
  // toggle favorites states
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    notifyListeners();
  }

  // chek if a product is favorited
  bool isExist(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  // add favorites to firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite':
            true, // create the userFavorite collection and add item as favorites in firestore
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Remove favorite from firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // load favorites from firestore (store favorite or not)
  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(
        e.toString(),
      );
    }
    notifyListeners();
  }

  // Static method to access the provider form any context
  static FavoritProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoritProvider>(
      context,
      listen: listen,
    );
  }
}
