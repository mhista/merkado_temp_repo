# merkados_kyc

A comprehensive, multi-tier KYC verification package for Flutter. It streamlines the user verification process by providing a ready-to-use, customizable flow that covers basic identity verification, biometric capture, and address validation.

## Features

- **Tier 1 (Basic Info)**: Date of Birth, NIN, and Gender verification.
- **Tier 2 (Enhanced KYC)**: BVN and Profile/Selfie biometric capture (with automatic Base64 conversion).
- **Tier 3 (Identity Verified)**: Address and Utility Bill verification.
- **Sequential Flow**: Built-in logic ensures that tiers are completed in order and locked once verified.
- **Customizable UI**: High-fidelity, premium design that adapts to your theme.

## Benefits

- **Fully Integrated**: Pre-configured to work with the Merkado KYC API (`https://kyc-api.merkado.site/v1`).
- **Personalized Experience**: Automatically propagates the `userFullName` to the success screen for a professional feel.
- **Highly Secure**: Built-in support for Bearer token authentication via interceptors.
- **Effortless Implementation**: Just drop the `KycFlow` widget into your app.

## Getting started

Add `merkados_kyc` to your `pubspec.yaml`:

```yaml
dependencies:
  merkados_kyc:
    path: ../path_to_package
```

## Usage

To use the package, you need to provide a `secretToken` (for API authentication) and the `userFullName` (to personalize the UI). You can optionally provide your own `Dio` instance if you have custom interceptors or global configurations.

```dart
import 'package:merkados_kyc/merkados_kyc.dart';
import 'package:dio/dio.dart';

// ... inside your widget build method
KycFlow(
  secretToken: 'YOUR_AUTHORIZATION_BEARER_TOKEN',
  userFullName: 'John Doe',
  dio: Dio(), // Optional: share your existing Dio instance
)
```

### Why provide `userFullName`?
The `userFullName` is used to personalize the KYC success screen. It dynamically generates user initials and displays the full name alongside a "Verified" badge once the process is complete.

### Why provide `Dio`?
While the package creates its own `Dio` instance by default, providing your own allows you to share global configurations, logging interceptors, or proxy settings used across your main application.

## Additional information

For more information, visit the [Merkado Documentation](https://kyc-api.merkado.site/v1/docs).
