# merkado_wallet

**Merkado OS · Flutter Package · v0.1.0**

> State-management-agnostic · ScreenUtil-compatible · Screen-customizable · Notification-bridgeable

The foundational wallet layer for all Grascope product apps. Powers balance management, real and demo funding, multi-currency withdrawals, escrow-aware transactions, and PIN security — all from a single shared backend.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Folder Structure](#folder-structure)
4. [Architecture](#architecture)
5. [Installation](#installation)
6. [Quick Start](#quick-start)
7. [Configuration Reference](#configuration-reference)
8. [API Endpoints](#api-endpoints)
9. [Nigerian Bank List — Public API](#nigerian-bank-list--public-api)
10. [Token Lifecycle](#token-lifecycle)
11. [State Management Integration](#state-management-integration)
12. [Notification Bridge](#notification-bridge)
13. [Explore Deals Section](#explore-deals-section)
14. [Custom Screens](#custom-screens)
15. [PIN Security](#pin-security)
16. [Demo Mode](#demo-mode)
17. [Multi-Currency Withdrawals](#multi-currency-withdrawals)
18. [Event Reference](#event-reference)
19. [Why Not Initialize in main()](#why-not-initialize-in-main)
20. [Per-Product Examples](#per-product-examples)
21. [Dependencies](#dependencies)

---

## Overview

`merkado_wallet` is the shared wallet infrastructure package for the Grascope ecosystem. Every product app — MyCut, Driply, ItsYourDay, FeastFeed — runs on the same wallet backend. This package is the Flutter client for that backend.

It is intentionally product-agnostic at its core, with injection points that allow each app to customize scope, appearance, and navigation without forking the package.

---

## Features

| Feature | Description |
|---|---|
| **Balance display** | Three-field balance (available, ledger, withdrawable) with eye toggle |
| **Add Money — Production** | Paystack/Fincra checkout via `POST /v1/wallet/fund`, returns checkout URL |
| **Add Money — Demo** | Instant credit via `POST /v1/wallet/demo/fund`, no payment gateway |
| **Withdrawals** | NGN, GBP, EUR, USD bank accounts with full form validation |
| **Bank list — NGN** | Auto-fetched from Paystack public API, 28-bank hardcoded fallback |
| **PIN security** | SHA-256 + userId salt, 5-attempt lockout, biometric-ready |
| **Explore Deals** | Product-scoped action buttons injected by the calling app |
| **Notification bridge** | Typed `WalletNotificationEvent` — wire to any notification plugin |
| **State-agnostic events** | `WalletEventBus` broadcast stream works with BLoC, Riverpod, GetX, setState |
| **Custom screens** | Override any screen while the package manages all data and state |
| **ScreenUtil-native** | Initializes inside the widget tree — all sizing uses `.w`, `.h`, `.sp` |
| **Session-safe** | Token held in-memory only, never written to disk by this package |

---

## Folder Structure

```
merkado_wallet/
├── pubspec.yaml
├── README.md
└── lib/
    ├── merkado_wallet.dart                  ← Public barrel export
    └── src/
        ├── merkado_wallet_scope.dart        ← InheritedWidget entry point + controller
        │
        ├── core/
        │   ├── config/
        │   │   ├── merkado_wallet_config.dart     ← MerkadoWalletConfig, WalletFeatures,
        │   │   │                                     WalletExploreAction, WalletCurrencyConfig
        │   │   └── custom_wallet_screens.dart     ← Screen builder overrides
        │   │
        │   ├── errors/
        │   │   └── wallet_result.dart             ← WalletResult<T> sealed class,
        │   │                                         PaginatedResult<T>
        │   ├── events/
        │   │   ├── wallet_event_bus.dart          ← WalletEventBus broadcast stream +
        │   │   │                                     all WalletEvent sealed subclasses
        │   │   └── wallet_notification_event.dart ← WalletNotificationEvent + typed factories
        │   │
        │   ├── http/
        │   │   └── wallet_http_client.dart        ← Dio wrapper, WalletAuthInterceptor,
        │   │                                         401 → session-expired bus emit
        │   └── storage/
        │       ├── wallet_secure_storage.dart     ← FlutterSecureStorage wrapper
        │       └── wallet_storage_keys.dart       ← All storage key constants
        │
        ├── features/
        │   │
        │   ├── wallet/                            ← Core wallet balance feature
        │   │   ├── data/
        │   │   │   ├── datasource/
        │   │   │   │   └── wallet_remote_datasource.dart   ← GET /v1/wallet
        │   │   │   │                                          POST /v1/wallet/fund
        │   │   │   │                                          POST /v1/wallet/demo/fund
        │   │   │   │                                          POST /v1/wallet/demo/withdraw
        │   │   │   └── repository/
        │   │   │       └── wallet_repository_impl.dart
        │   │   ├── domain/
        │   │   │   ├── models/
        │   │   │   │   └── wallet.dart            ← Wallet, FundWalletResponse,
        │   │   │   │                                 DemoFundResponse, DemoWithdrawResponse
        │   │   │   └── repositories/
        │   │   │       └── wallet_repository.dart ← Abstract interface
        │   │   └── presentation/
        │   │       ├── cubit/
        │   │       │   ├── wallet_cubit.dart      ← WalletCubit (balance, fund, demo ops)
        │   │       │   └── wallet_state.dart      ← Freezed states
        │   │       └── screens/
        │   │           └── wallet_home_screen.dart ← Main wallet screen (balance card,
        │   │                                          action buttons, explore, recent tx)
        │   │
        │   ├── withdrawal/                        ← Withdrawals + bank accounts
        │   │   ├── data/
        │   │   │   ├── datasource/
        │   │   │   │   └── withdrawal_remote_datasource.dart ← All 10 withdrawal endpoints
        │   │   │   └── repository/
        │   │   │       └── withdrawal_repository_impl.dart   ← NGN → Paystack fallback here
        │   │   ├── domain/
        │   │   │   ├── models/
        │   │   │   │   ├── bank_account.dart      ← BankAccount, SupportedBank, BankCurrency enum
        │   │   │   │   └── withdrawal_record.dart ← WithdrawalRecord, WithdrawalRequest
        │   │   │   └── repositories/
        │   │   │       └── withdrawal_repository.dart
        │   │   └── presentation/
        │   │       ├── cubit/
        │   │       │   ├── withdrawal_cubit.dart  ← WithdrawalCubit
        │   │       │   └── withdrawal_state.dart
        │   │       └── screens/
        │   │           ├── withdraw_screen.dart         ← Amount + bank selector + PIN gate
        │   │           ├── add_money_screen.dart        ← Funding flow (real + demo)
        │   │           ├── add_bank_account_screen.dart ← NGN / GBP / EUR / USD tab forms
        │   │           ├── withdrawal_history_screen.dart
        │   │           └── pin_entry_sheet.dart         ← Modal bottom sheet keypad
        │   │
        │   └── pin/                               ← PIN management
        │       ├── pin_service.dart               ← SHA-256 hashing, lockout logic
        │       ├── pin_cubit.dart                 ← PinCubit
        │       └── pin_state.dart                 ← Freezed states
        │
        ├── services/
        │   └── banks/
        │       └── nigerian_bank_service.dart     ← Paystack public API + 28-bank fallback
        │
        └── shared/
            └── widgets/
                └── wallet_widgets.dart            ← WalletAmountText, ExploreActionsRow,
                                                      WithdrawalListTile, shimmer loaders
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Consuming App (MyCut / Driply / ItsYourDay / FeastFeed)                   │
│                                                                             │
│  ScreenUtilInit                                                             │
│    └── MerkadoWalletScope  ◄── MerkadoWalletConfig (injected by app)       │
│          │                                                                  │
│          ├── MerkadoWalletController  (MerkadoWalletScope.of(context))      │
│          │     ├── setAccessToken(token)   ◄── from merkado_auth            │
│          │     ├── clearSession()                                           │
│          │     ├── pushWallet(context)                                      │
│          │     ├── walletStream  ──────────────► app's state manager        │
│          │     └── refreshBalance()                                         │
│          │                                                                  │
│          ├── WalletCubit                                                    │
│          │     └── WalletRepository                                         │
│          │           └── WalletRemoteDatasource                             │
│          │                 └── WalletHttpClient (Dio)                       │
│          │                       └── WalletAuthInterceptor                 │
│          │                             └── 401 → WalletEventBus.emit()     │
│          │                                                                  │
│          ├── WithdrawalCubit                                                │
│          │     └── WithdrawalRepository                                     │
│          │           ├── WithdrawalRemoteDatasource                         │
│          │           └── NigerianBankService  ◄── Paystack public API      │
│          │                                                                  │
│          ├── PinCubit                                                       │
│          │     └── PinService (SHA-256, lockout, secure storage)            │
│          │                                                                  │
│          └── WalletEventBus  ─────────────────► onWalletEvent callback     │
│                                                 walletStream (Riverpod /    │
│                                                 BLoC / GetX / setState)    │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Data flow per operation:**

```
User taps "Withdraw"
  → WithdrawScreen validates form
  → PinEntrySheet slides up (if pinLock: true)
  → WithdrawalCubit.requestWithdrawal()
  → WithdrawalRepository.requestWithdrawal()
  → WithdrawalRemoteDatasource → POST /v1/withdrawal/request
  → WalletResult<WithdrawalRecord>
  → WalletEventBus.emit(WalletWithdrawalRequested)
  → onNotification callback → CommonNotificationService
  → app's stream listener / Riverpod / BLoC
```

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  merkado_wallet:
    path: ../packages/merkado_wallet  # local path, or git URL
```

Run:
```bash
flutter pub get
```

---

## Quick Start

### Step 1 — Wrap your app

Place `MerkadoWalletScope` **inside** `ScreenUtilInit`'s builder so that `ScreenUtil` is initialized before any wallet screen is built:

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:merkado_wallet/merkado_wallet.dart';

class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MerkadoWalletScope(
        config: MerkadoWalletConfig(
          platformId: '019c761c-d25e-7257-b5ec-8af95ddd202c',
          baseUrl: 'https://wallet-api.merkado.site',
          primaryColor: const Color(0xFF1A3C34),
          features: WalletFeatures(
            addMoney: true,
            withdraw: true,
            pinLock: true,
            fundingRedirectUrl: 'https://mycut.app/wallet/fund/callback',
            exploreActions: [
              WalletExploreAction(
                label: 'Create deal',
                icon: Icons.handshake_outlined,
                onTap: () => context.push('/deals/create'),
              ),
            ],
          ),
          onNotification: (event) {
            CommonNotificationService.instance.show(
              title: event.title,
              body: event.body,
              channelId: event.channelId,
            );
          },
        ),
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
  }
}
```

### Step 2 — Connect auth token

Call `setAccessToken` immediately after `merkado_auth` returns a successful session:

```dart
// In your auth listener (wherever you handle merkado_auth callbacks):
MerkadoAuth.instance.authStream.listen((result) {
  if (result is AuthSuccess) {
    // Token is held in-memory only — never written to disk by the wallet package
    MerkadoWalletScope.of(context).setAccessToken(result.accessToken);
    // Pre-load balance so it's ready when user opens the wallet tab
    MerkadoWalletScope.of(context).refreshBalance();
  }
  if (result is AuthLoggedOut) {
    MerkadoWalletScope.of(context).clearSession();
  }
});
```

### Step 3 — Open the wallet

```dart
// From a bottom nav bar tab:
NavigationBarItem(
  icon: const Icon(Icons.account_balance_wallet_outlined),
  label: 'Wallet',
  onTap: () => MerkadoWalletScope.of(context).pushWallet(context),
)

// Or navigate programmatically:
MerkadoWalletScope.of(context).pushWallet(context);
```

---

## Configuration Reference

### `MerkadoWalletConfig`

| Property | Type | Required | Description |
|---|---|---|---|
| `platformId` | `String` | ✅ | Platform UUID from Merkado OS (same as merkado_auth) |
| `baseUrl` | `String` | ✅ | Wallet API base URL |
| `primaryColor` | `Color?` | — | Brand color for buttons, indicators, active states |
| `features` | `WalletFeatures` | — | Feature flags (see below) |
| `customScreens` | `CustomWalletScreens?` | — | Screen builder overrides |
| `onNotification` | `void Function(WalletNotificationEvent)?` | — | Notification bridge callback |
| `onWalletEvent` | `void Function(WalletEvent)?` | — | Alternative to subscribing to `walletStream` |
| `currency` | `WalletCurrencyConfig` | — | Currency code, symbol, locale (default: NGN / ₦) |
| `enableLogging` | `bool` | — | Verbose request/response logs (default: false) |

### `WalletFeatures`

| Property | Type | Default | Description |
|---|---|---|---|
| `addMoney` | `bool` | `true` | Show "Add Money" button and flow |
| `demoMode` | `bool` | `false` | Use demo endpoints — no real payments |
| `withdraw` | `bool` | `true` | Show "Withdraw" button and flow |
| `withdrawalHistory` | `bool` | `true` | Show full history screen |
| `recentActivityPreview` | `bool` | `true` | Show recent withdrawals on home |
| `recentActivityCount` | `int` | `5` | Number of items in the preview |
| `balanceVisibilityToggle` | `bool` | `true` | Eye icon to hide/show balance |
| `pinLock` | `bool` | `true` | Require PIN before withdrawals |
| `biometricUnlock` | `bool` | `false` | Allow biometric as PIN alternative |
| `fundingRedirectUrl` | `String?` | — | Callback URL for payment gateway redirect |
| `exploreActions` | `List<WalletExploreAction>` | `[]` | Product-scoped action buttons (empty = hidden) |
| `supportedWithdrawalCurrencies` | `List<String>` | `['NGN']` | Currencies to show tabs for in add-bank-account |

### `WalletExploreAction`

```dart
WalletExploreAction(
  label: 'Create deal',           // Pill button label
  icon: Icons.handshake_outlined, // Leading icon
  onTap: () => ...,               // Action
  badge: 3,                       // Optional count badge (null = hidden)
)
```

---

## API Endpoints

All 14 endpoints are fully implemented with proper error extraction, status code checking, and type-safe response models.

### Wallet

| Method | Endpoint | Datasource Method | Response Model |
|---|---|---|---|
| `GET` | `/v1/wallet` | `getWallet()` | `Wallet` |
| `POST` | `/v1/wallet/fund` | `fundWallet(amount, redirectUrl)` | `FundWalletResponse` |
| `POST` | `/v1/wallet/demo/fund` | `demoFundWallet(amount, reference?)` | `DemoFundResponse` |
| `POST` | `/v1/wallet/demo/withdraw` | `demoWithdrawWallet(amount)` | `DemoWithdrawResponse` |

### Withdrawal & Bank Accounts

| Method | Endpoint | Datasource Method | Response Model |
|---|---|---|---|
| `GET` | `/v1/withdrawal/banks?currency=NGN` | `getSupportedBanks(currency)` | `List<SupportedBank>` |
| `GET` | `/v1/withdrawal/bank-accounts` | `getBankAccounts()` | `List<BankAccount>` |
| `POST` | `/v1/withdrawal/bank-account` | `addBankAccountGeneric(data)` | `BankAccount` |
| `POST` | `/v1/withdrawal/bank-account/ngn` | `addNgnBankAccount(data)` | `BankAccount` |
| `POST` | `/v1/withdrawal/bank-account/gbp` | `addGbpBankAccount(data)` | `BankAccount` |
| `POST` | `/v1/withdrawal/bank-account/eur` | `addEurBankAccount(data)` | `BankAccount` |
| `POST` | `/v1/withdrawal/bank-account/usd` | `addUsdBankAccount(data)` | `BankAccount` |
| `DELETE` | `/v1/withdrawal/bank-account/{id}` | `deleteBankAccount(id)` | `void` |
| `GET` | `/v1/withdrawal/history` | `getWithdrawalHistory()` | `List<WithdrawalRecord>` |
| `POST` | `/v1/withdrawal/request` | `requestWithdrawal(bankAccountId, amount)` | `WithdrawalRecord` |

### Balance Fields

The backend returns three distinct balance values — all come as strings and are parsed to `double` by the `Wallet` model:

| Field | Description |
|---|---|
| `availableBalance` | Funds the user can spend right now |
| `ledgerBalance` | Total (available + escrowed) |
| `withdrawableBalance` | Subset of available that can be cashed out |
| `escrowedBalance` | Derived: `ledger - available` (computed on client) |

---

## Nigerian Bank List — Public API

For NGN bank accounts, the package uses **Paystack's free public API** — no API key required:

```
GET https://api.paystack.co/bank?country=nigeria&currency=NGN&perPage=200
```

This is handled by `NigerianBankService` (in `lib/src/services/banks/`):

- Returns 200+ Nigerian banks including fintechs: Kuda, OPay, PalmPay, Moniepoint, VFD
- Results are cached in-memory for 6 hours per session
- On network failure or parsing error, falls back to 28 hardcoded major banks so the add-account form always works offline
- Used automatically in `WithdrawalRepositoryImpl.getSupportedBanks()` for NGN currency
- For GBP, EUR, USD: falls through to the wallet API's own bank endpoint

```dart
// You can also use it directly from anywhere in your app:
final banks = await NigerianBankService.instance.getBanks();
final gtb = await NigerianBankService.instance.findByCode('058');
```

---

## Token Lifecycle

The wallet package **never stores the access token to disk**. It holds it in-memory in `WalletHttpClient` only.

```
merkado_auth AuthSuccess
  │
  └─► MerkadoWalletScope.of(context).setAccessToken(token)
          │
          └─► WalletHttpClient.instance.setToken(token)  ← in-memory only
                  │
                  └─► WalletAuthInterceptor attaches to every request
                            │
                            └─► 401 response
                                  │
                                  └─► WalletEventBus.emit(WalletSessionExpired)
                                            │
                                            └─► app listener → merkado_auth re-auth
```

On logout:
```dart
MerkadoWalletScope.of(context).clearSession();
// → WalletHttpClient.clearToken()
// → WalletEventBus.emit(WalletSessionCleared)
```

Public endpoints (`/v1/withdrawal/banks`) are exempt from the auth interceptor and work without a token.

---

## State Management Integration

`WalletEventBus` is a broadcast stream — use it with any state management approach.

### Riverpod

```dart
final walletEventProvider = StreamProvider<WalletEvent>((ref) {
  final context = ref.read(contextProvider);
  return MerkadoWalletScope.of(context).walletStream;
});

// In a widget:
ref.listen<AsyncValue<WalletEvent>>(walletEventProvider, (_, next) {
  next.whenData((event) {
    if (event is WalletFunded) {
      showToast('₦${event.amount} added to your wallet!');
    }
  });
});

// Balance as a derived provider:
final walletBalanceProvider = Provider<double?>((ref) {
  final event = ref.watch(walletEventProvider).valueOrNull;
  return event is WalletLoaded ? event.availableBalance : null;
});
```

### BLoC

```dart
class AppBloc extends Bloc<AppEvent, AppState> {
  StreamSubscription? _walletSub;

  void connectWallet(BuildContext context) {
    _walletSub = MerkadoWalletScope.of(context).walletStream.listen((event) {
      switch (event) {
        case WalletLoaded(:final availableBalance):
          add(AppWalletBalanceUpdated(availableBalance));
        case WalletSessionExpired():
          add(AppSessionExpired());
        default:
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _walletSub?.cancel();
    return super.close();
  }
}
```

### GetX

```dart
class WalletController extends GetxController {
  final balance = 0.0.obs;
  final isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    MerkadoWalletScope.of(Get.context!).walletStream.listen((event) {
      if (event is WalletLoaded) {
        balance.value = event.availableBalance;
        isLoaded.value = true;
      }
    });
  }
}
```

### Plain setState

```dart
class _HomeState extends State<HomeScreen> {
  double _balance = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = MerkadoWalletScope.of(context).walletStream.listen((event) {
      if (event is WalletLoaded && mounted) {
        setState(() => _balance = event.availableBalance);
      }
    });
    MerkadoWalletScope.of(context).refreshBalance();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
```

---

## Notification Bridge

The `onNotification` callback is called with a typed `WalletNotificationEvent` for every notification-worthy action. Wire it into whatever notification plugin your app uses.

```dart
MerkadoWalletConfig(
  onNotification: (event) {
    // Route by channel for Android channel grouping
    switch (event.channelId) {
      case 'wallet_credit':
      case 'wallet_debit':
      case 'wallet_system':
        CommonNotificationService.instance.show(
          title: event.title,
          body: event.body,
          channelId: event.channelId,
          data: event.payload,
        );
    }
  },
)
```

### Notification Types

| Type | Channel | Trigger |
|---|---|---|
| `fundInitiated` | `wallet_system` | Payment checkout URL ready |
| `fundSuccess` | `wallet_credit` | Demo fund or webhook confirmation |
| `withdrawalRequested` | `wallet_debit` | Withdrawal submitted |
| `withdrawalFailed` | `wallet_system` | Withdrawal rejected by gateway |
| `pinLocked` | `wallet_system` | Too many failed PIN attempts |
| `bankAccountAdded` | `wallet_system` | New bank account saved |
| `sessionExpired` | `wallet_system` | 401 received, re-auth needed |

All events carry a `deepLinkRoute` string (e.g. `/wallet/history`) that you can pass to your navigation handler.

---

## Explore Deals Section

The "Explore Deals" pill row is a first-class injection point. Each app defines its own actions — they are never hardcoded in the package.

```dart
// MyCut
exploreActions: [
  WalletExploreAction(label: 'Create deal', icon: Icons.handshake_outlined, onTap: ...),
  WalletExploreAction(label: 'Invite members', icon: Icons.group_add_outlined, onTap: ..., badge: pendingCount),
  WalletExploreAction(label: 'Refer & earn', icon: Icons.monetization_on_outlined, onTap: ...),
],

// Driply
exploreActions: [
  WalletExploreAction(label: 'Live shopping', icon: Icons.live_tv_outlined, onTap: ...),
  WalletExploreAction(label: 'Invite friends', icon: Icons.person_add_outlined, onTap: ...),
],

// FeastFeed
exploreActions: [
  WalletExploreAction(label: 'Create order', icon: Icons.restaurant_menu, onTap: ...),
  WalletExploreAction(label: 'Find vendors', icon: Icons.storefront_outlined, onTap: ...),
],

// Hide section entirely (e.g. enterprise app with no deals)
exploreActions: [],
```

---

## Custom Screens

You can replace any screen with your own UI. The package continues to manage all data fetching, cubits, and API calls — your builder just receives the relevant cubit.

```dart
MerkadoWalletConfig(
  customScreens: CustomWalletScreens(
    // Replace the wallet home screen entirely
    homeScreenBuilder: (context, walletCubit) {
      return MyBrandedWalletHome(cubit: walletCubit);
    },

    // Replace just the PIN verification screen
    pinVerifyScreenBuilder: (context, pinCubit, onVerified) {
      return MyBiometricPinScreen(
        cubit: pinCubit,
        onVerified: onVerified,
      );
    },

    // Replace the "Add Money" screen (e.g. custom payment methods)
    addMoneyScreenBuilder: (context, walletCubit) {
      return MyAddMoneyScreen(cubit: walletCubit);
    },
  ),
)
```

### Customizable screens

| Builder | Receives | Use case |
|---|---|---|
| `homeScreenBuilder` | `walletCubit` | Full home replacement |
| `addMoneyScreenBuilder` | `walletCubit` | Custom payment UI |
| `withdrawScreenBuilder` | `withdrawalCubit` | Custom withdrawal UI |
| `historyScreenBuilder` | `List<WithdrawalRecord>` | Custom history layout |
| `bankAccountsScreenBuilder` | `accounts, withdrawalCubit` | Custom bank list |
| `addBankAccountScreenBuilder` | `withdrawalCubit, currency` | Custom add-bank form |
| `pinSetupScreenBuilder` | `pinCubit` | Custom PIN setup UI |
| `pinVerifyScreenBuilder` | `pinCubit, onVerified` | Custom PIN / biometric UI |

---

## PIN Security

The PIN system is designed with zero plaintext exposure:

```
User enters PIN (4 or 6 digits)
  │
  └─► PinService.hashPin(pin, userId)
          │
          └─► SHA-256("${pin}:${userId}:merkado_wallet_pin_v1")
                  │
                  └─► hash sent to backend in withdrawal request body
                            (raw PIN never leaves the device, never logged)
```

**Brute-force protection:**

| Attempt | Result |
|---|---|
| 1–4 failed | Shows remaining attempts |
| 5th failed | 30-minute lockout begins |
| During lockout | Countdown timer shown, no attempts accepted |
| After lockout | Attempt count resets automatically |

Lockout state is persisted in `flutter_secure_storage` and survives app restarts. On successful verification, attempts are reset immediately.

To enable biometric as a fallback, set `biometricUnlock: true` in `WalletFeatures`. The `PinEntrySheet` will show a biometric prompt alongside the keypad.

---

## Demo Mode

Demo mode bypasses the payment gateway entirely. Useful for development, staging, and investor demos.

```dart
WalletFeatures(
  demoMode: true,
  addMoney: true,
  withdraw: true,
)
```

In demo mode:
- "Add Money" calls `POST /v1/wallet/demo/fund` → instant credit, no checkout URL
- All balance values update immediately in the UI
- A visible orange banner in the Add Money screen communicates demo status to the user
- Demo withdrawals call `POST /v1/wallet/demo/withdraw`

To toggle at runtime (e.g. based on a build flavor):

```dart
WalletFeatures(
  demoMode: const String.fromEnvironment('FLAVOR') == 'staging',
)
```

---

## Multi-Currency Withdrawals

The `AddBankAccountScreen` renders a tabbed form per currency. Enable currencies by listing them in `supportedWithdrawalCurrencies`:

```dart
WalletFeatures(
  supportedWithdrawalCurrencies: ['NGN', 'GBP', 'EUR', 'USD'],
)
```

Each currency maps to its own validated form and dedicated endpoint:

| Currency | Endpoint | Key fields |
|---|---|---|
| NGN | `/v1/withdrawal/bank-account/ngn` | Bank code (from Paystack list), 10-digit account number |
| GBP | `/v1/withdrawal/bank-account/gbp` | Sort code, account number, optional SWIFT/BIC |
| EUR | `/v1/withdrawal/bank-account/eur` | IBAN, SEPA country code |
| USD | `/v1/withdrawal/bank-account/usd` | Account number, SWIFT/BIC, routing code, addresses |

If only `['NGN']` is specified (the default), no tabs are shown — just the NGN form directly.

---

## Event Reference

All events emitted on `WalletEventBus`:

```dart
sealed class WalletEvent {}

WalletLoading()                         // Any async op started
WalletLoaded(walletId, availableBalance, ledgerBalance, withdrawableBalance, currency)
WalletFundInitiated(checkoutUrl, reference, provider, amount)
WalletFunded(amount, newAvailableBalance)
WalletWithdrawalRequested(amount, currency, bankName, status)
WalletBankAccountAdded(bankName, accountNumber, currency)
WalletBankAccountRemoved(bankAccountId)
WalletPinSet()
WalletPinVerified()
WalletPinFailed(attemptsLeft)
WalletPinLocked(unlocksAt)
WalletSessionExpired()                  // 401 received — re-auth needed
WalletSessionCleared()                  // Logout
WalletError(message)
```

---

## Why Not Initialize in `main()`

Other packages in the Grascope ecosystem (e.g. `merkado_auth`) initialize in `main()` before `runApp()`. This works for auth but breaks `flutter_screenutil` because `ScreenUtil` hasn't been initialized yet — any `.w`, `.h`, or `.sp` call will throw or return 0.

`merkado_wallet` solves this with `MerkadoWalletScope`, an `InheritedWidget` placed inside `ScreenUtilInit`'s builder. Initialization happens **after** `ScreenUtil.init()` has been called, so every wallet screen and widget uses responsive sizing correctly, with no workarounds.

---

## Per-Product Examples

### MyCut

```dart
MerkadoWalletConfig(
  platformId: MerkadoPlatform.mycut,
  baseUrl: 'https://wallet-api.merkado.site',
  primaryColor: const Color(0xFF1A3C34),
  currency: const WalletCurrencyConfig(code: 'NGN', symbol: '₦'),
  features: WalletFeatures(
    addMoney: true,
    withdraw: true,
    pinLock: true,
    fundingRedirectUrl: 'https://mycut.app/wallet/fund/callback',
    supportedWithdrawalCurrencies: ['NGN'],
    exploreActions: [
      WalletExploreAction(label: 'Create deal', icon: Icons.handshake_outlined, onTap: ...),
      WalletExploreAction(label: 'Invite members', icon: Icons.group_add_outlined, onTap: ..., badge: ref.watch(pendingInviteCountProvider)),
      WalletExploreAction(label: 'Refer & earn', icon: Icons.monetization_on_outlined, onTap: ...),
    ],
  ),
)
```

### Driply

```dart
MerkadoWalletConfig(
  platformId: MerkadoPlatform.driply,
  baseUrl: 'https://wallet-api.merkado.site',
  primaryColor: const Color(0xFFE91E8C),
  features: WalletFeatures(
    addMoney: true,
    withdraw: true,
    pinLock: true,
    exploreActions: [
      WalletExploreAction(label: 'Live shopping', icon: Icons.live_tv_outlined, onTap: ...),
      WalletExploreAction(label: 'Flash sale', icon: Icons.bolt_outlined, onTap: ...),
    ],
  ),
)
```

### Staging / Dev

```dart
MerkadoWalletConfig(
  platformId: 'dev-platform-id',
  baseUrl: 'https://wallet-api.merkado.site',
  features: WalletFeatures(
    demoMode: true,      // instant fund/withdraw, no gateway
    addMoney: true,
    withdraw: true,
    pinLock: false,      // skip PIN in dev
  ),
  enableLogging: true,
)
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | `WalletCubit`, `WithdrawalCubit`, `PinCubit` |
| `freezed_annotation` | Sealed state classes |
| `dio` | HTTP client with interceptor support |
| `flutter_secure_storage` | PIN state, balance visibility, wallet ID cache |
| `flutter_screenutil` | Responsive sizing across all wallet screens |
| `local_auth` | Biometric PIN fallback (optional, toggled by config) |
| `crypto` | SHA-256 PIN hashing |
| `intl` | Currency formatting, date display |
| `json_annotation` | JSON serialization for API models |
| `get_it` + `injectable` | Dependency injection (available for custom extension) |
| `uuid` | Reference ID generation |
| `equatable` | Value equality on models |

Run code generation after any model changes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```