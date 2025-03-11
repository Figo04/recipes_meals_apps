import 'dart:ffi';

import 'package:aplikasi_resep/Provider/favorit_provider.dart';
import 'package:aplikasi_resep/Provider/quantity.dart';
import 'package:aplikasi_resep/Utils/constants.dart';
import 'package:aplikasi_resep/widget/my_icon_button.dart';
import 'package:aplikasi_resep/widget/quantity_increment_decrement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cooking_steps_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class RecipesDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const RecipesDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipesDetailScreen> createState() => _RecipesDetailScreenState();
}

class _RecipesDetailScreenState extends State<RecipesDetailScreen> {
  @override
  void initState() {
    // initialize base ingredients amounts in the provider
    List<String> baseAmounts = widget.documentSnapshot['ingredientsamount']
        .map<String>((amount) => amount.toString())
        .toList();
    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts(baseAmounts);
    super.initState();
  }

  Widget build(BuildContext context) {
    final provider = FavoritProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // for image
                Hero(
                  tag: widget.documentSnapshot['image'],
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          widget.documentSnapshot['image'],
                        ),
                      ),
                    ),
                  ),
                ),
                // for back button
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                          icon: Icons.arrow_back_ios_new,
                          pressed: () {
                            Navigator.pop(context);
                          }),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        pressed: () {},
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width / 1.05,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            // for drag handle
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        size: 20,
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
                  ),
                  const SizedBox(height: 10),
                  // for
                  Row(
                    children: [
                      Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot["rate"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['reviews'.toString()]} Reviews",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bahan-bahan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "berapa porsi",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemove: () => quantityProvider.decreaseQuantity(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // List of ingredients
                  Column(
                    children: [
                      Row(
                        children: [
                          // Ingredients image
                          Column(
                            children: widget
                                .documentSnapshot['ingredientsimage']
                                .map<Widget>(
                                  (imageUrl) => Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          imageUrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(width: 20),
                          // Ingredients name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.documentSnapshot['ingredientname']
                                .map<Widget>((ingredient) => SizedBox(
                                      height: 73,
                                      child: Center(
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          // ingredient amount
                          const Spacer(),
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>((amount) => SizedBox(
                                      height: 73,
                                      child: Center(
                                        child: Text(
                                          amount, // Now directly using the string
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(FavoritProvider Provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 12),
              foregroundColor: Colors.white,
            ),
            // In RecipesDetailScreen.dart, update the onPressed of the "Mulai Memasak" button:
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CookingStepsScreen(
                    documentSnapshot: widget.documentSnapshot,
                  ),
                ),
              );
            },
            child: Text(
              "Mulai Memasak",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            onPressed: () {
              Provider.toggleFavorite(widget.documentSnapshot);
            },
            icon: Icon(
              Provider.isExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: Provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
