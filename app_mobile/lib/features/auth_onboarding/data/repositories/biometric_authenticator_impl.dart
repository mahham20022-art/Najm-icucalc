import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/biometric_authenticator.dart';
import '../datasources/biometric_datasource.dart';

class BiometricAuthenticatorImpl implements BiometricAuthenticator {
  const BiometricAuthenticatorImpl(this._dataSource);

  final BiometricDataSource _dataSource;

  @override
  Future<bool> isAvailable() => _dataSource.isAvailable();

  @override
  Future<Result<void>> authenticate() async {
    try {
      final success = await _dataSource.authenticate();
      if (success) return const Result.success(null);
      return const Result.failure(BiometricFailure());
    } catch (_) {
      return const Result.failure(BiometricFailure());
    }
  }
}
