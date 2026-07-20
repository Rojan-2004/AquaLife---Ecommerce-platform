import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeRepository {
  final ApiClient _apiClient;
  HomeRepository(this._apiClient);

  Future<Map<String, dynamic>?> fetchBannerProduct() async {
    final res = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'featured': 'true', 'limit': 1},
    );
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      return products.isNotEmpty ? products.first as Map<String, dynamic> : null;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchSpotlightProducts() async {
    final res = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'featured': 'true', 'limit': 6},
    );
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['products'] as List<dynamic>? ?? []);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final res = await _apiClient.get(ApiEndpoints.categories);
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] as List<dynamic>? ?? []);
    }
    return [];
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return HomeRepository(apiClient);
});
