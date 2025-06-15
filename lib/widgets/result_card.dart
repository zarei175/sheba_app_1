import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sheba_app/models/card_info.dart';

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
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'اطلاعات حساب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Card Number
              if (cardInfo.cardNumber.isNotEmpty)
                _buildInfoCard(
                  context,
                  'شماره کارت',
                  cardInfo.cardNumber.toPersianDigit().toString(),
                  Icons.credit_card,
                  Colors.blue,
                ),
              
              // Account Number
              if (cardInfo.accountNumber != null && cardInfo.accountNumber!.isNotEmpty)
                _buildInfoCard(
                  context,
                  'شماره حساب',
                  cardInfo.accountNumber!.toPersianDigit().toString(),
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              
              // SHEBA Number
              if (cardInfo.sheba.isNotEmpty)
                _buildInfoCard(
                  context,
                  'شماره شبا',
                  cardInfo.sheba.toPersianDigit().toString(),
                  Icons.account_balance,
                  Colors.green,
                  canCopy: true,
                  copyValue: cardInfo.sheba,
                ),
              
              // Bank Name
              if (cardInfo.bankName.isNotEmpty)
                _buildInfoCard(
                  context,
                  'نام بانک',
                  cardInfo.bankName,
                  Icons.business,
                  Colors.purple,
                ),
              
              // Owner Name
              if (cardInfo.ownerName.isNotEmpty)
                _buildInfoCard(
                  context,
                  'نام صاحب حساب',
                  cardInfo.ownerName,
                  Icons.person,
                  Colors.teal,
                ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.refresh),
                      label: const Text('استعلام جدید'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _shareResult(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.share),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool canCopy = false,
    String? copyValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy && copyValue != null)
            IconButton(
              icon: Icon(Icons.copy, size: 20, color: color),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('کپی شد'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              tooltip: 'کپی',
            ),
        ],
      ),
    );
  }

  void _shareResult(BuildContext context) {
    final StringBuffer shareText = StringBuffer();
    shareText.writeln('اطلاعات حساب بانکی:');
    shareText.writeln('');
    
    if (cardInfo.cardNumber.isNotEmpty) {
      shareText.writeln('شماره کارت: ${cardInfo.cardNumber}');
    }
    
    if (cardInfo.accountNumber != null && cardInfo.accountNumber!.isNotEmpty) {
      shareText.writeln('شماره حساب: ${cardInfo.accountNumber}');
    }
    
    if (cardInfo.sheba.isNotEmpty) {
      shareText.writeln('شماره شبا: ${cardInfo.sheba}');
    }
    
    if (cardInfo.bankName.isNotEmpty) {
      shareText.writeln('نام بانک: ${cardInfo.bankName}');
    }
    
    if (cardInfo.ownerName.isNotEmpty) {
      shareText.writeln('نام صاحب حساب: ${cardInfo.ownerName}');
    }

    // Share functionality would be implemented here
    // For now, we'll copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اطلاعات کپی شد'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

