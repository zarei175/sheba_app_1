import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class CardInputField extends StatelessWidget {
  final TextEditingController controller;

  const CardInputField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      decoration: const InputDecoration(
        hintText: '---- ---- ---- ----',
        prefixIcon: Icon(Icons.credit_card),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لطفاً شماره کارت را وارد کنید';
        }
        
        final cardNumber = value.replaceAll('-', '').trim();
        
        if (cardNumber.length != 16) {
          return 'شماره کارت باید 16 رقم باشد';
        }
        
        return null;
      },
      onChanged: (value) {
        // تبدیل اعداد انگلیسی به فارسی در نمایش
        final persianText = value.toEnglishDigit();
        if (persianText != value) {
          controller.value = controller.value.copyWith(
            text: persianText,
            selection: TextSelection.collapsed(offset: persianText.length),
          );
        }
      },
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
