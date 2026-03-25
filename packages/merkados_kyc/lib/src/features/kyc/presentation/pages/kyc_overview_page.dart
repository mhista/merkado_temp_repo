import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/kyc_page_banner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/kyc_page_title_model.dart';
import '../../domain/entities/kyc_entities.dart';
import '../bloc/kyc_bloc.dart';
import '../widgets/kyc_tier_card.dart';

class KycOverviewPage extends StatelessWidget {
  const KycOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return KycPageBanner(
      pageTitle: firstTierPageTitle,
      pageBody: BlocBuilder<KycBloc, KycState>(
        builder: (context, state) {
          if (state is KycLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is KycLoaded) {
            final data = state.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: AppSpacing.xl),
                ...data.tiers.map(
                  (tier) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: KycTierCard(
                      title: tier.title,
                      description: tier.description,
                      tags: tier.tags,
                      unlockLimit: tier.unlockLimit,
                      isLocked: tier.status == TierStatus.locked,
                      isStartHere: tier.status == TierStatus.startHere,
                      isCompleted: tier.status == TierStatus.completed,
                      onTap: () {
                        if (tier.status == TierStatus.completed ||
                            tier.status == TierStatus.locked) {
                          return;
                        }
                        if (tier.id == 1) {
                          Navigator.pushNamed(context, '/tier1');
                        } else if (tier.id == 2) {
                          Navigator.pushNamed(context, '/tier2');
                        } else if (tier.id == 3) {
                          Navigator.pushNamed(context, '/tier3');
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
