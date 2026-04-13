import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../data/profile_data_source.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final ProfileDataSource _dataSource;
  final SecureStorageService _secureStorage;

  ProfileRepository({
    ProfileDataSource? dataSource,
    SecureStorageService? secureStorage,
  }) : _dataSource = dataSource ?? ProfileDataSource(),
       _secureStorage = secureStorage ?? SecureStorageService.to;

  Future<ProfileResponse> fetchProfile() async {
    final userId = await _secureStorage.read(StorageKeys.userId) ?? '';
    return _dataSource.fetchProfile(userId);
  }

  Future<LogoutResponse> logout() async {
    final userId = await _secureStorage.read(StorageKeys.userId) ?? '';
    final response = await _dataSource.logout(userId);
    if (response.isSuccess) {
      await _clearSession();
    }
    return response;
  }

  /// Returns the stored user_id for display / requests
  Future<String> getUserId() async {
    return await _secureStorage.read(StorageKeys.userId) ?? '';
  }

  Future<void> _clearSession() async {
    await Future.wait([
      _secureStorage.delete(StorageKeys.authToken),
      _secureStorage.delete(StorageKeys.refreshToken),
      _secureStorage.delete(StorageKeys.userId),
      _secureStorage.delete(StorageKeys.userType),
      _secureStorage.delete(StorageKeys.profileCompleted),
    ]);
    LocalStorageService.to.setBool('is_logged_in', false);
  }
}
