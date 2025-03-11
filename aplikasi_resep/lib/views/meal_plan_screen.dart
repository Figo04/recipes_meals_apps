import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aplikasi_resep/Utils/constants.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final CollectionReference mealPlans =
      FirebaseFirestore.instance.collection("meal-plans");
  DateTime selectedDate = DateTime.now();
  List<String> mealTypes = ['Sarapan', 'Makan Siang', 'Makan Malam'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
  }

  String _formatDate(DateTime date, String pattern) {
    return DateFormat(pattern, 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor, // kbackgroundColor
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Perencanaan Makan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.add),
                    onPressed: () => _showAddMealDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: mealPlans
                    .where('date',
                        isEqualTo: _formatDate(selectedDate, 'yyyy-MM-dd'))
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Terjadi kesalahan'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.calendar_1,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada rencana makan untuk\n${_formatDate(selectedDate, 'dd MMMM yyyy')}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final meal = snapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: _getMealTypeIcon(meal['mealType']),
                          title: Text(
                            meal['recipeName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(meal['mealType']),
                          trailing: IconButton(
                            icon: const Icon(Iconsax.trash),
                            onPressed: () => _deleteMealPlan(meal.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _formatDate(date, 'yyyy-MM-dd') ==
              _formatDate(selectedDate, 'yyyy-MM-dd');

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1FCC79) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(date, 'EEE'),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(date, 'd'),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'Sarapan':
        return const Icon(Iconsax.coffee, color: Color(0xFF1FCC79));
      case 'Makan Siang':
        return const Icon(Iconsax.coffee, color: Color(0xFF1FCC79));
      case 'Makan Malam':
        return const Icon(Iconsax.coffee, color: Color(0xFF1FCC79));
      default:
        return const Icon(Iconsax.coffee);
    }
  }

  Future<void> _showAddMealDialog(BuildContext context) async {
    String selectedMealType = mealTypes[0];
    String recipeName = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Rencana Makan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMealType,
              decoration: const InputDecoration(labelText: 'Jenis Makanan'),
              items: mealTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => selectedMealType = value!,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Nama Resep'),
              onChanged: (value) => recipeName = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (recipeName.isNotEmpty) {
                _addMealPlan(selectedMealType, recipeName);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMealPlan(String mealType, String recipeName) async {
    await mealPlans.add({
      'date': _formatDate(selectedDate, 'yyyy-MM-dd'),
      'mealType': mealType,
      'recipeName': recipeName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteMealPlan(String docId) async {
    await mealPlans.doc(docId).delete();
  }
}
