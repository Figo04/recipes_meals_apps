import 'package:aplikasi_resep/Utils/constants.dart';
import 'package:aplikasi_resep/views/view_all_items.dart';
import 'package:aplikasi_resep/widget/banner.dart';
import 'package:aplikasi_resep/widget/food_item_display.dart';
import 'package:aplikasi_resep/widget/my_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  String searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App-category");

  Query get fileteredRecipes {
    Query query = FirebaseFirestore.instance
        .collection("Complate-Flutter-apps")
        .where('category', isEqualTo: category);

    if (searchQuery.isNotEmpty) {
      // Menggunakan array-contains untuk mencari dalam array keywords
      query = query.where('searchKeywords',
          arrayContains: searchQuery.toLowerCase());
    }

    return query;
  }

  Query get allRecipes {
    Query query =
        FirebaseFirestore.instance.collection("Complate-Flutter-apps");

    if (searchQuery.isNotEmpty) {
      query = query.where('searchKeywords',
          arrayContains: searchQuery.toLowerCase());
    }

    return query;
  }

  Query get selectedRecipes =>
      category == "All" ? allRecipes : fileteredRecipes;

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  Widget selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  streamSnapshot.data!.docs.length,
                  (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            category = streamSnapshot.data!.docs[index]["name"];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: category ==
                                    streamSnapshot.data!.docs[index]["name"]
                                ? kprimaryColor
                                : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(right: 20),
                          child: Text(
                            streamSnapshot.data!.docs[index]["name"],
                            style: TextStyle(
                              color: category ==
                                      streamSnapshot.data!.docs[index]["name"]
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    mySearchBar(),
                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Kategori",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    selectedCategory(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Cepat & Mudah",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllItems(),
                              ),
                            );
                          },
                          child: Text(
                            "Lihat semua",
                            style: TextStyle(
                              color: kbannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: selectedRecipes.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Terjadi kesalahan dalam mengambil data'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(
                              Iconsax.search_normal,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              searchQuery.isEmpty
                                  ? 'Tidak ada resep tersedia'
                                  : 'Tidak ada resep yang cocok dengan "$searchQuery"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 5, left: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: snapshot.data!.docs
                            .map((e) => FoodItemDisplay(documentSnapshot: e))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Cari resep apa pun",
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        const Text(
          "Apa yang akan kamu\nmasak hari ini?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.notification,
          pressed: () {},
        ),
      ],
    );
  }
}
