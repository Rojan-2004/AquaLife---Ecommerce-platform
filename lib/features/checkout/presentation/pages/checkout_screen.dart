import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/order/presentation/pages/order_success_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  bool _isLoading = true;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _postalCodeCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCartData() async {
    try {
      // Populate user info from preferences
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        _nameCtrl.text = userData['name'] ?? userData['fullName'] ?? '';
        _emailCtrl.text = userData['email'] ?? '';
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    try {
      final res = await ApiService.post('/api/orders', {
        'shippingAddress': {
          'fullName': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'province': _provinceCtrl.text.trim(),
          'district': _districtCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'street': _streetCtrl.text.trim(),
          'postalCode': _postalCodeCtrl.text.trim(),
          'landmark': _landmarkCtrl.text.trim(),
        }
      });

      setState(() => _placing = false);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final orderId = data['orderId'] ?? data['data']?['id'] ?? data['id'] ?? 'OrderPlaced';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Order Placed Successfully!'),
            backgroundColor: const Color(0xFF112240),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId.toString())),
          );
        }
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      setState(() => _placing = false);
      if (mounted) {
        final errMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errMsg),
          backgroundColor: const Color(0xFF7f1d1d),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final subtotal = cartState.items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    final total = subtotal > 0 ? subtotal + 50 : 0.0;

    if (_isLoading || cartState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shipping Address', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField(_nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(_emailCtrl, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildField(_phoneCtrl, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField(_provinceCtrl, 'Province', Icons.map_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_districtCtrl, 'District', Icons.pin_drop_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField(_cityCtrl, 'City', Icons.location_city_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_postalCodeCtrl, 'Postal Code', Icons.local_post_office_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              _buildField(_streetCtrl, 'Street Address', Icons.home_outlined),
              const SizedBox(height: 12),
              _buildField(_landmarkCtrl, 'Landmark (Optional)', Icons.place_outlined, required: false),
              const SizedBox(height: 24),
              const Text('Order Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF112240),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E3A5C)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: Color(0xFF7AB8CC))),
                        Text('Rs. ${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee', style: TextStyle(color: Color(0xFF7AB8CC))),
                        Text('Rs. 50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Color(0xFF1E3A5C), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _placing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType, bool required = true}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5C)),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A6B82)),
          prefixIcon: Icon(icon, color: const Color(0xFF7AB8CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? '$hint is required' : null
            : null,
      ),
    );
  }
}
