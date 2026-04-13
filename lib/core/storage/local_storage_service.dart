import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();
  static LocalStorageService get to => instance;

  late final GetStorage _box;

  static Future<void> initialize() async {
    await GetStorage.init();
    instance._box = GetStorage();
  }

  void write(String key, dynamic value) => _box.write(key, value);

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  bool hasData(String key) => _box.hasData(key);

  // ── Typed helpers ────────────────────────────────────────────
  bool getBool(String key, {bool defaultValue = false}) =>
      _box.read<bool>(key) ?? defaultValue;

  String getString(String key, {String defaultValue = ''}) =>
      _box.read<String>(key) ?? defaultValue;

  int getInt(String key, {int defaultValue = 0}) =>
      _box.read<int>(key) ?? defaultValue;

  void setBool(String key, bool value) => _box.write(key, value);
  void setString(String key, String value) => _box.write(key, value);
  void setInt(String key, int value) => _box.write(key, value);
}
