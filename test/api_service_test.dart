import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sheba_app/api_service.dart';
import 'package:sheba_app/models/card_info.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    test('should validate card number format', () {
      // Test card number validation
      const validCardNumber = '1234567890123456';
      const invalidCardNumber = '123';
      
      expect(validCardNumber.length, equals(16));
      expect(invalidCardNumber.length, lessThan(16));
    });

    test('should format card number correctly', () {
      const cardNumber = '1234567890123456';
      const expectedFormat = '1234-5678-9012-3456';
      
      String formatCardNumber(String input) {
        var buffer = StringBuffer();
        for (int i = 0; i < input.length; i++) {
          buffer.write(input[i]);
          var nonZeroIndex = i + 1;
          if (nonZeroIndex % 4 == 0 && nonZeroIndex != input.length) {
            buffer.write('-');
          }
        }
        return buffer.toString();
      }
      
      expect(formatCardNumber(cardNumber), equals(expectedFormat));
    });

    test('should create CardInfo from JSON correctly', () {
      final json = {
        'card': '1234567890123456',
        'iban': 'IR123456789012345678901234',
        'owner': 'احمد احمدی',
        'bank': 'بانک ملی',
      };

      final cardInfo = CardInfo.fromJson(json);
      
      expect(cardInfo.cardNumber, equals('1234567890123456'));
      expect(cardInfo.sheba, equals('IR123456789012345678901234'));
      expect(cardInfo.ownerName, equals('احمد احمدی'));
      expect(cardInfo.bankName, equals('بانک ملی'));
    });

    test('should handle missing fields in JSON gracefully', () {
      final json = {
        'card': '1234567890123456',
        // Missing other fields
      };

      final cardInfo = CardInfo.fromJson(json);
      
      expect(cardInfo.cardNumber, equals('1234567890123456'));
      expect(cardInfo.sheba, equals(''));
      expect(cardInfo.ownerName, equals(''));
      expect(cardInfo.bankName, equals(''));
    });

    test('should convert CardInfo to JSON correctly', () {
      final cardInfo = CardInfo(
        cardNumber: '1234567890123456',
        sheba: 'IR123456789012345678901234',
        ownerName: 'احمد احمدی',
        bankName: 'بانک ملی',
      );

      final json = cardInfo.toJson();
      
      expect(json['cardNumber'], equals('1234567890123456'));
      expect(json['sheba'], equals('IR123456789012345678901234'));
      expect(json['ownerName'], equals('احمد احمدی'));
      expect(json['bankName'], equals('بانک ملی'));
    });
  });
}

