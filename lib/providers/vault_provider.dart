import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/password_entry.dart';

class VaultProvider extends ChangeNotifier {
  List<PasswordEntry> _entries = [];
  List<String> _categories = ['Social', 'Work', 'Entertainment', 'Finance', 'General', 'Other'];
  String _backupSchedule = 'never'; // 'daily', 'weekly', 'monthly', 'never'

  List<PasswordEntry> get entries => List.unmodifiable(_entries);
  List<String> get categories => List.unmodifiable(_categories);
  String get backupSchedule => _backupSchedule;

  VaultProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load categories
    final catsJson = prefs.getString('vault_categories_cache');
    if (catsJson != null) {
      final List<dynamic> decoded = jsonDecode(catsJson);
      _categories = decoded.map((e) => e.toString()).toList();
    }

    // Load entries
    final entriesJson = prefs.getString('vault_entries_cache');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries = decoded.map((e) => PasswordEntry.fromJson(e)).toList();
    }

    // Load backup schedule
    _backupSchedule = prefs.getString('backup_schedule') ?? 'never';

    notifyListeners();
    _checkAndRunScheduledBackup();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vault_categories_cache', jsonEncode(_categories));
    await prefs.setString('vault_entries_cache', jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  Future<void> setBackupSchedule(String schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backup_schedule', schedule);
    _backupSchedule = schedule;
    notifyListeners();
    _checkAndRunScheduledBackup();
  }

  Future<void> _checkAndRunScheduledBackup() async {
    if (_backupSchedule == 'never' || _entries.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final lastBackupTime = prefs.getInt('last_backup_timestamp') ?? 0;
    final now = DateTime.now();
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastBackupTime);
    final diff = now.difference(lastDate);

    bool shouldBackup = false;
    if (_backupSchedule == 'daily' && diff.inDays >= 1) shouldBackup = true;
    if (_backupSchedule == 'weekly' && diff.inDays >= 7) shouldBackup = true;
    if (_backupSchedule == 'monthly' && diff.inDays >= 30) shouldBackup = true;
    if (lastBackupTime == 0) shouldBackup = true;

    if (shouldBackup) {
      await createAutomatedBackup();
    }
  }

  Future<String?> createAutomatedBackup() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${docDir.path}/automated_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final file = File('${backupDir.path}/orbit_backup_$timestamp.json');

      final data = exportVault();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonString);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_backup_timestamp', now.millisecondsSinceEpoch);

      return file.path;
    } catch (e) {
      debugPrint('Automated backup error: $e');
    }
    return null;
  }

  Future<List<File>> getAutomatedBackupFiles() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${docDir.path}/automated_backups');
      if (!await backupDir.exists()) return [];

      final files = backupDir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      debugPrint('Error reading backups: $e');
    }
    return [];
  }

  void addEntry(PasswordEntry entry) {
    _entries.insert(0, entry); 
    _saveCache();
    notifyListeners();
  }

  void updateEntry(PasswordEntry updatedEntry) {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _saveCache();
      notifyListeners();
    }
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveCache();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(isFavorite: !_entries[index].isFavorite);
      _saveCache();
      notifyListeners();
    }
  }

  // Category Management
  void addCategory(String name) {
    if (!_categories.contains(name)) {
      _categories.add(name);
      _saveCache();
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
      _saveCache();
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
    _saveCache();
    notifyListeners();
  }

  List<PasswordEntry> get recentEntries {
    final sorted = List<PasswordEntry>.from(_entries);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  int get totalCount => _entries.length;
  int get favoriteCount => _entries.where((e) => e.isFavorite).length;

  Map<String, dynamic> exportVault() {
    return {
      'version': 1,
      'categories': _categories,
      'entries': _entries.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, int> importVault(Map<String, dynamic> data) {
    int importedCount = 0;
    int duplicateCount = 0;

    if (data.containsKey('categories')) {
      final cats = data['categories'] as List<dynamic>?;
      if (cats != null) {
        for (final cat in cats) {
          final cName = cat.toString().trim();
          if (cName.isNotEmpty && (!_categories.contains(cName))) {
            _categories.add(cName);
          }
        }
      }
    }

    if (data.containsKey('entries')) {
      final items = data['entries'] as List<dynamic>?;
      if (items != null) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            final newEntry = PasswordEntry.fromJson(item);
            
            // Check for identical entry (same title, same website, same password)
            final isDuplicate = _entries.any((existing) {
              final sameTitle = existing.title.trim().toLowerCase() == newEntry.title.trim().toLowerCase();
              final sameWebsite = (existing.website ?? '').trim().toLowerCase() == (newEntry.website ?? '').trim().toLowerCase();
              final samePassword = existing.password == newEntry.password;
              return sameTitle && sameWebsite && samePassword;
            });

            if (isDuplicate) {
              duplicateCount++;
            } else {
              _entries.insert(0, newEntry);
              importedCount++;
            }
          }
        }
      }
    }

    if (importedCount > 0 || data.containsKey('categories')) {
      _saveCache();
      notifyListeners();
    }

    return {
      'imported': importedCount,
      'duplicates': duplicateCount,
    };
  }
}


