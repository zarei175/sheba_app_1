import 'package:flutter/foundation.dart';
import 'package:sheba_app/models/card_info.dart';
import 'package:sheba_app/models/history_item.dart';
import 'package:sheba_app/database_helper.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryItem> _history = [];
  List<HistoryItem> get history => _history;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _history = await DatabaseHelper.instance.getHistoryItems();
    notifyListeners();
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    await DatabaseHelper.instance.insertHistoryItem(item);
    _history.add(item);
    notifyListeners();
  }

  Future<void> deleteHistoryItem(int id) async {
    await DatabaseHelper.instance.deleteHistoryItem(id);
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await DatabaseHelper.instance.clearHistory();
    _history = [];
    notifyListeners();
  }


}

