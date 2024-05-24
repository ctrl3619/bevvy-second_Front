import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final Set<String> _selectedTastes = {};
  final List<double> _ratings = List.generate(5, (index) => 0);
  final int totalBeers = 5;

  Set<String> get selectedTastes => _selectedTastes;
  List<double> get ratings => _ratings;

  void toggleTaste(String taste) {
    if (_selectedTastes.contains(taste)) {
      _selectedTastes.remove(taste);
    } else {
      _selectedTastes.add(taste);
    }
    notifyListeners();
  }

  void rateBeer(int index, double rating) {
    _ratings[index] = rating;
    notifyListeners();
  }
}
