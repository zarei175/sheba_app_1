import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:zstandard/zstandard.dart';
import 'package:sheba_app/models/card_info.dart';
import 'package:sheba_app/services/token_manager.dart'; // Import TokenManager

class ApiService {
  static const String baseUrl = 'https://khanesarmaye.com/api';
  static const String cardToShebaEndpoint = '/sheba/get/card-to-sheba/';
  static const String cardToAccountEndpoint = '/sheba/get/card-to-account/'; // New endpoint
  static const String accountToShebaEndpoint = '/sheba/get/account-to-sheba/'; // New endpoint
  static const String shebaInfoEndpoint = '/sheba/get/sheba-info/'; // New endpoint

  // هدرهای مورد نیاز برای درخواست - به‌روزرسانی شده مطابق با کد پایتون
  static Future<Map<String, String>> getHeaders() async {
    final token = await TokenManager().getApiToken(); // Fetch token dynamically
    return {
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'en-US,en;q=0.9,fa;q=0.8',
      'Content-Type': 'application/json',
      'Origin': 'https://khanesarmaye.com',
      'Referer': 'https://khanesarmaye.com/sheba/result/',
      'Sec-Ch-Ua': '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"',
      'Sec-Ch-Ua-Mobile': '?0',
      'Sec-Ch-Ua-Platform': '"Windows"',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',
      'Authorization': 'Bearer $token', // Use fetched token
    };
  }

  // کوکی‌های مورد نیاز - به‌روزرسانی شده مطابق با کد پایتون
  static Map<String, String> getCookies() {
    // Note: user_auth_token in cookies might also need to be dynamic if it's tied to the API token
    // For now, keeping it as is, but it's a potential area for improvement.
    return {
      '_gcl_au': '1.1.1338617498.1747861749',
      'analytics_campaign': '{%22source%22:%22google%22%2C%22medium%22:%22organic%22}',
      'analytics_token': '35583e04-bf92-6dbd-1936-a83714b6b05a',
      'analytics_session_token': '0bb5269d-3205-f16c-a7c5-eb09c077bd8a',
      'yektanet_session_last_activity': '5/22/2025',
      '_yngt_iframe': '1',
      '_yngt': '4629f41c-ba91-4a6c-a96b-d19098843c15',
      'user_auth_token': 'YOUR_DYNAMIC_AUTH_TOKEN_HERE', // This should also be dynamic if it's the same as API token
      '_gid': 'GA1.2.1986953517.1747861892',
      '_ga': 'GA1.2.1731811901.1747861749',
      '_gat_UA-106223998-1': '1',
      '_ga_RKW9YD95V1': r"'GS2.1.s1747861748$o1$g1$t1747862611$j20$l0$h1151592747$dDYOrPDAuxt1xun7A6qP_ieRhBpLFd43NyQ'",
    };
  }

  // تبدیل کوکی‌ها به رشته
  static String _cookiesToString(Map<String, String> cookies) {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  // رمزگشایی پاسخ با استفاده از کتابخانه zstandard
  static Future<dynamic> decodeResponse(http.Response response) async {
    try {
      // ابتدا تلاش برای تفسیر مستقیم به عنوان JSON
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // اگر JSON نبود، ادامه می‌دهیم
      }
      
      // بررسی هدر Content-Encoding
      String? contentEncoding = response.headers['content-encoding']?.toLowerCase();
      
      // ایجاد نمونه از کتابخانه zstandard
      final zstandard = Zstandard();
      
      // رمزگشایی بر اساس نوع فشرده‌سازی
      if (contentEncoding != null) {
        if (contentEncoding.contains('zstd')) {
          // رمزگشایی zstd با استفاده از کتابخانه zstandard
          final Uint8List bytes = Uint8List.fromList(response.bodyBytes);
          final Uint8List? decompressed = await zstandard.decompress(bytes);
          
          if (decompressed != null) {
            final content = utf8.decode(decompressed);
            return jsonDecode(content);
          }
        } else if (contentEncoding.contains('gzip')) {
          // رمزگشایی gzip با استفاده از کتابخانه archive
          try {
            final bytes = response.bodyBytes;
            final decompressed = gzip.decode(bytes);
            final content = utf8.decode(decompressed);
            return jsonDecode(content);
          } catch (e) {
            // اگر خطا داشت، ادامه می‌دهیم
          }
        }
      }
      
      // تلاش نهایی برای تفسیر محتوا به عنوان متن و سپس JSON
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('خطا در رمزگشایی پاسخ: $e');
      }
    } catch (e) {
      throw Exception('خطا در پردازش پاسخ: $e');
    }
  }

  // استعلام شماره شبا با شماره کارت
  static Future<CardInfo> getCardInfo(String cardNumber) async {
    final url = Uri.parse('$baseUrl$cardToShebaEndpoint');
    final headers = await getHeaders(); // Await the async getHeaders()
    
    // اضافه کردن کوکی‌ها به هدرها
    headers['Cookie'] = _cookiesToString(getCookies());
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'cardNumber': cardNumber}),
      );

      if (response.statusCode == 200) {
        final jsonData = await decodeResponse(response);
        return CardInfo(
          cardNumber: cardNumber,
          sheba: jsonData['iban'] ?? '',
          ownerName: jsonData['owner'] ?? '',
          bankName: jsonData['bank'] ?? '',
        );
      } else {
        throw Exception('خطا در دریافت اطلاعات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }

  // استعلام شماره حساب بر اساس شماره کارت
  static Future<CardInfo> getAccountInfoFromCard(String cardNumber) async {
    final url = Uri.parse('$baseUrl$cardToAccountEndpoint');
    final headers = await getHeaders();
    headers['Cookie'] = _cookiesToString(getCookies());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'cardNumber': cardNumber}),
      );

      if (response.statusCode == 200) {
        final jsonData = await decodeResponse(response);
        return CardInfo(
          cardNumber: cardNumber,
          sheba: jsonData['iban'] ?? '', // Assuming API returns IBAN even for account inquiry
          ownerName: jsonData['owner'] ?? '',
          bankName: jsonData['bank'] ?? '',
          accountNumber: jsonData['accountNumber'] ?? '', // Assuming API returns accountNumber
        );
      } else {
        throw Exception('خطا در دریافت اطلاعات حساب از کارت: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور برای استعلام حساب از کارت: $e');
    }
  }

  // استعلام شماره شبا بر اساس شماره حساب
  static Future<CardInfo> getShebaInfoFromAccount(String accountNumber) async {
    final url = Uri.parse('$baseUrl$accountToShebaEndpoint');
    final headers = await getHeaders();
    headers['Cookie'] = _cookiesToString(getCookies());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'accountNumber': accountNumber}),
      );

      if (response.statusCode == 200) {
        final jsonData = await decodeResponse(response);
        return CardInfo(
          cardNumber: jsonData['cardNumber'] ?? '', // Assuming API returns cardNumber
          sheba: jsonData['iban'] ?? '',
          ownerName: jsonData['owner'] ?? '',
          bankName: jsonData['bank'] ?? '',
          accountNumber: accountNumber,
        );
      } else {
        throw Exception('خطا در دریافت اطلاعات شبا از حساب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور برای استعلام شبا از حساب: $e');
    }
  }

  // استعلام اطلاعات شبا (بر اساس خود شبا)
  static Future<CardInfo> getShebaInfo(String shebaNumber) async {
    final url = Uri.parse('$baseUrl$shebaInfoEndpoint');
    final headers = await getHeaders();
    headers['Cookie'] = _cookiesToString(getCookies());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'shebaNumber': shebaNumber}),
      );

      if (response.statusCode == 200) {
        final jsonData = await decodeResponse(response);
        return CardInfo(
          cardNumber: jsonData['cardNumber'] ?? '', // Assuming API returns cardNumber
          sheba: shebaNumber,
          ownerName: jsonData['owner'] ?? '',
          bankName: jsonData['bank'] ?? '',
          accountNumber: jsonData['accountNumber'] ?? '', // Assuming API returns accountNumber
        );
      } else {
        throw Exception('خطا در دریافت اطلاعات شبا: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور برای استعلام اطلاعات شبا: $e');
    }
  }
}


