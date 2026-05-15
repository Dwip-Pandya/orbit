import 'package:flutter/material.dart';
import '../models/password_entry.dart';

class VaultProvider extends ChangeNotifier {
  final List<PasswordEntry> _entries = [];
  final List<String> _categories = ['Social', 'Work', 'Entertainment', 'Finance', 'General', 'Other'];

  List<PasswordEntry> get entries => List.unmodifiable(_entries);
  List<String> get categories => List.unmodifiable(_categories);

  void addEntry(PasswordEntry entry) {
    _entries.insert(0, entry); 
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(isFavorite: !_entries[index].isFavorite);
      notifyListeners();
    }
  }

  // Category Management
  void addCategory(String name) {
    if (!_categories.contains(name)) {
      _categories.add(name);
      notifyListeners();
    }
  }

  void editCategory(String oldName, String newName) {
    final index = _categories.indexOf(oldName);
    if (index != -1) {
      _categories[index] = newName;
      // Update all entries with this category
      for (int i = 0; i < _entries.length; i++) {
        if (_entries[i].category == oldName) {
          _entries[i] = _entries[i].copyWith(category: newName);
        }
      }
      notifyListeners();
    }
  }

  void removeCategory(String name) {
    _categories.remove(name);
    // Reset entries with this category to 'General'
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].category == name) {
        _entries[i] = _entries[i].copyWith(category: 'General');
      }
    }
    notifyListeners();
  }

  List<PasswordEntry> get recentEntries {
    final sorted = List<PasswordEntry>.from(_entries);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  int get totalCount => _entries.length;
  int get favoriteCount => _entries.where((e) => e.isFavorite).length;
}
