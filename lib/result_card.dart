import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'card_info.dart';

class ResultCard extends StatelessWidget {
  final CardInfo cardInfo;
  final VoidCallback onClear;

  const ResultCard({
    super.key,
    required this.cardInfo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                SizedBox(width: 8),
                Text(
                  'اطلاعات حساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              'شماره کارت:',
              cardInfo.cardNumber.toPersianDigit().toString(),
              Icons.credit_card,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              'شماره شبا:',
              cardInfo.sheba.toPersianDigit().toString(),
              Icons.account_balance,
              canCopy: true,
              copyValue: cardInfo.sheba,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              'نام صاحب حساب:',
              cardInfo.ownerName,
              Icons.person,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade800,
                side: BorderSide(color: Colors.green.shade800),
              ),
              child: const Text('استعلام جدید'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool canCopy = false,
    String? copyValue,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green.shade800,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        if (canCopy && copyValue != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: copyValue));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('کپی شد'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'کپی',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
