import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kyc_repository.dart';

class SubmitTier2UseCase {
  final KycRepository repository;

  SubmitTier2UseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String bvn,
    required String selfiePath,
  }) async {
    return await repository.submitTier2EnhancedKyc(
      bvn: bvn,
      selfiePath: selfiePath,
    );
  }
}
