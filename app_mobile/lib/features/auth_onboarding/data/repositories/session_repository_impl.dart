import '../../domain/repositories/session_repository.dart';
import '../datasources/secure_session_datasource.dart';

class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl(this._dataSource);

  final SecureSessionDataSource _dataSource;

  @override
  Future<bool> isRememberMeEnabled() => _dataSource.getRememberMe();

  @override
  Future<void> setRememberMeEnabled(bool value) => _dataSource.setRememberMe(value);

  @override
  Future<bool> isBiometricEnabled() => _dataSource.getBiometricEnabled();

  @override
  Future<void> setBiometricEnabled(bool value) => _dataSource.setBiometricEnabled(value);
}
