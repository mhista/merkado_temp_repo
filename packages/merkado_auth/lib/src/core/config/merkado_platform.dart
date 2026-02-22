/// MerkadoPlatform
/// ================
/// Defines all registered Grascope platform identifiers.
///
/// Each product that runs on Merkado OS has a unique UUID that is
/// sent with every auth request so the Identity Service can:
///   - Issue product-scoped access tokens
///   - Track session origins for security
///   - Apply platform-specific onboarding flows
///
/// ADDING A NEW PLATFORM:
/// Add a new static const here and register the UUID with the backend team.
class MerkadoPlatform {
  MerkadoPlatform._();

  /// MyCut — Deals & Multi-party Transactions
  static const String mycut = '019c761c-d25e-7257-b5ec-8af95ddd202c';

  /// Driply — Fashion & Beauty Social Commerce
  static const String driply = '019c761c-d265-7a25-a095-ec995157cb32';

  /// Haulway — Custom Tailoring Services
  static const String haulway = '019c761c-d265-7a25-a095-ec9a7262b4fa';

  /// FeastFeed — Food Vendors & Creators
  static const String feastFeed = '019c761c-d265-7a25-a095-ec9bfcd940d6';

  /// ItsYourDay — Event Planning & Coordination
  static const String itsYourDay = '019c761c-d265-7a25-a095-ec9c5ad364f5';

  /// Returns the human-readable name for a given platform ID.
  /// Used in logging and error messages.
  static String nameOf(String platformId) {
    return _names[platformId] ?? 'Unknown Platform';
  }

  static const Map<String, String> _names = {
    mycut: 'MyCut',
    driply: 'Driply',
    haulway: 'Haulway',
    feastFeed: 'FeastFeed',
    itsYourDay: 'ItsYourDay',
  };
}