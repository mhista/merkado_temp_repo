import '../../../../core/logging/wallet_logger.dart';
import '../../domain/models/wallet_user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  WalletUser? _user;

  @override
  WalletUser? get currentUser => _user;

  @override
  void setUser(WalletUser user) {
    _user = user;
    WalletLogger.i.info('user set: ${user.fullName} [${user.id}]');
  }

  @override
  void clearUser() {
    _user = null;
    WalletLogger.i.info('user cleared');
  }
}