import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/order/presentation/view_model/order_view_model.dart';
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

  Future<void> _useCurrentLocation() async {
    try {
      await ref.read(orderViewModelProvider.notifier).fetchCurrentAddress();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _applyAddress(Map<String, String?> address) {
    setState(() {
      _streetCtrl.text = address['street'] ?? '';
      _cityCtrl.text = address['locality'] ?? '';
      _postalCodeCtrl.text = address['postalCode'] ?? '';
      _districtCtrl.text = address['locality'] ?? '';
      _provinceCtrl.text = address['country'] ?? '';
    });
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
            backgroundColor: Theme.of(context).colorScheme.surface,
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
    final orderState = ref.watch(orderViewModelProvider);
    final subtotal = cartState.items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    final total = subtotal > 0 ? subtotal + 50 : 0.0;
    final cs = Theme.of(context).colorScheme;

    if (orderState.address != null && orderState.address!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyAddress(orderState.address!);
      });
    }
    if (orderState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(orderState.error!),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      });
    }

    if (_isLoading || cartState.isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Checkout', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Shipping Address', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  TextButton.icon(
                    onPressed: orderState.isFetchingAddress ? null : _useCurrentLocation,
                    icon: orderState.isFetchingAddress
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: cs.primary, strokeWidth: 2))
                        : Icon(Icons.my_location, color: cs.primary, size: 20),
                    label: Text(orderState.isFetchingAddress ? 'Locating...' : 'Use my current location'),
                  ),
                ],
              ),
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
              Text('Order Summary', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72))),
                        Text('Rs. ${subtotal.toStringAsFixed(0)}', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72))),
                        Text('Rs. 50', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(color: cs.outline, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Rs. ${total.toStringAsFixed(0)}', style: TextStyle(color: cs.primary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.black,
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.48)),
          prefixIcon: Icon(icon, color: cs.onSurface.withValues(alpha: 0.72)),
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
