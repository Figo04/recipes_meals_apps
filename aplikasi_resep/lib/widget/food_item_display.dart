import 'package:aplikasi_resep/Provider/favorit_provider.dart';
import 'package:aplikasi_resep/views/recipes_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class FoodItemDisplay extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const FoodItemDisplay({super.key, required this.documentSnapshot});

  @override
  State<FoodItemDisplay> createState() => _FoodItemDisplayState();
}

class _FoodItemDisplayState extends State<FoodItemDisplay> {
  @override
  Widget build(BuildContext context) {
    final Provider = FavoritProvider.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipesDetailScreen(documentSnapshot: widget.documentSnapshot),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.documentSnapshot['image'],
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            widget.documentSnapshot[
                                'image'], // image from firestore
                          ),
                        )),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.documentSnapshot['name'],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Iconsax.flash_1,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Text(
                      "${widget.documentSnapshot['cal']} Cal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      ".",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Iconsax.clock,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${widget.documentSnapshot['time']} Min",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
            //for fav button
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    Provider.toggleFavorite(widget.documentSnapshot);
                  },
                  child: Icon(
                    Provider.isExist(widget.documentSnapshot)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    color: Provider.isExist(widget.documentSnapshot)
                        ? Colors.red
                        : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
            // favorite screen design!!
          ],
        ),
      ),
    );
  }
}
