import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheba_app/api_service.dart';
import 'package:sheba_app/models/card_info.dart';
import 'package:sheba_app/providers/history_provider.dart';
import 'package:sheba_app/screens/batch_inquiry_screen.dart';
import 'package:sheba_app/screens/history_screen.dart';
import 'package:sheba_app/widgets/card_input_field.dart';
import 'package:sheba_app/widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _shebaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  CardInfo? _cardInfo;
  String? _errorMessage;
  
  // Tab controller for different inquiry types
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _accountController.dispose();
    _shebaController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعلام اطلاعات بانکی'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.credit_card),
              text: 'کارت به شبا',
            ),
            Tab(
              icon: Icon(Icons.account_balance),
              text: 'حساب به شبا',
            ),
            Tab(
              icon: Icon(Icons.info),
              text: 'اطلاعات شبا',
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCardToShebaTab(),
              _buildAccountToShebaTab(),
              _buildShebaInfoTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardToShebaTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildInquiryCard(
              title: 'استعلام شبا با شماره کارت',
              description: 'شماره کارت بانکی خود را وارد کنید',
              controller: _cardController,
              inputType: InquiryType.card,
              onSubmit: _getCardToShebaInfo,
            ),
            const SizedBox(height: 20),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountToShebaTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildInquiryCard(
              title: 'استعلام شبا با شماره حساب',
              description: 'شماره حساب بانکی خود را وارد کنید',
              controller: _accountController,
              inputType: InquiryType.account,
              onSubmit: _getAccountToShebaInfo,
            ),
            const SizedBox(height: 20),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShebaInfoTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildInquiryCard(
              title: 'استعلام اطلاعات شبا',
              description: 'شماره شبا را وارد کنید',
              controller: _shebaController,
              inputType: InquiryType.sheba,
              onSubmit: _getShebaInfo,
            ),
            const SizedBox(height: 20),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiryCard({
    required String title,
    required String description,
    required TextEditingController controller,
    required InquiryType inputType,
    required VoidCallback onSubmit,
  }) {
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _getIconForType(inputType),
                  size: 48,
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildInputField(controller, inputType),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'استعلام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BatchInquiryScreen()),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('استعلام گروهی با فایل اکسل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                    side: BorderSide(color: Colors.green.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, InquiryType type) {
    switch (type) {
      case InquiryType.card:
        return CardInputField(controller: controller);
      case InquiryType.account:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'شماره حساب',
            hintText: 'مثال: 123456789',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفاً شماره حساب را وارد کنید';
            }
            if (value.length < 8) {
              return 'شماره حساب باید حداقل ۸ رقم باشد';
            }
            return null;
          },
        );
      case InquiryType.sheba:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'شماره شبا',
            hintText: 'مثال: IR123456789012345678901234',
            prefixIcon: const Icon(Icons.info),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفاً شماره شبا را وارد کنید';
            }
            if (!value.startsWith('IR') || value.length != 26) {
              return 'شماره شبا باید با IR شروع شده و ۲۶ کاراکتر باشد';
            }
            return null;
          },
        );
    }
  }

  Widget _buildResultSection() {
    if (_errorMessage != null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade50,
                Colors.red.shade100,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'خطا در دریافت اطلاعات',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_cardInfo != null) {
      return ResultCard(
        cardInfo: _cardInfo!,
        onClear: _clearResult,
      );
    }

    return const SizedBox.shrink();
  }

  IconData _getIconForType(InquiryType type) {
    switch (type) {
      case InquiryType.card:
        return Icons.credit_card;
      case InquiryType.account:
        return Icons.account_balance;
      case InquiryType.sheba:
        return Icons.info;
    }
  }

  Future<void> _getCardToShebaInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cardInfo = null;
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

  Future<void> _getAccountToShebaInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cardInfo = null;
    });

    try {
      final accountNumber = _accountController.text.trim();
      final cardInfo = await ApiService.getShebaInfoFromAccount(accountNumber);
      
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

  Future<void> _getShebaInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cardInfo = null;
    });

    try {
      final shebaNumber = _shebaController.text.trim();
      final cardInfo = await ApiService.getShebaInfo(shebaNumber);
      
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

enum InquiryType {
  card,
  account,
  sheba,
}

