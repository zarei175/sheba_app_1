import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sheba_app/models/card_info.dart';
import 'package:sheba_app/api_service.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class BatchInquiryScreen extends StatefulWidget {
  const BatchInquiryScreen({super.key});

  @override
  State<BatchInquiryScreen> createState() => _BatchInquiryScreenState();
}

class _BatchInquiryScreenState extends State<BatchInquiryScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _filePath;
  String _fileName = '';
  List<String> _cardNumbers = [];
  List<CardInfo?> _results = [];
  List<String> _errors = [];
  int _processedCount = 0;
  int _totalCount = 0;
  int _successCount = 0;
  int _errorCount = 0;
  
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

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
          _successCount = 0;
          _errorCount = 0;
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
      final excel = excel_package.Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        // فرض می‌کنیم شماره کارت‌ها در ستون اول قرار دارند (از سطر دوم به بعد)
        for (var row = 1; row < sheet.maxRows; row++) {
          final cell = sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
          if (cell.value != null) {
            String cardNumber = cell.value.toString().trim();
            // حذف خط تیره‌ها و فاصله‌ها
            cardNumber = cardNumber.replaceAll('-', '').replaceAll(' ', '');
            
            if (cardNumber.isNotEmpty && cardNumber.length == 16) {
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
      _successCount = 0;
      _errorCount = 0;
      _results = List.filled(_cardNumbers.length, null);
      _errors = List.filled(_cardNumbers.length, '');
    });

    _progressAnimationController.forward();

    for (int i = 0; i < _cardNumbers.length; i++) {
      try {
        final cardInfo = await ApiService.getCardInfo(_cardNumbers[i]);
        setState(() {
          _results[i] = cardInfo;
          _processedCount++;
          _successCount++;
        });
      } catch (e) {
        setState(() {
          _errors[i] = e.toString();
          _processedCount++;
          _errorCount++;
        });
      }
      
      // Small delay to prevent overwhelming the API
      await Future.delayed(const Duration(milliseconds: 100));
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

      final excel = excel_package.Excel.createExcel();
      final sheet = excel['نتایج استعلام'];

      // Style for header
      final headerStyle = excel_package.CellStyle(
        bold: true,
        backgroundColorHex: '#4CAF50',
        fontColorHex: '#FFFFFF',
      );

      // ایجاد هدر
      final headers = ['شماره کارت', 'نام بانک', 'شماره شبا', 'نام صاحب حساب', 'وضعیت'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = headerStyle;
      }

      // پر کردن داده‌ها
      for (int i = 0; i < _cardNumbers.length; i++) {
        sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = _cardNumbers[i];
        
        if (_results[i] != null) {
          sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = _results[i]!.bankName;
          sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = _results[i]!.sheba;
          sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = _results[i]!.ownerName;
          sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = 'موفق';
        } else {
          sheet.cell(excel_package.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = 'خطا: ${_errors[i]}';
        }
      }

      // ذخیره فایل
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/نتایج_استعلام_گروهی_$timestamp.xlsx';
      final file = File(path);
      await file.writeAsBytes(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فایل با موفقیت ذخیره شد'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'مشاهده مسیر',
              textColor: Colors.white,
              onPressed: () => _showPathDialog(path),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطا در صدور فایل اکسل: $e');
    }
  }

  void _showPathDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسیر فایل'),
        content: SelectableText(path),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
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
        title: const Text('استعلام گروهی'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade600,
              Colors.green.shade50,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildFileSelectionCard(),
              if (_isProcessing || _processedCount > 0) ...[
                const SizedBox(height: 16),
                _buildProgressCard(),
              ],
              if (_results.isNotEmpty && !_isProcessing) ...[
                const SizedBox(height: 16),
                _buildResultsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard() {
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
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'فایل اکسل حاوی شماره کارت‌ها',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'فایل اکسل باید شامل شماره کارت‌ها در ستون اول باشد.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading || _isProcessing ? null : _pickExcelFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('انتخاب فایل اکسل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_filePath != null && !_isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: excel_package.Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'فایل انتخاب شده: $_fileName',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تعداد شماره کارت‌ها: ${_cardNumbers.length.toString().toPersianDigit()}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _processCardNumbers,
                        icon: const Icon(Icons.search),
                        label: const Text('شروع استعلام گروهی'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
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
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('کل', _totalCount, Colors.blue),
                  _buildStatCard('موفق', _successCount, Colors.green),
                  _buildStatCard('خطا', _errorCount, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'پیشرفت: ${_processedCount.toString().toPersianDigit()} از ${_totalCount.toString().toPersianDigit()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _totalCount > 0 ? (_processedCount / _totalCount) * _progressAnimation.value : 0,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  );
                },
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
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString().toPersianDigit(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Expanded(
      child: Card(
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
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'نتایج استعلام',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final cardNumber = _cardNumbers[index];
                      final result = _results[index];
                      final error = _errors[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: result != null ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: result != null ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: result != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'شماره کارت: ${cardNumber.toPersianDigit()}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                                    Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.red.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'شماره کارت: ${cardNumber.toPersianDigit()}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'خطا: $error',
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
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
    );
  }
}

