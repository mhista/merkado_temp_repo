import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entities.dart';

abstract class KycRepository {
  void setSecretToken(String token);
  void setUserFullName(String userFullName);
  Future<Either<Failure, KycStateData>> getKycStatus();
  Future<Either<Failure, bool>> submitTier1BasicInfo({
    required String dob,
    required String nin,
    required String gender,
  });
  Future<Either<Failure, bool>> submitTier2EnhancedKyc({
    required String bvn,
    required String selfiePath,
  });
  Future<Either<Failure, bool>> submitTier3AddressVerification({
    required String address,
    required String provider,
    required String type,
    required String accountNo,
    required String meterNo,
  });
}
