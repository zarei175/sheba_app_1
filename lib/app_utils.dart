import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  // تبدیل شماره کارت به فرمت نمایشی (با خط تیره)
  static String formatCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll('-', '').replaceAll(' ', '');
    if (cardNumber.length != 16) return cardNumber;
    
    return '${cardNumber.substring(0, 4)}-${cardNumber.substring(4, 8)}-${cardNumber.substring(8, 12)}-${cardNumber.substring(12, 16)}';
  }
  
  // نمایش دیالوگ خطا
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطا'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }
  
  // نمایش اسنک‌بار
  static void showSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
  
  // تنظیم جهت متن بر اساس محتوا
  static TextDirection getTextDirection(String text) {
    final RegExp rtlChars = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    if (rtlChars.hasMatch(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
