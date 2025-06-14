import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_item.dart';
import 'history_provider.dart';
import 'history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه استعلام‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearHistoryDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (historyProvider.historyItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تاریخچه‌ای وجود ندارد',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyProvider.historyItems.length,
            itemBuilder: (context, index) {
              final historyItem = historyProvider.historyItems[index];
              return Dismissible(
                key: Key(historyItem.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  historyProvider.deleteHistoryItem(historyItem.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('مورد از تاریخچه حذف شد'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: HistoryItemCard(historyItem: historyItem),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تاریخچه'),
        content: const Text('آیا مطمئن هستید که می‌خواهید تمام تاریخچه را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HistoryProvider>(context, listen: false).clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تاریخچه با موفقیت حذف شد'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
