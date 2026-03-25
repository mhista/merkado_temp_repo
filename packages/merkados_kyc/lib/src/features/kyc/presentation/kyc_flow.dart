import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../data/repositories/kyc_repository_impl.dart';
import '../domain/repositories/kyc_repository.dart';
import '../domain/usecases/get_kyc_status.dart';
import '../domain/usecases/submit_tier_1_usecase.dart';
import '../domain/usecases/submit_tier_2_usecase.dart';
import '../domain/usecases/submit_tier_3_usecase.dart';
import 'bloc/kyc_bloc.dart';
import 'pages/kyc_overview_page.dart';
import 'pages/tier1_basic_info_page.dart';
import 'pages/tier2_enhanced_kyc_page.dart';
import 'pages/tier3_address_verification_page.dart';
import 'pages/kyc_success_page.dart';

class KycFlow extends StatefulWidget {
  final Dio? dio;
  final String? secretToken;
  final String? userFullName;

  const KycFlow({super.key, this.dio, this.secretToken, this.userFullName});

  @override
  State<KycFlow> createState() => _KycFlowState();
}

class _KycFlowState extends State<KycFlow> {
  late final KycRepository repository;
  late final GetKycStatus getKycStatus;
  late final SubmitTier1UseCase submitTier1;
  late final SubmitTier2UseCase submitTier2;
  late final SubmitTier3UseCase submitTier3;

  @override
  void initState() {
    super.initState();
    repository = KycRepositoryImpl(DioClient(widget.dio ?? Dio()));
    if (widget.secretToken != null) {
      repository.setSecretToken(widget.secretToken!);
    }
    if (widget.userFullName != null) {
      repository.setUserFullName(widget.userFullName!);
    }
    getKycStatus = GetKycStatus(repository);
    submitTier1 = SubmitTier1UseCase(repository);
    submitTier2 = SubmitTier2UseCase(repository);
    submitTier3 = SubmitTier3UseCase(repository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KycBloc(
        getKycStatus: getKycStatus,
        submitTier1: submitTier1,
        submitTier2: submitTier2,
        submitTier3: submitTier3,
      )..add(FetchKycStatus()),
      child: Navigator(
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/':
              page = const KycOverviewPage();
              break;
            case '/tier1':
              page = const Tier1BasicInfoPage();
              break;
            case '/tier2':
              page = const Tier2EnhancedKycPage();
              break;
            case '/tier3':
              page = const Tier3AddressVerificationPage();
              break;
            case '/success':
              page = const KycSuccessPage();
              break;
            default:
              page = const KycOverviewPage();
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
    );
  }
}
