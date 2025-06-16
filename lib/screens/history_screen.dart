import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheba_app/providers/history_provider.dart';
import 'package:sheba_app/widgets/history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه استعلام‌ها'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف تاریخچه'),
                  content: const Text('آیا از حذف کامل تاریخچه اطمینان دارید؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('خیر'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<HistoryProvider>(context, listen: false).clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('بله'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تاریخچه‌ای وجود ندارد.',
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
            padding: const EdgeInsets.all(8.0),
            itemCount: historyProvider.history.length,
            itemBuilder: (context, index) {
              final item = historyProvider.history[index];
              return HistoryItemCard(
                item: item,
                onDelete: () {
                  historyProvider.deleteHistoryItem(item.id!);
                },
              );
            },
          );
        },
      ),
    );
  }
}


