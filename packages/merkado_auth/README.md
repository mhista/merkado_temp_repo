# merkado_auth

Shared authentication package for all Grascope apps built on Merkado OS.

Handles the full identity lifecycle — signup, email OTP verification, onboarding, login, social login, biometrics, 2FA, cross-app SSO, token refresh, and session recovery — so each product app ships with zero auth code of its own.

> **Not published to pub.dev.** Distributed via the Merkado monorepo on GitHub and referenced via `git:` or local `path:` dependency.

---

## Contents

- [How it fits into the ecosystem](#how-it-fits-into-the-ecosystem)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Auth flow reference](#auth-flow-reference)
- [Terminated state resumption](#terminated-state-resumption)
- [Cross-app SSO](#cross-app-sso)
- [Social login](#social-login)
- [Feature flags](#feature-flags)
- [Custom screens](#custom-screens)
- [Logging](#logging)
- [Platform IDs](#platform-ids)
- [Android keystore](#android-keystore)
- [iOS keychain setup](#ios-keychain-setup)
- [Testing](#testing)
- [Package structure](#package-structure)
- [Troubleshooting](#troubleshooting)

---

## How it fits into the ecosystem

```
merkado_systems/
└── packages/
    ├── merkado/_design_system        ← SecureStorageService, StorageService, LoggerService, HttpClient
    └── merkado_auth/        ← this package (depends on common_utils)

```

The package is **state-management agnostic**. It uses Bloc internally but exposes zero Bloc types to consuming apps. Apps interact only through `MerkadoAuth.instance` and listen to an `authStream` that emits sealed `AuthResult` subclasses — compatible with Bloc, Riverpod, Provider, GetX, or plain `StreamSubscription`.

**Dependency registration** is fully self-contained. The package registers its own `AuthRemoteDatasource`, `AuthRepository`, use cases, and `AuthCubit` into GetIt during `initialize()`. Consuming apps do not need to register anything auth-related.

---

## Installation

### From GitHub (recommended for CI and shared machines)

```yaml
# your_app/pubspec.yaml
dependencies:
  merkado_auth:
    git:
      url: https://github.com/mhista/merkado_temp_repo.git
      path: packages/merkado_auth
      ref: v1.0.1   # pin to a tag — don't use main in production

```

Then run:

```bash
flutter pub get
```

---

## Quick start

### 1. `main.dart`

```dart
import 'package:merkado_auth/merkado_auth.dart';
import 'package:common_utils2/common_utils2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first — pass it to MerkadoAuth so auth logs
  // appear inline with the rest of your Talker output
  LoggerService.init(enabled: true, logLevel: LogLevel.debug);
  Bloc.observer = LoggerService.getBlocObserver();

  // Initialize your app's DI, Firebase, notifications, etc.
  await configureDependencies();

  // Initialize MerkadoAuth — runs startup session check internally.
  // By the time runApp() is called, currentAuthResult already reflects
  // the user's state (authenticated, mid-OTP, mid-onboarding, etc.)
  await MerkadoAuth.initialize(
    config: MerkadoAuthConfig(
      platformId: MerkadoPlatform.mycut,
      baseUrl: 'https://auth-api.merkado.site',
      appName: 'MyCut',
      appLogo: const AssetImage('assets/images/logo.png'),
      termsUrl: 'https://mycut.app/terms',
      privacyUrl: 'https://mycut.app/privacy',
      enableSharedKeychain: false, // see Cross-app SSO section
      features: AuthFeatures(
        biometrics: true,
        socialLogin: true,
        socialProviders: {SocialProvider.google, SocialProvider.apple},
      ),
    ),
    logger: LoggerService.instance, // optional but strongly recommended
  );

  runApp(const MyApp());
}
```

### 2. Listen to auth results

Subscribe from anywhere in the app. Works with any state manager.

```dart
MerkadoAuth.instance.authStream.listen((result) {
  switch (result) {
    case AuthSuccess():
      router.go('/home');
    case AuthLoggedOut():
    case AuthExpired():
      router.go('/');
    case AuthFailure(:final message):
      showSnackBar(message);
    default:
      break;
  }
});
```

### 3. Show the auth flow

The package manages its own internal navigation stack — login, signup, OTP, onboarding, and account picker screens are all handled internally.

```dart
await MerkadoAuth.instance.pushAuth(context);
```

### 4. Read current state synchronously

Safe to call in GoRouter's `redirect` function without awaiting.

```dart
final isAuthenticated = MerkadoAuth.instance.currentAuthResult is AuthSuccess;
```

### 5. GoRouter integration

```dart
GoRouter(
  refreshListenable: _AuthRefreshNotifier(),
  redirect: (context, state) {
    final isAuthenticated =
        MerkadoAuth.instance.currentAuthResult is AuthSuccess;

    if (!isAuthenticated && state.matchedLocation != '/') return '/';
    return null;
  },
);

/// Bridges MerkadoAuth's stream to GoRouter's refreshListenable.
/// Router re-evaluates redirect on every auth state change automatically.
class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthResult> _sub;

  _AuthRefreshNotifier() {
    _sub = MerkadoAuth.instance.authStream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
```

---

## Auth flow reference

### Signup

```
signUp(email, password)
  → backend issues tokens immediately (before email verification)
  → tokens saved to storage  ← enables terminated state resumption
  → emits AuthEmailNotVerified
  ↓
verifyEmail(email, otp)
  → backend returns { message: "Email verified successfully" }
  → isEmailVerified flag saved
  → emits AuthOtpVerified → AuthOnboardingRequired
  ↓
completeOnboarding(firstName, lastName, country, avatarUrl?)
  → POST /onboarding/complete
  → shared SSO hint updated with real display name
  → emits AuthSuccess ✓
```

### Login

```
login(email, password)
  → if isMfa=true           → emits AuthMfaRequired → verifyTwoFactor()
  → if verified=false       → emits AuthEmailNotVerified → OTP flow
  → if onboarding=false     → emits AuthOnboardingRequired → onboarding flow
  → all good                → emits AuthSuccess ✓
```

### Token refresh

The `MerkadoAuthInterceptor` handles token refresh transparently on every 401 response. Apps never call refresh manually. On startup, if the stored access token has expired but a refresh token exists, the package attempts a refresh before emitting `AuthSuccess` or `AuthExpired`.

---

## Terminated state resumption

The package stores enough state to resume any interrupted auth flow. On every app launch, the startup check reads stored flags and emits the correct initial `AuthResult` — no manual routing logic needed in the app.

| Stored state | Emitted on relaunch |
|---|---|
| No tokens | `AuthUnauthenticated` → check SSO → show login |
| Token + `verified=false` | `AuthEmailNotVerified(email)` → OTP screen pre-filled |
| Token + `verified=true` + `onboarding=false` | `AuthOnboardingRequired` → onboarding screen |
| Token + both true + token valid | `AuthSuccess` → straight to home |
| Token + both true + token expired | Attempts refresh → `AuthSuccess` or `AuthExpired` |

A user who signs up, receives their verification email, kills the app, and relaunches two hours later will land directly on the OTP screen with their email pre-filled — not on the login screen.

---

## Cross-app SSO

When a user is signed into MyCut and opens Driply for the first time, Driply detects the MyCut session and shows **"Continue as Amara Okafor"** — no re-login needed.

### Requirements

All Grascope apps must share the same Android signing keystore AND declare the same iOS Keychain Access Group. Until that is in place, set `enableSharedKeychain: false`. SSO detection will not work but everything else functions normally.

### Enabling

1. All apps signed with the same `keystore_grascope.jks` (see [Android keystore](#android-keystore))
2. All apps declare `com.grascope.sharedauth` in Xcode Keychain Sharing (see [iOS keychain setup](#ios-keychain-setup))
3. Set `enableSharedKeychain: true` in `MerkadoAuthConfig`
4. Set `features: AuthFeatures(crossAppSso: true)`

### What the user sees

```
Driply first launch
  → detects MyCut session in shared storage
  → shows account picker: "Continue as Amara Okafor" / "Use different account"
  → user selects account
  → package exchanges refresh token for Driply-scoped access token
  → emits AuthSuccess(fromCrossAppSso: true) ✓
```

---

## Social login

The package handles the backend exchange. The consuming app triggers the native SDK and passes the token through.

### Google

```dart
// 1. Add google_sign_in to your app's pubspec.yaml (not this package's)
// 2. Obtain the token:
final googleUser = await GoogleSignIn().signIn();
final auth = await googleUser!.authentication;

// 3. Pass to the package — it calls POST /auth/social/google internally:
MerkadoAuth.instance.cubit.signInWithGoogle(
  idToken: auth.idToken!,
  deviceName: deviceInfo.name,
  deviceOs: deviceInfo.systemVersion,
);

// 4. Same AuthSuccess/AuthFailure events on authStream as normal login
```

### Apple

```dart
// 1. Add sign_in_with_apple to your app's pubspec.yaml
// 2. Apple only provides name on FIRST login — cache it yourself
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
);

// 3. Pass to the package:
MerkadoAuth.instance.cubit.signInWithApple(
  identityToken: credential.identityToken!,
  authorizationCode: credential.authorizationCode,
  firstName: credential.givenName,   // null on second+ login
  lastName: credential.familyName,
);
```

---

## Feature flags

Control which screens and capabilities are active per app without modifying the package.

```dart
AuthFeatures(
  emailOtpVerification: true,   // OTP screen after signup (default: true)
  forgotPassword: true,         // Forgot password link + flow (default: true)
  resetPassword: true,          // Reset password via email (default: true)
  twoFactorAuth: false,         // 2FA screen when backend requests it (default: false)
  biometrics: false,            // Face ID / Fingerprint login (default: false)
  crossAppSso: true,            // Account picker on startup (default: true)
  resendOtp: true,              // Resend button on OTP screen (default: true)
  socialLogin: false,           // Google / Apple buttons (default: false)
  socialProviders: {            // Which providers to show
    SocialProvider.google,
    SocialProvider.apple,
  },
)

// Presets:
AuthFeatures.minimal()   // login + signup only
AuthFeatures.full()      // everything enabled
```

---

## Custom screens

Replace any built-in screen while the package manages all state, tokens, and navigation internally.

```dart
MerkadoAuthConfig(
  // ...
  customScreens: CustomAuthScreens(
    loginScreenBuilder: (context, cubit) =>
        MyBrandedLoginScreen(cubit: cubit),
    otpScreenBuilder: (context, cubit) =>
        MyOtpScreen(cubit: cubit),
    onboardingScreenBuilder: (context, cubit) =>
        MyOnboardingScreen(cubit: cubit),
  ),
)
```

Your custom screen calls cubit methods directly and listens to cubit state. The package still handles storage, token management, and `authStream` emission.

```dart
class MyBrandedLoginScreen extends StatelessWidget {
  final AuthCubit cubit;
  const MyBrandedLoginScreen({required this.cubit, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => cubit.login(email: _email, password: _password),
      child: const Text('Sign In'),
    );
  }
}
```

---

## Logging

At the moment, the package never creates its own `LoggerService`. Pass the app's instance to `initialize()` and all auth logs route through your existing Talker setup automatically.

```dart
await MerkadoAuth.initialize(
  config: ...,
  logger: LoggerService.instance,
);
```

Logs are tagged by layer so you can filter in Talker:

| Tag | Source |
|---|---|
| `[MerkadoAuth]` | Package initialization and navigation |
| `[AuthCubit]` | Every state transition, startup check, session management |
| `[AuthDatasource]` | Every HTTP request and response with status code |

If `logger` is omitted, all logs are silently discarded — no errors thrown.

---

## Platform IDs

Each Grascope product has a unique UUID registered with the Identity Service. Use the correct constant — never hardcode the raw UUID.

| App | Constant | UUID |
|---|---|---|
| MyCut | `MerkadoPlatform.mycut` | `019c761c-d25e-7257-b5ec-8af95ddd202c` |
| Driply | `MerkadoPlatform.driply` | `019c761c-d265-7a25-a095-ec995157cb32` |
| Haulway | `MerkadoPlatform.haulway` | `019c761c-d265-7a25-a095-ec9a7262b4fa` |
| FeastFeed | `MerkadoPlatform.feastFeed` | `019c761c-d265-7a25-a095-ec9bfcd940d6` |
| ItsYourDay | `MerkadoPlatform.itsYourDay` | `019c761c-d265-7a25-a095-ec9c5ad364f5` |

To add a new platform, add a constant to `MerkadoPlatform` and register the UUID with the backend team.

---

## Android keystore

Cross-app SSO requires all Grascope apps to share the same signing keystore so Android grants them access to the same `sharedPreferencesName`.

### Shared keystore (for new apps)

Create one keystore used by all apps:

```
grascope_keystore/
├── keystore_grascope_dev.jks
├── keystore_grascope_staging.jks
└── keystore_grascope_production.jks
```

`key.properties`:
```properties
storePassword.production=your_password
keyPassword.production=your_password
keyAlias.production=grascope-production-key
storeFile.production=../../grascope_keystore/keystore_grascope_production.jks
```

### Reusing MyCut's keystore for other apps

If MyCut is already on the Play Store, its production key cannot change. Point other apps at `keystore_mycut_production.jks` using alias `mycut-production-key`. The alias name is internal — users never see it. This is valid and fully functional.

> **Important:** Do not set `enableSharedKeychain: true` until all production apps share the same signing key. Mixing keys silently breaks cross-app storage access — each app sees its own isolated bucket.

---

## iOS keychain setup

Required for cross-app SSO on iOS. Configure per app in Xcode — not on App Store Connect.

1. Open the app target in Xcode
2. **Signing & Capabilities** → **+ Capability** → **Keychain Sharing**
3. Add group: `com.grascope.sharedauth`

This is separate from your bundle ID (`com.grascope.mycut`). The keychain group is a shared storage bucket — Apple prefixes it internally with your Team ID. All apps must belong to the same Apple Developer Team.

---

## Testing

### Run package tests

```bash
cd packages/merkado_auth
flutter test
```

### Simulate auth events in widget tests

```dart
setUp(() {
  // Simulate an authenticated session
  AuthEventBus.instance.emit(const AuthSuccess(accessToken: 'test_token'));
});

tearDown(() {
  AuthEventBus.instance.dispose();
});
```

### Test terminated state resumption

Mock `AuthSecureStorageService` to pre-populate storage flags:

```dart
// Simulate: signed up, killed app before OTP
when(() => mockStorage.getAccessToken()).thenAnswer((_) async => 'token');
when(() => mockStorage.isEmailVerified()).thenAnswer((_) async => false);
when(() => mockStorage.getPendingVerificationEmail())
    .thenAnswer((_) async => 'user@test.com');

await cubit.init(testConfig);

expect(cubit.state, isA<AuthState>());
// authStream emits AuthEmailNotVerified(email: 'user@test.com')
```

---

## Package structure

```
merkado_auth/
├── lib/
│   ├── merkado_auth.dart              ← public barrel (import this)
│   └── src/
│       ├── merkado_auth.dart          ← MerkadoAuth entry point + DI
│       ├── core/
│       │   ├── config/
│       │   │   ├── merkado_auth_config.dart
│       │   │   ├── merkado_platform.dart
│       │   │   ├── auth_features.dart
│       │   │   └── custom_auth_screens.dart
│       │   ├── events/
│       │   │   ├── auth_event_bus.dart     ← authStream source
│       │   │   └── re_login_event_bus.dart ← interceptor → cubit bridge
│       │   ├── interceptors/
│       │   │   └── merkado_auth_interceptor.dart
│       │   ├── models/
│       │   │   ├── auth_result.dart        ← sealed AuthResult subclasses
│       │   │   ├── grascope_session_hint.dart
│       │   │   └── merkado_user.dart
│       │   └── storage/
│       │       ├── auth_storage_keys.dart
│       │       └── auth_secure_storage_service.dart
│       └── features/auth/
│           ├── data/
│           │   ├── datasources/auth_remote_datasource.dart
│           │   └── repositories/auth_repository_impl.dart
│           ├── domain/
│           │   ├── repositories/auth_repository.dart
│           │   └── usecases/auth_usecases.dart
│           └── presentation/
│               ├── cubit/
│               │   ├── auth_cubit.dart
│               │   └── auth_state.dart
│               └── screens/
│                   ├── auth_shell.dart
│                   ├── auth_screens.dart
│                   ├── login_screen.dart
│                   ├── onboarding_screen.dart
│                   └── account_picker_screen.dart
└── test/
    └── auth_cubit_test.dart
```

---

## Troubleshooting

**`GetIt: Object/factory with type AuthRepository is not registered`**

You're using an older version of the package where `AuthRepositoryImpl` wasn't registered in `_setupDependencies`. Update to the latest version — the registration order is now: datasource → repository → use cases → cubit.

**`MerkadoAuth not initialized`**

`MerkadoAuth.instance` was accessed before `MerkadoAuth.initialize()` completed. Move `initialize()` above `runApp()` and await it.

**`AuthSecureStorageService not initialized`**

`AuthSecureStorageService.instance` was called before `MerkadoAuth.initialize()`. The package initializes storage internally during `initialize()` — never call `AuthSecureStorageService.init()` directly from the app.

**`Target of URI doesn't exist: 'package:merkado_auth/merkado_auth.dart'`**

Usually means the path in `pubspec.yaml` doesn't resolve. Verify from the app root:
```bash
ls path/to/merkado_designs/packages/merkado_auth/pubspec.yaml
```
Also ensure `resolution: workspace` is removed from `merkado_auth/pubspec.yaml` if present.

**Cross-app SSO not detecting accounts**

Both apps must be signed with the same keystore (Android) and share `com.grascope.sharedauth` in Keychain Sharing (iOS). Verify `enableSharedKeychain: true` is set in both apps' `MerkadoAuthConfig`.

**Token expired on startup — user sent to login instead of home**

The backend's `/auth/refresh` response must include `expiresIn` (seconds). If missing, the package cannot track expiry and falls back to treating the token as expired on every launch.

**Apple Sign In: name is null on second login**

This is Apple's intended behaviour — they only send `givenName` and `familyName` on the first authentication. Cache the name during first login in your own storage. The package passes through whatever the app provides.

**Import shows no autocomplete / red underline despite `pub get` succeeding**

Restart the Dart Analysis Server in your IDE: in VS Code, open the Command Palette → `Dart: Restart Analysis Server`. In Android Studio: **File → Invalidate Caches → Restart**.