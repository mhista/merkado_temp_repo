import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kyc_repository.dart';

class SubmitTier1UseCase {
  final KycRepository repository;

  SubmitTier1UseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String dob,
    required String nin,
    required String gender,
  }) async {
    return await repository.submitTier1BasicInfo(
      dob: dob,
      nin: nin,
      gender: gender,
    );
  }
}
