import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/kyc_entities.dart';
import '../../domain/usecases/get_kyc_status.dart';
import '../../domain/usecases/submit_tier_1_usecase.dart';
import '../../domain/usecases/submit_tier_2_usecase.dart';
import '../../domain/usecases/submit_tier_3_usecase.dart';

// Events
abstract class KycEvent extends Equatable {
  const KycEvent();
  @override
  List<Object?> get props => [];
}

class FetchKycStatus extends KycEvent {}

class SubmitTier1 extends KycEvent {
  final String dob, nin, gender;
  const SubmitTier1(this.dob, this.nin, this.gender);
}

class SubmitTier2 extends KycEvent {
  final String bvn, selfiePath;
  const SubmitTier2(this.bvn, this.selfiePath);
}

class SubmitTier3 extends KycEvent {
  final String address, provider, type, accountNo, meterNo;
  const SubmitTier3(this.address, this.provider, this.type, this.accountNo, this.meterNo);
}

// States
abstract class KycState extends Equatable {
  const KycState();
  @override
  List<Object?> get props => [];
}

class KycInitial extends KycState {}
class KycLoading extends KycState {}
class KycLoaded extends KycState {
  final KycStateData data;
  const KycLoaded(this.data);
  @override
  List<Object?> get props => [data];
}
class KycError extends KycState {
  final String message;
  const KycError(this.message);
  @override
  List<Object?> get props => [message];
}
class KycTierSubmitSuccess extends KycState {
  final int tierId;
  const KycTierSubmitSuccess(this.tierId);
}

// BLoC
class KycBloc extends Bloc<KycEvent, KycState> {
  final GetKycStatus getKycStatus;
  final SubmitTier1UseCase submitTier1;
  final SubmitTier2UseCase submitTier2;
  final SubmitTier3UseCase submitTier3;

  KycBloc({
    required this.getKycStatus,
    required this.submitTier1,
    required this.submitTier2,
    required this.submitTier3,
  }) : super(KycInitial()) {
    on<FetchKycStatus>(_onFetchKycStatus);
    on<SubmitTier1>(_onSubmitTier1);
    on<SubmitTier2>(_onSubmitTier2);
    on<SubmitTier3>(_onSubmitTier3);
  }

  Future<void> _onFetchKycStatus(FetchKycStatus event, Emitter<KycState> emit) async {
    emit(KycLoading());
    final result = await getKycStatus();
    result.fold(
      (failure) => emit(KycError(failure.message)),
      (data) => emit(KycLoaded(data)),
    );
  }

  Future<void> _onSubmitTier1(SubmitTier1 event, Emitter<KycState> emit) async {
    emit(KycLoading());
    final result = await submitTier1(
      dob: event.dob,
      nin: event.nin,
      gender: event.gender,
    );
    result.fold(
      (failure) => emit(KycError(failure.message)),
      (_) {
        emit(const KycTierSubmitSuccess(1));
        add(FetchKycStatus());
      },
    );
  }

  Future<void> _onSubmitTier2(SubmitTier2 event, Emitter<KycState> emit) async {
    emit(KycLoading());
    final result = await submitTier2(
      bvn: event.bvn,
      selfiePath: event.selfiePath,
    );
    result.fold(
      (failure) => emit(KycError(failure.message)),
      (_) {
        emit(const KycTierSubmitSuccess(2));
        add(FetchKycStatus());
      },
    );
  }

  Future<void> _onSubmitTier3(SubmitTier3 event, Emitter<KycState> emit) async {
    emit(KycLoading());
    final result = await submitTier3(
      address: event.address,
      provider: event.provider,
      type: event.type,
      accountNo: event.accountNo,
      meterNo: event.meterNo,
    );
    result.fold(
      (failure) => emit(KycError(failure.message)),
      (_) {
        emit(const KycTierSubmitSuccess(3));
        add(FetchKycStatus());
      },
    );
  }
}
