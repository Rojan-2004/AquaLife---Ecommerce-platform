import 'dart:convert';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeRepository {
  Future<Map<String, dynamic>?> fetchBannerProduct() async {
    try {
      final res = await ApiService.get('/api/products?featured=true&limit=1');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final products = data['products'] as List<dynamic>? ?? [];
        return products.isNotEmpty ? products.first as Map<String, dynamic> : null;
      }
    } catch (_) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchSpotlightProducts() async {
    try {
      final res = await ApiService.get('/api/products?featured=true&limit=6');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['products'] as List<dynamic>? ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final res = await ApiService.get('/api/categories');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['categories'] ?? data;
        if (list is List) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (_) {}
    return [];
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});
