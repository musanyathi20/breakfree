import 'package:flutter/material.dart';
import '../models/reason.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ReasonProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Reason> _reasons = [];

  List<Reason> get reasons => _reasons;

  // Initialize provider
  Future<void> init() async {
    await loadReasons();

    // Add default reasons if empty
    if (_reasons.isEmpty) {
      await addDefaultReasons();
    }
  }

  // Load reasons from storage
  Future<void> loadReasons() async {
    _reasons = _storage.getReasons();
    notifyListeners();
  }

  // Add default reasons
  Future<void> addDefaultReasons() async {
    for (var defaultReason in AppConstants.defaultReasons) {
      final reason = Reason(
        text: defaultReason['text']!,
        icon: defaultReason['icon']!,
        createdAt: DateTime.now(),
      );
      await _storage.addReason(reason);
    }
    await loadReasons();
  }

  // Add new reason
  Future<void> addReason(Reason reason) async {
    await _storage.addReason(reason);
    await loadReasons();
  }

  // Delete reason
  Future<void> deleteReason(String reasonId) async {
    await _storage.deleteReason(reasonId);
    await loadReasons();
  }

  // Get random reason for emergency screen
  Reason? getRandomReason() {
    if (_reasons.isEmpty) return null;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _reasons.length;
    return _reasons[randomIndex];
  }
}
