import 'package:equatable/equatable.dart';

enum TierStatus { locked, startHere, completed, inProgress }

class KycTier extends Equatable {
  final int id;
  final String title;
  final String description;
  final Iterable<String> tags;
  final String unlockLimit;
  final TierStatus status;

  const KycTier({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.unlockLimit,
    required this.status,
  });

  @override
  List<Object?> get props => [id, title, description, tags, unlockLimit, status];
}

class KycStateData extends Equatable {
  final List<KycTier> tiers;
  final bool isFullyVerified;
  final String userFullName;

  const KycStateData({
    required this.tiers,
    this.isFullyVerified = false,
    this.userFullName = '',
  });

  @override
  List<Object?> get props => [tiers, isFullyVerified, userFullName];
}
