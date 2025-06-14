import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppConstants {
  // API Constants
  static const String baseUrl = 'https://khanesarmaye.com/api';
  static const String cardToShebaEndpoint = '/sheba/get/card-to-sheba/';
  
  // Auth Token - به‌روزرسانی شده مطابق با کد پایتون
  static const String authToken = '32838|ctzcZA81ndPb5XjEl6UKl9auu62Z7BQKa0h5UV1c4e9e6747';
  
  // Database Constants
  static const String databaseName = 'sheba_app.db';
  static const String historyTable = 'history';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  
  // Validation Constants
  static const int cardNumberLength = 16;
  
  // Error Messages
  static const String networkErrorMessage = 'خطا در ارتباط با سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
  static const String invalidCardNumberMessage = 'شماره کارت نامعتبر است. لطفاً یک شماره کارت 16 رقمی معتبر وارد کنید.';
  static const String serverErrorMessage = 'خطا در سرور. لطفاً بعداً دوباره تلاش کنید.';
  
  // Success Messages
  static const String copiedToClipboardMessage = 'با موفقیت کپی شد';
}
