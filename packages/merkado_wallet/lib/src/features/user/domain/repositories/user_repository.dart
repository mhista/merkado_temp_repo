import '../models/wallet_user.dart';

/// UserRepository
/// ==============
/// The wallet package does NOT fetch the user itself.
/// The consuming app owns auth — it passes the already-fetched user
/// into the wallet via [MerkadoWalletScope.of(context).setUser(user)].
///
/// This interface exists purely for internal state management,
/// not for network access.
abstract interface class UserRepository {
  WalletUser? get currentUser;
  void setUser(WalletUser user);
  void clearUser();
}