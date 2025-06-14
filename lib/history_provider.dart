import 'package:flutter/material.dart';
import 'card_info.dart';
import 'history_item.dart';
import 'database_helper.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _historyItems = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;

  List<HistoryItem> get historyItems => _historyItems;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _historyItems = await _databaseHelper.getHistoryItems();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToHistory(CardInfo cardInfo) async {
    final historyItem = HistoryItem(
      cardNumber: cardInfo.cardNumber,
      sheba: cardInfo.sheba,
      ownerName: cardInfo.ownerName,
      timestamp: DateTime.now(), bankName: '',
    );

    await _databaseHelper.insertHistoryItem(historyItem);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _databaseHelper.clearHistory();
    await loadHistory();
  }

  Future<void> deleteHistoryItem(int id) async {
    await _databaseHelper.deleteHistoryItem(id);
    await loadHistory();
  }
}
