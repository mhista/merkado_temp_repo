import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entities.dart';
import '../repositories/kyc_repository.dart';

class GetKycStatus {
  final KycRepository repository;

  GetKycStatus(this.repository);

  Future<Either<Failure, KycStateData>> call() async {
    return await repository.getKycStatus();
  }
}
