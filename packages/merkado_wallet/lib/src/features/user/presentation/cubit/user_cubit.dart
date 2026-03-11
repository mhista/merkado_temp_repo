import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/wallet_user.dart';
import '../../data/repository/user_repository_impl.dart';
import '../../../../core/logging/wallet_logger.dart';

part 'user_state.dart';
part 'user_cubit.freezed.dart';

/// UserCubit
/// =========
/// Holds the [WalletUser] profile passed in from the consuming app.
///
/// The package NEVER fetches the user from the network.
/// The app owns auth and calls [setUser] after a successful login.
///
/// FULL FLOW:
/// ```dart
/// // 1. App authenticates via merkado_auth
/// MerkadoAuth.instance.authStream.listen((result) {
///   if (result is AuthSuccess) {
///     // 2. App maps its auth user to WalletUser
///     final walletUser = WalletUser(
///       id:        result.user.id,
///       firstName: result.user.firstName,
///       lastName:  result.user.lastName,
///       email:     result.user.email,
///       avatarUrl: result.user.avatarUrl,
///       phone:     result.user.phone,
///       emailVerified: result.user.emailVerified,
///       phoneVerified: result.user.phoneVerified,
///       country:   result.user.country,
///     );
///     // 3. Pass token AND user to the wallet scope
///     MerkadoWalletScope.of(context).setAccessToken(result.accessToken);
///     MerkadoWalletScope.of(context).setUser(walletUser);
///   }
///   if (result is AuthLoggedOut) {
///     MerkadoWalletScope.of(context).clearSession();
///   }
/// });
/// ```
///
/// Or use the convenience method that does both at once:
/// ```dart
/// MerkadoWalletScope.of(context).setSession(
///   token: result.accessToken,
///   user:  walletUser,
/// );
/// ```
class UserCubit extends Cubit<UserState> {
  final UserRepositoryImpl _repository = UserRepositoryImpl();

  UserCubit() : super(const UserState.empty());

  /// The currently loaded user, or null.
  WalletUser? get currentUser => _repository.currentUser;

  /// Set the user profile from the consuming app's auth response.
  void setUser(WalletUser user) {
    _repository.setUser(user);
    WalletLogger.i.state('UserCubit', 'loaded', data: {
      'name':    user.fullName,
      'country': user.country,
    });
    _emitSafe(UserState.loaded(user: user));
  }

  /// Clear user profile on logout.
  void clearUser() {
    _repository.clearUser();
    WalletLogger.i.state('UserCubit', 'empty');
    _emitSafe(const UserState.empty());
  }

  /// Preview mode injection — same as setUser but skips logging noise.
  void injectPreview(WalletUser user) {
    if (!isClosed) emit(UserState.loaded(user: user));
  }

  void _emitSafe(UserState s) {
    if (!isClosed) emit(s);
  }
}