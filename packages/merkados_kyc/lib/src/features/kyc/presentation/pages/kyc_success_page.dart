import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/kyc_bloc.dart';
import '../widgets/success_app_bar.dart';
import '../widgets/success_limit_card.dart';
import '../widgets/success_profile_snipet.dart';
import '../widgets/success_verification_bar.dart';
import '../widgets/success_what_next.dart';

// Defining the custom color palette from the image
const Color darkGreen = Color(0xFF1B2B1B); // Deep forest green
const Color goldAccent = Color(0xFFC5A368); // Muted gold/bronze
const Color softGold = Color(0xFFE5D1B2);

class KycSuccessPage extends StatelessWidget {
  const KycSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<KycBloc, KycState>(
        builder: (context, state) {
          String fullName = '';
          if (state is KycLoaded) {
            fullName = state.data.userFullName;
          }

          return SingleChildScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            // padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SuccessAppBar(),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    spacing: AppSpacing.lg,
                    children: [
                      const SuccessLimitCard(),
                      // const SizedBox(height: AppSpacing.lg),
                      SuccessProfileSnippet(userFullName: fullName),
                      SuccessVerificationBar(),
                      // const SizedBox(height: AppSpacing.lg),
                      // _buildWhatNext(context),
                      SuccessWhatNext(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
