# merkado_auth — Developer Integration Guide

**Merkado OS · Grascope Technology**
Version 0.1.0 · February 2026

---

`merkado_auth` is a Flutter package that delivers the complete Merkado OS authentication lifecycle — signup, email OTP verification, onboarding, login, social login, biometrics, 2FA, cross-app SSO, session recovery, and token refresh — as a drop-in integration. Apps ship zero auth code of their own; the package handles every state, token, and screen internally.

This document is the complete reference for developers integrating `merkado_auth` into a new Grascope product.

---

## Contents

1. [Prerequisites](#1-prerequisites)
2. [Installation](#2-installation)
3. [Initialisation](#3-initialisation)
4. [Configuration](#4-configuration)
5. [Launching the Auth Flow](#5-launching-the-auth-flow)
6. [Listening to Auth Results](#6-listening-to-auth-results)
7. [Auth Flows in Detail](#7-auth-flows-in-detail)
8. [Custom Screens](#8-custom-screens)
9. [Cross-App SSO](#9-cross-app-sso)
10. [Android Manifest](#10-android-manifest)
11. [Token Management](#11-token-management)
12. [Logging](#12-logging)
13. [Storage Architecture](#13-storage-architecture)
14. [Troubleshooting](#14-troubleshooting)
15. [Package Structure](#15-package-structure)
16. [Changelog](#16-changelog)

---

## 1. Prerequisites

Before integrating `merkado_auth`, ensure the following are in place.

### 1.1 Flutter & Dart SDK

| Requirement | Minimum Version |
|---|---|
| Flutter | 3.0.0 |
| Dart SDK | 3.0.0 |
| Xcode (iOS) | 14.0 |
| Android SDK | API 21 (Android 5.0) |

### 1.2 Repository access

The package is not published to pub.dev. It lives in the Grascope monorepo on GitHub. You need read access to the repository before you can reference it as a dependency.

> **Note:** Contact the Grascope platform team to be added as a collaborator on the `merkado_designs` repository if you have not already received an invitation.

### 1.3 common_utils2

`merkado_auth` depends on `common_utils2`, the shared utility package from the same monorepo. It provides `SecureStorageService`, `LoggerService`, and the `HttpClient` that the auth package builds on. Both packages must be declared together in your `pubspec.yaml`.

### 1.4 Platform registration

Every Grascope product that uses `merkado_auth` must be registered with the Merkado Identity Service backend. Registration produces a Platform UUID that is required during initialisation. Contact the backend team to register a new platform and receive your UUID.

---

## 2. Installation

### 2.1 pubspec.yaml — GitHub reference (recommended)

Pin to a release tag in production. Never reference `main` in a shipping app.

```yaml
dependencies:
  flutter:
    sdk: flutter

  merkado_auth:
    git:
      url: https://github.com/grascope/merkado_designs.git
      path: packages/merkado_auth
      ref: v0.1.0          # pin to a release tag

  common_utils2:
    git:
      url: https://github.com/grascope/merkado_designs.git
      path: packages/common_utils
      ref: v0.1.0
```

### 2.2 pubspec.yaml — Local path (development only)

Use path references when actively developing the package alongside your app. Switch back to a git reference before merging to main.

```yaml
dependencies:
  merkado_auth:
    path: ../../../merkado_designs/packages/merkado_auth
  common_utils2:
    path: ../../../merkado_designs/packages/common_utils
```

### 2.3 Install

```bash
flutter pub get
```

---

## 3. Initialisation

Call `MerkadoAuth.initialize()` in `main()` before `runApp()`. The call is async and must be awaited. By the time `runApp()` executes, the package has already performed a startup session check and the current auth state is available synchronously via `MerkadoAuth.instance.currentAuthResult`.

### 3.1 Minimal setup

```dart
import 'package:merkado_auth/merkado_auth.dart';
import 'package:common_utils2/common_utils2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise logger first — must be before MerkadoAuth.initialize()
  LoggerService.init(enabled: true, logLevel: LogLevel.debug);
  Bloc.observer = LoggerService.getBlocObserver();

  // 2. Your app's own DI, Firebase, notifications, etc.
  await configureDependencies();

  // 3. Initialise auth — performs startup session check internally
  await MerkadoAuth.initialize(
    config: MerkadoAuthConfig(
      platformId: MerkadoPlatform.myPlatform,   // your platform UUID constant
      baseUrl:    'https://auth-api.merkado.site',
      appName:    'My App',
    ),
    logger: LoggerService.instance,   // optional but strongly recommended
  );

  runApp(const MyApp());
}
```

### 3.2 Initialisation order rule

> **Critical:** `LoggerService.init()` must be called before `MerkadoAuth.initialize()`. If you pass `logger: LoggerService.instance` and the logger is not yet initialised, the app will throw at runtime. Always initialise utilities before passing them to the package.

### 3.3 What happens during initialize()

The call performs the following steps in order:

1. Sets up the package logger and wires it to `AuthEventBus` and `ReLoginEventBus`.
2. Initialises `AuthSecureStorageService` with two scoped storage instances (shared and local).
3. Registers `AuthRemoteDatasource`, `AuthRepository`, all use cases, and `AuthCubit` into GetIt.
4. Adds `MerkadoAuthInterceptor` to the app's Dio instance.
5. Runs `_checkStartupSession()` — reads stored tokens and flags, performs timeout checks, and emits an initial `AuthResult` to `authStream`.

---

## 4. Configuration

All configuration is passed through a single `MerkadoAuthConfig` object. There is no global state to manage — the config is stored internally and referenced for every auth operation and UI render.

### 4.1 MerkadoAuthConfig — all fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `platformId` | `String` | Yes | — | Platform UUID. Use `MerkadoPlatform` constants. |
| `baseUrl` | `String` | Yes | — | Base URL of the Merkado Identity Service. |
| `appName` | `String` | Yes | — | Shown in UI headings and error messages. |
| `appLogo` | `ImageProvider?` | No | `null` | Logo displayed on auth screens. Accepts `AssetImage`, `NetworkImage`, etc. |
| `logoHeight` | `double` | No | `80` | Height in logical pixels of the logo widget. |
| `termsUrl` | `String?` | No | `null` | URL for Terms of Service link on signup screen. |
| `privacyUrl` | `String?` | No | `null` | URL for Privacy Policy link on signup screen. |
| `features` | `AuthFeatures` | No | `AuthFeatures()` | Feature flag set. See Section 4.2. |
| `customScreens` | `CustomAuthScreens?` | No | `null` | Custom screen builders. See Section 8. |
| `primaryColor` | `Color?` | No | Merkado brand | Brand colour used on buttons and accents. |
| `enableSharedKeychain` | `bool` | No | `false` | Enable cross-app SSO shared storage. See Section 9. |

### 4.2 AuthFeatures — feature flags

`AuthFeatures` controls which screens and capabilities are active for a given app. Pass it inside `MerkadoAuthConfig`. All fields default to sensible values — only override what you need to change.

| Flag | Default | Description |
|---|---|---|
| `emailOtpVerification` | `true` | Show OTP screen after signup. Disable if your backend skips OTP. |
| `forgotPassword` | `true` | Show "Forgot password?" link on login and trigger the reset flow. |
| `resetPassword` | `true` | Allow password reset via email link or OTP. |
| `twoFactorAuth` | `false` | Show 2FA screen when backend returns `isMfa: true`. |
| `biometrics` | `false` | Enable Face ID / Fingerprint login on subsequent opens. |
| `crossAppSso` | `true` | Detect existing Grascope accounts from other apps on the same device. |
| `resendOtp` | `true` | Show "Resend code" button on the OTP screen. |
| `socialLogin` | `false` | Show Google / Apple sign-in buttons. |
| `socialProviders` | `{}` | Which social providers to show when `socialLogin` is `true`. |

**Presets**

Two convenience constructors are available for common configurations:

```dart
// Login + signup only — no OTP, no SSO, no social
features: const AuthFeatures.minimal()

// Every feature enabled
features: const AuthFeatures.full()
```

### 4.3 Platform IDs

Use `MerkadoPlatform` constants. Never hardcode raw UUIDs in app code.

| App | Constant | UUID |
|---|---|---|
| MyCut | `MerkadoPlatform.mycut` | `019c761c-d25e-7257-b5ec-8af95ddd202c` |
| Driply | `MerkadoPlatform.driply` | `019c761c-d265-7a25-a095-ec995157cb32` |
| Haulway | `MerkadoPlatform.haulway` | `019c761c-d265-7a25-a095-ec9a7262b4fa` |
| FeastFeed | `MerkadoPlatform.feastFeed` | `019c761c-d265-7a25-a095-ec9bfcd940d6` |
| ItsYourDay | `MerkadoPlatform.itsYourDay` | `019c761c-d265-7a25-a095-ec9c5ad364f5` |

> **Note:** To add a new platform, add a `static const` to `MerkadoPlatform` in the package source, then ask the backend team to register the UUID with the Identity Service. Both steps are required.

---

## 5. Launching the Auth Flow

The package manages its own internal navigation stack. Login, signup, OTP, onboarding, 2FA, and the cross-app account picker are all handled inside the package. Your app never navigates between these screens — it only triggers the flow and listens for the result.

### 5.1 Show the auth flow

Call `pushAuth()` from anywhere in your app that has a `BuildContext`. The call is awaitable — it resolves when the user completes authentication, dismisses the flow, or the session expires.

```dart
// From a button press, a redirect, wherever you need auth:
await MerkadoAuth.instance.pushAuth(context);

// After this line, check authStream for the result.
// The stream already has the latest value — no need to re-subscribe.
```

### 5.2 Check auth state synchronously

`currentAuthResult` holds the most recent `AuthResult` without requiring an `await`. Use it in GoRouter `redirect` callbacks or any place where async is not permitted.

```dart
final isAuthenticated =
    MerkadoAuth.instance.currentAuthResult is AuthSuccess;
```

### 5.3 GoRouter integration

Bridge `authStream` to GoRouter's `refreshListenable` so the router re-evaluates its redirect on every auth state change.

```dart
final _router = GoRouter(
  refreshListenable: _AuthNotifier(),
  redirect: (context, state) {
    final authed =
        MerkadoAuth.instance.currentAuthResult is AuthSuccess;
    if (!authed && state.matchedLocation != '/') return '/';
    return null;
  },
  routes: [ /* your routes */ ],
);

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthResult> _sub;

  _AuthNotifier() {
    _sub = MerkadoAuth.instance.authStream.listen((_) => notifyListeners());
  }

  @override
  void dispose() { _sub.cancel(); super.dispose(); }
}
```

---

## 6. Listening to Auth Results

The package emits `AuthResult` events through `authStream` — a broadcast stream that works with any state management solution. You never need to import Bloc or any package-internal type to handle auth results.

### 6.1 AuthResult sealed class — all types

| Type | When emitted | Key fields |
|---|---|---|
| `AuthLoading` | Any operation has started | — |
| `AuthSuccess` | User is fully authenticated | `accessToken`, `fromCrossAppSso` |
| `AuthEmailNotVerified` | Signup/login returns `verified: false` | `email` |
| `AuthOtpVerified` | OTP accepted (informational) | `message` |
| `AuthOnboardingRequired` | Email verified but onboarding not done | — |
| `AuthMfaRequired` | Backend requests 2FA | `userId`, `message` |
| `AuthFailure` | Any operation failed | `message` |
| `AuthExpired` | Refresh token is dead | `userId?`, `displayName?` |
| `AuthLoggedOut` | User explicitly logged out | — |
| `AuthAccountsDetected` | Cross-app accounts found on device | `accounts` |
| `AuthUnauthenticated` | No session, no known accounts | — |

### 6.2 Listening — any state manager

Subscribe at app startup (e.g. in a root widget's `initState` or a Riverpod provider). Cancel the subscription in `dispose`.

```dart
late final StreamSubscription<AuthResult> _authSub;

@override
void initState() {
  super.initState();
  _authSub = MerkadoAuth.instance.authStream.listen((result) {
    switch (result) {
      case AuthSuccess(:final accessToken):
        // Store token if needed, navigate home
        _myTokenStore.set(accessToken);
        router.go('/home');
      case AuthLoggedOut():
      case AuthExpired():
        router.go('/');
      case AuthFailure(:final message):
        showErrorSnackBar(message);
      default:
        break;
    }
  });
}

@override
void dispose() {
  _authSub.cancel();
  super.dispose();
}
```

### 6.3 Listening — Riverpod

```dart
final authResultProvider = StreamProvider<AuthResult>((ref) {
  return MerkadoAuth.instance.authStream;
});

// In a widget:
final result = ref.watch(authResultProvider);
result.whenData((r) {
  if (r is AuthSuccess) ref.read(routerProvider).go('/home');
});
```

### 6.4 Accessing the access token

`AuthSuccess` carries the short-lived access token scoped to your platform. Store it in your own state layer and attach it to your API calls. The package automatically refreshes it on 401 responses through `MerkadoAuthInterceptor` — you never call refresh manually.

> **Warning:** Access tokens expire in approximately 15 minutes. Do not persist them to disk. Store them in memory only. The package handles re-issuance via the stored refresh token.

---

## 7. Auth Flows in Detail

### 7.1 Signup flow

The signup flow is fully managed internally. Your app calls `pushAuth()` and receives `AuthSuccess` at the end. The intermediate states (OTP verification, onboarding) are handled by the package's own screens unless you provide custom ones.

```
signUp(email, password)
  → POST /auth/register
  → backend issues tokens immediately
  → tokens saved to secure storage
  → emits AuthEmailNotVerified
  ↓
OTP screen shown automatically
  → user enters 6-digit code
  → POST /auth/verify-email   (requires Bearer token)
  → emits AuthOtpVerified → AuthOnboardingRequired
  ↓
Onboarding screen shown automatically
  → user enters firstName, lastName, country, avatarUrl
  → POST /onboarding/complete
  → emits AuthSuccess ✓
```

### 7.2 Login flow

Login adapts to whatever the backend returns. If the account requires OTP or onboarding to be completed, the package resumes those screens automatically.

```
login(email, password)
  → if isMfa: true       → 2FA screen  → verifyTwoFactor()
  → if verified: false   → OTP screen  → verifyEmail()
  → if onboarding: false → Onboarding  → completeOnboarding()
  → all checks pass      → emits AuthSuccess ✓
```

### 7.3 Social login — Google

The package handles the backend exchange. Your app is responsible for obtaining the ID token from the native Google Sign-In SDK.

```dart
// 1. Add google_sign_in to YOUR app's pubspec.yaml (not this package)
// 2. Obtain the token from the native SDK:
final googleUser = await GoogleSignIn().signIn();
final auth = await googleUser!.authentication;

// 3. Hand it to the package cubit:
MerkadoAuth.instance.cubit.signInWithGoogle(
  idToken:    auth.idToken!,
  deviceName: deviceInfo.name,
  deviceOs:   deviceInfo.systemVersion,
);

// 4. Result arrives on authStream — same as email login.
```

### 7.4 Social login — Apple

> **Warning:** Apple only provides `givenName` and `familyName` on the very first authentication. On all subsequent logins these fields are `null`. Cache the name on first login in your own storage.

```dart
// 1. Add sign_in_with_apple to YOUR app's pubspec.yaml
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

MerkadoAuth.instance.cubit.signInWithApple(
  identityToken:     credential.identityToken!,
  authorizationCode: credential.authorizationCode,
  firstName: credential.givenName,   // null on 2nd+ login
  lastName:  credential.familyName,
);
```

### 7.5 Terminated-state resumption

The package saves a checkpoint after every significant auth step. If the app is killed mid-signup, the correct screen is shown automatically on the next launch — the user is not sent back to login.

| Stored state at app kill | Screen shown on relaunch |
|---|---|
| No tokens at all | Login (or account picker if SSO accounts found) |
| Token + `verified: false` + OTP window not expired | OTP screen with email pre-filled |
| Token + `verified: false` + OTP window **expired** (> 15 min) | Login — OTP has expired, user re-authenticates |
| Token + `verified: true` + `onboarding: false` + window not expired | Onboarding screen |
| Token + `verified: true` + `onboarding: false` + window **expired** (> 30 min) | Login — session cleared |
| Token + all complete + token valid | `AuthSuccess` emitted — straight to home |
| Token + all complete + token expired | Refresh attempted → `AuthSuccess` or `AuthExpired` |

### 7.6 Logout

```dart
// Logout current session only:
await MerkadoAuth.instance.cubit.logout();

// Logout all sessions for this user across all devices:
await MerkadoAuth.instance.cubit.logoutAll();

// Both emit AuthLoggedOut on authStream when complete.
```

---

## 8. Custom Screens

Replace any or all built-in auth screens with your own UI. The package continues to manage all state, tokens, API calls, session storage, and navigation. Your screens only render state and call cubit actions.

### 8.1 Replacing screens

Pass a `CustomAuthScreens` instance inside `MerkadoAuthConfig`. Each builder is optional — omit any screen you want to keep as the built-in.

```dart
MerkadoAuthConfig(
  platformId: MerkadoPlatform.myPlatform,
  baseUrl:    'https://auth-api.merkado.site',
  appName:    'My App',
  customScreens: CustomAuthScreens(
    loginScreenBuilder:      (ctx, cubit) => MyLoginScreen(cubit: cubit),
    signupScreenBuilder:     (ctx, cubit) => MySignupScreen(cubit: cubit),
    otpScreenBuilder:        (ctx, cubit, email) => MyOtpScreen(cubit: cubit, email: email),
    onboardingScreenBuilder: (ctx, cubit) => MyOnboardingScreen(cubit: cubit),
    // forgotPasswordScreenBuilder, resetPasswordScreenBuilder,
    // twoFactorScreenBuilder, accountPickerScreenBuilder
  ),
)
```

### 8.2 Available screen builders

| Builder | Arguments | Cubit method to call |
|---|---|---|
| `loginScreenBuilder` | `context, cubit` | `cubit.login(email:, password:)` |
| `signupScreenBuilder` | `context, cubit` | `cubit.signUp(email:, password:)` |
| `otpScreenBuilder` | `context, cubit, email` | `cubit.verifyEmail(email:, otp:)` / `cubit.resendOtp(email:)` |
| `forgotPasswordScreenBuilder` | `context, cubit` | `cubit.forgotPassword(email:)` |
| `resetPasswordScreenBuilder` | `context, cubit, token` | `cubit.resetPassword(token:, newPassword:)` |
| `twoFactorScreenBuilder` | `context, cubit, userId, message` | `cubit.verifyTwoFactor(userId:, otp:)` |
| `accountPickerScreenBuilder` | `context, cubit, hints` | `cubit.continueAsAccount(hint)` |
| `onboardingScreenBuilder` | `context, cubit` | `cubit.completeOnboarding(firstName:, lastName:, country:)` |

### 8.3 Navigation contract for pushed screens

> **Critical:** Two screens are pushed on top of `AuthShell` via `Navigator.push` from the login screen: `SignupScreen` and `ForgotPasswordScreen`. If you replace these with custom screens, you **must** include a `BlocListener` that pops the screen when the cubit emits the correct transition state — `emailNotVerified` for signup, and `passwordResetSent` for forgot password. Failing to do this causes the next screen to render underneath your custom screen rather than replacing it.

```dart
// In your custom signup screen:
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    state.whenOrNull(
      emailNotVerified: (_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
    );
  },
  child: /* your UI */,
)

// In your custom forgot password screen:
// Listen for passwordResetSent and pop in the same way.
```

### 8.4 Listening to cubit state in custom screens

Use `BlocBuilder` or `BlocListener` from `flutter_bloc`. The cubit is already provided in the `BuildContext` by `AuthShell` via `BlocProvider.value`.

```dart
class MyLoginScreen extends StatelessWidget {
  final AuthCubit cubit;
  const MyLoginScreen({required this.cubit, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () => cubit.login(
                    email: _emailCtrl.text,
                    password: _passCtrl.text,
                  ),
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Sign in'),
        );
      },
    );
  }
}
```

---

## 9. Cross-App SSO

When a user is signed into one Grascope app, other Grascope apps on the same device detect that session and present a "Continue as [name]" account picker — no re-authentication needed. The feature requires platform-level configuration before it can be enabled.

### 9.1 Requirements

- All Grascope apps must be signed with the same Android signing keystore.
- All Grascope apps must declare `com.grascope.sharedauth` in Xcode Keychain Sharing.
- All Grascope apps must belong to the same Apple Developer Team.
- `enableSharedKeychain: true` must be set in `MerkadoAuthConfig` for every app.

> **Note:** Set `enableSharedKeychain: false` (the default) until all apps meet the requirements above. Login, signup, and all other flows work normally without it. Only the cross-app account detection is inactive.

### 9.2 Android — shared keystore

All apps must share the same keystore file so Android grants them access to the same `sharedPreferencesName` bucket.

```properties
# key.properties (in your Android app root — gitignored)
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=grascope-production
storeFile=../../grascope_keystore/keystore_grascope_production.jks
```

> **Critical:** If your app is already on the Play Store, its production signing key cannot change. Point other apps at the existing keystore file. The `keyAlias` is internal — users never see it.

### 9.3 iOS — Keychain Sharing

Configure Keychain Sharing in Xcode for every app. This is separate from your bundle ID.

1. Open the app target in Xcode.
2. Navigate to **Signing & Capabilities**.
3. Click **+ Capability** and add **Keychain Sharing**.
4. Add group: `com.grascope.sharedauth`

> **Note:** Apple automatically prefixes the keychain group with your Team ID internally. You declare `com.grascope.sharedauth`; it is stored as `TEAMID.com.grascope.sharedauth`. All apps must belong to the same Team ID.

---

## 10. Android Manifest

Add the following attribute to the `<application>` tag in `android/app/src/main/AndroidManifest.xml`. This enables Flutter's predictive back gesture support on Android 13+ and prevents a system warning at runtime.

```xml
<application
    android:label="My App"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:enableOnBackInvokedCallback="true">   <!-- ADD THIS -->
    ...
</application>
```

> **Note:** This must be added per app. It is not applied by the package automatically. Without it, Android 13+ logs a warning and the system back gesture may behave inconsistently.

---

## 11. Token Management

The package manages the full token lifecycle. Consuming apps do not call any token API directly — they receive the access token once via `AuthSuccess` and let the package handle refresh from that point on.

### 11.1 Token types

| Token | Lifetime | Scope | Stored in |
|---|---|---|---|
| Access token | ~15 minutes | Platform-scoped (per app) | Local secure storage (private to this app) |
| Refresh token | Long-lived | Cross-platform identity | Local storage + shared SSO list |

### 11.2 Automatic refresh

`MerkadoAuthInterceptor` is added to the Dio instance during `initialize()`. It intercepts every outgoing request and:

1. Checks whether the stored access token has more than 30 seconds remaining.
2. If yes — attaches it as a `Bearer` header and proceeds.
3. If the request returns `401` — silently attempts a token refresh using the stored refresh token.
4. On successful refresh — retries the original request with the new token.
5. On failed refresh — emits on `ReLoginEventBus`, which `AuthCubit` picks up and converts into `AuthExpired` on `authStream`.

> **Note — public paths:** The interceptor does not attach tokens to `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`, or social login endpoints. All other endpoints — including `/auth/verify-email`, `/auth/resend-otp`, and `/onboarding/complete` — receive the token automatically.

---

## 12. Logging

The package uses the `LoggerService` from `common_utils2` (backed by Talker). Pass `LoggerService.instance` to `initialize()` and all package logs appear inline with your app's Talker output. The package never creates its own logger instance.

### 12.1 Wiring the logger

```dart
await MerkadoAuth.initialize(
  config: /* ... */,
  logger: LoggerService.instance,   // pass your app's logger
);

// If logger is omitted, all package logs are silently discarded.
// No errors are thrown — logging is entirely optional.
```

### 12.2 Log tags by layer

| Tag | Source layer | What it covers |
|---|---|---|
| `[MerkadoAuth]` | Entry point | Initialisation, storage setup, DI registration, `pushAuth` calls |
| `[AuthCubit]` | Presentation | Every method call, state transition, session check, timeout decision |
| `[AuthRepo]` | Data — repository | Every repository method with success/failure outcome |
| `[AuthDatasource]` | Data — HTTP | Every HTTP request with status code, error body, and stack trace on failure |
| `[AuthStorage]` | Infrastructure — storage | Every significant read/write to secure storage |
| `[Interceptor]` | Infrastructure — HTTP | Token attachment decisions, refresh attempts, retry outcomes |
| `[AuthEventBus]` | Infrastructure — bus | Every `AuthResult` emitted to the stream |
| `[ReLoginEventBus]` | Infrastructure — bus | Session expiry signals from the interceptor |

### 12.3 Log levels

| Level | When used |
|---|---|
| `info` | Major operations: initialisation, login attempt, logout, session checks |
| `debug` | Detailed flow: token validation, storage reads, HTTP success responses |
| `warning` | Non-critical issues: session expiry, logout HTTP errors, timeout decisions |
| `error` | Failures: HTTP errors, exceptions with stack traces, DI registration failures |

---

## 13. Storage Architecture

The package uses two isolated secure storage scopes. Consuming apps should never read or write to either scope directly — use the public methods on `MerkadoAuth.instance` or observe `authStream` instead.

### 13.1 Two-scope model

| Scope | Purpose | Visible to other apps? | Requires shared keychain? |
|---|---|---|---|
| Shared | Cross-app SSO account list (known accounts, active user ID) | Yes, if shared keychain enabled | Yes |
| Local | Per-app tokens, session flags, flow state | No — private to this app | No |

### 13.2 Flow-state keys (for reference only)

These keys power terminated-state resumption. They are set and cleared by the package automatically. Documented here for debugging purposes — do not read or write them from app code.

| Key | Type | Purpose |
|---|---|---|
| `merkado_access_token` | `String` | Short-lived platform-scoped JWT |
| `merkado_access_token_expires_at` | `String` (ms timestamp) | Unix ms timestamp of token expiry |
| `merkado_refresh_token` | `String` | Long-lived refresh token |
| `merkado_session_id` | `String` | Backend session ID for server-side logout |
| `merkado_is_email_verified` | `bool` | Whether OTP verification is complete |
| `merkado_onboarding_completed` | `bool` | Whether onboarding profile is complete |
| `merkado_pending_verification_email` | `String` | Email pre-fills OTP screen after app kill |
| `merkado_otp_started_at` | `String` (ms timestamp) | When OTP flow started — gates 15-minute timeout |
| `merkado_onboarding_started_at` | `String` (ms timestamp) | When onboarding started — gates 30-minute timeout |

---

## 14. Troubleshooting

### "GetIt: Object/factory with type AuthRepository is not registered"

**Cause:** `MerkadoAuth.initialize()` was not called before something tried to resolve `AuthRepository` from GetIt.

**Fix:** Ensure `initialize()` is called and awaited in `main()` before `runApp()` and before any code that might trigger GetIt resolution.

---

### "MerkadoAuth not initialized" / Null check operator on null value

**Cause:** `MerkadoAuth.instance` was accessed before `initialize()` completed.

**Fix:** `await MerkadoAuth.initialize(...)` before calling `MerkadoAuth.instance`.

---

### /auth/resend-otp returns 401

**Cause:** The backend requires an `Authorization` header on this endpoint, but it was listed in the interceptor's public paths (now fixed in v0.1.0+).

**Fix:** Ensure you are on package version 0.1.0 or later. The interceptor no longer treats `/auth/resend-otp`, `/auth/verify-email`, or `/onboarding/complete` as public paths — all three now receive the Bearer token automatically.

---

### OTP screen shown on relaunch even after hours away

**Cause:** No timeout was enforced on the pending-verification state in earlier versions.

**Fix:** The package now enforces a 15-minute OTP window and a 30-minute onboarding window. After either window expires, the incomplete session is cleared and the user is routed to login. Within the window, users return to exactly where they left off.

---

### Signup shows OTP beneath the signup screen instead of replacing it

**Cause:** `SignupScreen` was `Navigator.push`ed on top of `AuthShell`. When `AuthShell` rebuilt its body to `OtpScreen`, the signup screen was still on top of the navigator stack.

**Fix:** `SignupScreen` now includes a `BlocListener` that pops itself on `emailNotVerified`. The same fix applies to `ForgotPasswordScreen` on `passwordResetSent`. If you use custom screens, apply the same pattern (see Section 8.3).

---

### Cross-app SSO not detecting accounts from other Grascope apps

Confirm all of the following:

- All apps are signed with the same Android keystore (same `storeFile`, same `keyAlias`).
- All apps declare `com.grascope.sharedauth` under Keychain Sharing in Xcode.
- All apps belong to the same Apple Developer Team ID.
- `enableSharedKeychain: true` is set in `MerkadoAuthConfig` in every app.
- All apps have been freshly installed after the above configuration was applied.

---

### Package symbols not resolving / red underlines after pub get

**Fix:** Restart the Dart Analysis Server. In VS Code: Command Palette → **Dart: Restart Analysis Server**. In Android Studio: **File → Invalidate Caches → Restart**.

---

### "Target of URI doesn't exist: package:merkado_auth/merkado_auth.dart"

**Cause:** The path or git ref in `pubspec.yaml` does not resolve to a valid package.

**Fix:** Verify the path from your app root. For git references, confirm the tag exists in the repository. Run `flutter pub get` and check the output for resolution errors.

---

## 15. Package Structure

```
merkado_auth/
├── lib/
│   ├── merkado_auth.dart               ← Public barrel — import this file only
│   └── src/
│       ├── merkado_auth.dart            ← MerkadoAuth entry point + DI setup
│       ├── core/
│       │   ├── config/
│       │   │   ├── merkado_auth_config.dart
│       │   │   ├── merkado_platform.dart
│       │   │   ├── auth_features.dart
│       │   │   └── custom_auth_screens.dart
│       │   ├── events/
│       │   │   ├── auth_event_bus.dart       ← authStream source
│       │   │   └── re_login_event_bus.dart   ← interceptor → cubit bridge
│       │   ├── interceptors/
│       │   │   └── merkado_auth_interceptor.dart
│       │   ├── models/
│       │   │   ├── auth_result.dart          ← sealed AuthResult types
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
│                   ├── signup_screen.dart
│                   └── onboarding_screen.dart
└── test/
    └── auth_cubit_test.dart
```

---

## 16. Changelog

### v0.1.0 — February 2026

- Initial release
- Full signup / login / OTP / onboarding flows
- Social login (Google, Apple)
- Cross-app SSO with account picker
- Terminated-state resumption with flow checkpoints
- OTP 15-minute and onboarding 30-minute timeout windows
- 180 log calls across all layers with tagged output per layer
- `MerkadoAuthInterceptor` with automatic token refresh and retry
- Android predictive back gesture support (`enableOnBackInvokedCallback`)
- Navigation fix: `SignupScreen` and `ForgotPasswordScreen` pop themselves on state transition

---

*Grascope Technology · Merkado OS · Confidential*