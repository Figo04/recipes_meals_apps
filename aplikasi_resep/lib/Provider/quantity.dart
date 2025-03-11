import 'package:flutter/foundation.dart';

class QuantityProvider with ChangeNotifier {
  int _currentNumber = 1;
  List<String> _baseIngredientAmounts = [];

  int get currentNumber => _currentNumber;

  void setBaseIngredientAmounts(List<String> amounts) {
    _baseIngredientAmounts = amounts;
    notifyListeners();
  }

  List<String> get updateIngredientAmounts {
    return _baseIngredientAmounts.map((amount) {
      // Parse the amount and unit
      final parts = amount.trim().split(' ');
      if (parts.length < 2) return amount; // Return as is if no unit

      try {
        final baseNumber = double.parse(parts[0]);
        final unit = parts.sublist(1).join(' '); // Join rest of parts as unit
        final newNumber = baseNumber * _currentNumber;

        // Format the number to avoid unnecessary decimal places
        final formattedNumber = newNumber % 1 == 0
            ? newNumber.toInt().toString()
            : newNumber.toStringAsFixed(1);

        return '$formattedNumber $unit';
      } catch (e) {
        // If parsing fails, return original amount
        return amount;
      }
    }).toList();
  }

  void increaseQuantity() {
    _currentNumber++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_currentNumber > 1) {
      _currentNumber--;
      notifyListeners();
    }
  }
}
