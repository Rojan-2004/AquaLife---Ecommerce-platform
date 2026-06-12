import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';

abstract class StorageService {
  Future<void> setFirstTime(bool value);
  Future<bool> getFirstTime();
}

class UserSharedPrefs implements StorageService {
  final SharedPreferences _prefs;
  static const String _keyFirstTime = 'is_first_time';

  UserSharedPrefs({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<void> setFirstTime(bool value) async {
    await _prefs.setBool(_keyFirstTime, value);
  }

  @override
  Future<bool> getFirstTime() async {
    return _prefs.getBool(_keyFirstTime) ?? true;
  }
}

final userSharedPrefsProvider = Provider<UserSharedPrefs>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSharedPrefs(prefs: prefs);
});
