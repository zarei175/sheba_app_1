import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'card_info.dart';
import 'api_service.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class BatchInquiryScreen extends StatefulWidget {
  const BatchInquiryScreen({super.key});

  @override
  State<BatchInquiryScreen> createState() => _BatchInquiryScreenState();
}

class _BatchInquiryScreenState extends State<BatchInquiryScreen> {
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _filePath;
  String _fileName = '';
  List<String> _cardNumbers = [];
  List<CardInfo?> _results = [];
  List<String> _errors = [];
  int _processedCount = 0;
  int _totalCount = 0;

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _filePath = result.files.single.path;
          _fileName = result.files.single.name;
          _cardNumbers = [];
          _results = [];
          _errors = [];
          _processedCount = 0;
          _totalCount = 0;
        });

        await _readExcelFile();

        setState(() {
          _isLoading = false;
          _totalCount = _cardNumbers.length;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('خطا در انتخاب فایل: $e');
    }
  }

  Future<void> _readExcelFile() async {
    try {
      if (_filePath == null) return;

      final bytes = File(_filePath!).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        // فرض می‌کنیم شماره کارت‌ها در ستون اول قرار دارند (از سطر دوم به بعد)
        for (var row = 1; row < sheet.maxRows; row++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
          if (cell.value != null) {
            String cardNumber = cell.value.toString().trim();
            // حذف خط تیره‌ها و فاصله‌ها
            cardNumber = cardNumber.replaceAll('-', '').replaceAll(' ', '');
            
            if (cardNumber.isNotEmpty) {
              _cardNumbers.add(cardNumber);
            }
          }
        }
      }
    } catch (e) {
      _showErrorDialog('خطا در خواندن فایل اکسل: $e');
    }
  }

  Future<void> _processCardNumbers() async {
    if (_cardNumbers.isEmpty) {
      _showErrorDialog('هیچ شماره کارتی برای پردازش یافت نشد.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processedCount = 0;
      _results = List.filled(_cardNumbers.length, null);
      _errors = List.filled(_cardNumbers.length, '');
    });

    for (int i = 0; i < _cardNumbers.length; i++) {
      try {
        final cardInfo = await ApiService.getCardInfo(_cardNumbers[i]);
        setState(() {
          _results[i] = cardInfo;
          _processedCount++;
        });
      } catch (e) {
        setState(() {
          _errors[i] = e.toString();
          _processedCount++;
        });
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _exportToExcel() async {
    try {
      if (_results.isEmpty) {
        _showErrorDialog('هیچ نتیجه‌ای برای صدور وجود ندارد.');
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel['نتایج استعلام'];

      // ایجاد هدر
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'شماره کارت' as CellValue?;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'نام بانک' as CellValue?;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'شماره شبا' as CellValue?;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'نام صاحب حساب' as CellValue?;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'وضعیت' as CellValue?;

      // پر کردن داده‌ها
      for (int i = 0; i < _cardNumbers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = _cardNumbers[i] as CellValue?;
        
        if (_results[i] != null) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = _results[i]!.bankName as CellValue?;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = _results[i]!.sheba as CellValue?;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = _results[i]!.ownerName as CellValue?;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = 'موفق' as CellValue?;
        } else {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = 'خطا: ${_errors[i]}' as CellValue?;
        }
      }

      // ذخیره فایل
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/نتایج_استعلام_گروهی.xlsx';
      final file = File(path);
      await file.writeAsBytes(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فایل با موفقیت در مسیر زیر ذخیره شد:\n$path'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      _showErrorDialog('خطا در صدور فایل اکسل: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطا'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعلام گروهی شماره شبا'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'فایل اکسل حاوی شماره کارت‌ها را انتخاب کنید',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'فایل اکسل باید شامل شماره کارت‌ها در ستون اول باشد.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading || _isProcessing ? null : _pickExcelFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('انتخاب فایل اکسل'),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_filePath != null && !_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فایل انتخاب شده: $_fileName',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعداد شماره کارت‌ها: ${_cardNumbers.length.toString().toPersianDigit()}',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _processCardNumbers,
                              icon: const Icon(Icons.search),
                              label: const Text('شروع استعلام گروهی'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isProcessing || _processedCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'پیشرفت: ${_processedCount.toString().toPersianDigit()} از ${_totalCount.toString().toPersianDigit()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _totalCount > 0 ? _processedCount / _totalCount : 0,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        if (_isProcessing)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!_isProcessing && _processedCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              onPressed: _exportToExcel,
                              icon: const Icon(Icons.download),
                              label: const Text('دانلود نتایج (اکسل)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_results.isNotEmpty && !_isProcessing)
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'نتایج استعلام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final cardNumber = _cardNumbers[index];
                              final result = _results[index];
                              final error = _errors[index];
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: result != null ? Colors.green.shade50 : Colors.red.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: result != null
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'شماره کارت: ${cardNumber.toPersianDigit()}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('نام بانک: ${result.bankName}'),
                                            const SizedBox(height: 4),
                                            Text('شماره شبا: ${result.sheba.toPersianDigit()}'),
                                            const SizedBox(height: 4),
                                            Text('نام صاحب حساب: ${result.ownerName}'),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'شماره کارت: ${cardNumber.toPersianDigit()}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('خطا: $error', style: const TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
