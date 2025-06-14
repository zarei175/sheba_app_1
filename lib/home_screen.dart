import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'batch_inquiry_screen.dart';
import 'card_info.dart';
import 'card_input_field.dart';
import 'history_provider.dart';
import 'history_screen.dart';
import 'result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعلام شماره شبا'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'استعلام گروهی',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BatchInquiryScreen()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'شماره کارت بانکی خود را وارد کنید',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CardInputField(controller: _cardController),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _getCardInfo,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('استعلام'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BatchInquiryScreen()),
                              );
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('استعلام گروهی با فایل اکسل'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'خطا در دریافت اطلاعات',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _clearResult,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade800,
                              side: BorderSide(color: Colors.red.shade800),
                            ),
                            child: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_cardInfo != null)
                  ResultCard(
                    cardInfo: _cardInfo!,
                    onClear: _clearResult,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  final TextEditingController _cardController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CardInfo? _cardInfo;
  String? _errorMessage;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _getCardInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cardNumber = _cardController.text.replaceAll('-', '').trim();
      final cardInfo = await ApiService.getCardInfo(cardNumber);
      
      setState(() {
        _cardInfo = cardInfo;
        _isLoading = false;
      });

      // Add to history
      if (!mounted) return;
      await Provider.of<HistoryProvider>(context, listen: false).addToHistory(cardInfo);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _clearResult() {
    setState(() {
      _cardInfo = null;
      _errorMessage = null;
    });
  }
}
