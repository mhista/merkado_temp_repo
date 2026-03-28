import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/kyc_entities.dart';
import '../../domain/repositories/kyc_repository.dart';

class KycRepositoryImpl implements KycRepository {
  final DioClient dioClient;

  KycRepositoryImpl(this.dioClient);

  @override
  void setSecretToken(String token) {
    dioClient.setSecretToken(token);
  }

  String _userFullName = '';

  @override
  void setUserFullName(String userFullName) {
    _userFullName = userFullName;
    dioClient.setUserFullName(userFullName);
  }

  List<KycTier> _tiers = [
    const KycTier(
      id: 1,
      title: 'Tier 1\nBasic Info',
      description: 'Your NIN and date of birth',
      tags: ['📱 Phone number', '🧑‍🤝‍🧑 Gender', '🪪 NIN'],
      unlockLimit: 'Up to ₦500,000',
      status: TierStatus.startHere,
    ),
    const KycTier(
      id: 2,
      title: 'Tier 2\nEnhanced KYC',
      description: 'BVN and date of birth',
      tags: ['🏦 BVN number', '🤳 Selfie photo'],
      unlockLimit: 'Up to ₦5,000,000',
      status: TierStatus.locked,
    ),
    const KycTier(
      id: 3,
      title: 'Tier 3\nIdentity Verified',
      description: 'Where you currently live',
      tags: ['🔌 Utility type', '🔌 Utility type', '🔢 Meter number'],
      unlockLimit: 'Unlimited',
      status: TierStatus.locked,
    ),
  ];

  @override
  Future<Either<Failure, KycStateData>> getKycStatus() async {
    try {
      final response = await dioClient.get('/v1/kyc/status');
      final data = response.data;

      // Map API response to local tiers
      // Logic: If tier X is completed, unlock next tier.
      // Expected API structure (example based on doc):
      // { "tier1": "approved", "tier2": "pending", "tier3": "none" }

      _tiers = _tiers.map((tier) {
        String statusStr = 'none';
        if (tier.id == 1) statusStr = data['tier1'] ?? 'none';
        if (tier.id == 2) statusStr = data['tier2'] ?? 'none';
        if (tier.id == 3) statusStr = data['tier3'] ?? 'none';

        TierStatus status;
        switch (statusStr) {
          case 'approved':
          case 'completed':
            status = TierStatus.completed;
            break;
          case 'pending':
          case 'in_progress':
            status = TierStatus.inProgress;
            break;
          case 'none':
            // Check if previous tier is completed to unlock
            bool prevCompleted = true;
            if (tier.id > 1) {
              final prevStatus = _getTierStatusFromData(data, tier.id - 1);
              prevCompleted =
                  (prevStatus == 'approved' || prevStatus == 'completed');
            }
            status = prevCompleted ? TierStatus.startHere : TierStatus.locked;
            break;
          default:
            status = TierStatus.locked;
        }

        return KycTier(
          id: tier.id,
          title: tier.title,
          description: tier.description,
          tags: tier.tags,
          unlockLimit: tier.unlockLimit,
          status: status,
        );
      }).toList();

      return Right(
        KycStateData(
          tiers: _tiers,
          isFullyVerified: _tiers.every(
            (t) => t.status == TierStatus.completed,
          ),
          userFullName: _userFullName,
        ),
      );
    } catch (e) {
      // Fallback to local state if server fails or returns error
      return Right(
        KycStateData(
          tiers: _tiers,
          isFullyVerified: _tiers.every(
            (t) => t.status == TierStatus.completed,
          ),
          userFullName: _userFullName,
        ),
      );
    }
  }

  String _getTierStatusFromData(dynamic data, int tierId) {
    if (tierId == 1) return data['tier1'] ?? 'none';
    if (tierId == 2) return data['tier2'] ?? 'none';
    if (tierId == 3) return data['tier3'] ?? 'none';
    return 'none';
  }

  @override
  Future<Either<Failure, bool>> submitTier1BasicInfo({
    required String dob,
    required String nin,
    required String gender,
  }) async {
    try {
      await dioClient.post(
        '/v1/kyc/tier-1',
        data: {
          'nin': nin,
          'dob': dob,
          'gender': gender.startsWith('M') ? 'M' : 'F',
        },
      );
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> submitTier2EnhancedKyc({
    required String bvn,
    required String selfiePath,
  }) async {
    try {
      final File file = File(selfiePath);
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      await dioClient.post(
        '/v1/kyc/tier-2',
        data: {'bvn': bvn, 'selfieBase64': base64Image},
      );
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> submitTier3AddressVerification({
    required String address,
    required String provider,
    required String type,
    required String accountNo,
    required String meterNo,
  }) async {
    try {
      await dioClient.post(
        '/v1/kyc/tier-3',
        data: {
          'address': address,
          'meterNumber': meterNo.isNotEmpty ? meterNo : accountNo,
          'utilityProvider': provider,
          'utilityType': type,
        },
      );
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
