import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/order/presentation/view_model/order_view_model.dart';
import 'package:aqua_life/features/order/presentation/pages/order_history_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: cartState.isEmpty
          ? const Center(child: Text('Your cart is empty', style: TextStyle(color: Colors.white54)))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Shipping Address', compact),
                    SizedBox(height: compact ? 10 : 12),
                    _buildTextField(_fullNameController, 'Full Name', Icons.person_outline, compact, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    SizedBox(height: compact ? 8 : 10),
                    _buildTextField(_emailController, 'Email', Icons.email_outlined, compact, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    SizedBox(height: compact ? 8 : 10),
                    _buildTextField(_phoneController, 'Phone', Icons.phone_outlined, compact, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    SizedBox(height: compact ? 8 : 10),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_provinceController, 'Province', Icons.location_city_outlined, compact, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                        SizedBox(width: compact ? 8 : 10),
                        Expanded(child: _buildTextField(_districtController, 'District', Icons.map_outlined, compact, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                      ],
                    ),
                    SizedBox(height: compact ? 8 : 10),
                    _buildTextField(_cityController, 'City', Icons.location_on_outlined, compact, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    SizedBox(height: compact ? 8 : 10),
                    _buildTextField(_streetController, 'Street Address', Icons.home, compact, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    SizedBox(height: compact ? 8 : 10),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_postalCodeController, 'Postal Code', Icons.markunread_mailbox_outlined, compact, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                        SizedBox(width: compact ? 8 : 10),
                        Expanded(child: _buildTextField(_landmarkController, 'Landmark', Icons.place_outlined, compact)),
                      ],
                    ),
                    SizedBox(height: compact ? 14 : 18),
                    _buildSectionTitle('Order Summary', compact),
                    SizedBox(height: compact ? 10 : 12),
                    _buildSummaryRow('Subtotal', 'Rs. ${_format(cartState.subtotal)}', compact),
                    SizedBox(height: compact ? 6 : 8),
                    _buildSummaryRow('Shipping', cartState.shipping == 0 ? 'Free' : 'Rs. ${_format(cartState.shipping)}', compact),
                    SizedBox(height: compact ? 6 : 8),
                    const Divider(color: kBorder),
                    _buildSummaryRow('Total', 'Rs. ${_format(cartState.total)}', compact, emphasized: true),
                    SizedBox(height: compact ? 14 : 18),
                    SizedBox(
                      width: double.infinity,
                      height: compact ? 48 : 54,
                      child: ElevatedButton(
                        onPressed: _isPlacingOrder ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isPlacingOrder
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Place Order', style: TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, bool compact) {
    return Text(title, style: TextStyle(color: Colors.white, fontSize: compact ? 15 : 17, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool compact, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kSub, fontSize: compact ? 12 : 13),
          prefixIcon: Icon(icon, color: kSub, size: compact ? 18 : 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 10 : 12),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool compact, {bool emphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: emphasized ? Colors.white : kSub, fontSize: compact ? 13 : 14, fontWeight: emphasized ? FontWeight.bold : FontWeight.w600))),
        Text(value, maxLines: 1, style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 14, fontWeight: emphasized ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPlacingOrder = true);

    final shippingAddress = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'province': _provinceController.text.trim(),
      'district': _districtController.text.trim(),
      'city': _cityController.text.trim(),
      'street': _streetController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'landmark': _landmarkController.text.trim(),
    };

    final orderId = await ref.read(orderViewModelProvider.notifier).placeOrder(shippingAddress);
    setState(() => _isPlacingOrder = false);

    if (orderId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kCard,
          content: const Text('Order placed successfully!', style: TextStyle(color: Colors.greenAccent)),
        ),
      );
      ref.read(cartViewModelProvider.notifier).refresh();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kCard,
          content: Text(ref.read(orderViewModelProvider).error ?? 'Failed to place order', style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }
  }

  String _format(int value) {
    if (value == 0) return '0';
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)},');
  }
}
