import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kyc_repository.dart';

class SubmitTier3UseCase {
  final KycRepository repository;

  SubmitTier3UseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String address,
    required String provider,
    required String type,
    required String accountNo,
    required String meterNo,
  }) async {
    return await repository.submitTier3AddressVerification(
      address: address,
      provider: provider,
      type: type,
      accountNo: accountNo,
      meterNo: meterNo,
    );
  }
}
