import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/kyc/data/models/kyc_page_title_model.dart';
import '../../features/kyc/presentation/bloc/kyc_bloc.dart';
import '../constants/app_colors.dart';
import 'back_button.dart';
import 'kyc_page_progress_indicator.dart';

class KycPageBanner extends StatelessWidget {
  const KycPageBanner({
    super.key,
    required this.pageBody,
    required this.pageTitle,
  });

  final Widget pageBody;
  final KycPageTitle pageTitle;

  @override
  Widget build(BuildContext context) {
    final double devWidth = MediaQuery.of(context).size.width;
    final double devHeight = MediaQuery.of(context).size.height;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bannerBg = isDark
        ? AppColors.primary.withValues(alpha: 0.1)
        : const Color(0xFF1C2E1F);
    final Color bannerTextColor = isDark
        ? AppColors.lightTextPrimary
        : Colors.white;
    final Color bannerPrimaryColor = AppColors.primary;

    return Scaffold(
      body: BlocBuilder<KycBloc, KycState>(
        builder: (context, state) {
          // Note: Initial loading should still show a spinner if there's no data
          if (state is KycLoading &&
              (state is KycInitial || state is KycError)) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: devWidth,
                height: 284.00,
                padding: const EdgeInsets.all(AppSpacing.md),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: bannerBg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: devWidth,
                      height: 50.0,
                      margin: EdgeInsets.only(top: devHeight * 0.015),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const AppBackButton(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: bannerPrimaryColor.withValues(alpha: 0.18),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: bannerPrimaryColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              pageTitle.badge!,
                              style: TextStyle(
                                color: bannerPrimaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'MY',
                            style: TextStyle(
                              color: bannerTextColor,
                              fontSize: 20,
                              fontFamily: 'Cormorant Garamond',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.80,
                            ),
                          ),
                          TextSpan(
                            text: 'CUT',
                            style: TextStyle(
                              color: bannerPrimaryColor,
                              fontSize: 20,
                              fontFamily: 'Cormorant Garamond',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.90,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 46,
                      height: 44,
                      padding: const EdgeInsets.only(bottom: 2),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: bannerPrimaryColor.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: bannerPrimaryColor.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Icon(
                        Icons.star_outline_outlined,
                        size: 22.0,
                        color: bannerTextColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        pageTitle.title,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontFamily: 'Cormorant Garamond',
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: devWidth * 0.8,
                      child: Text(
                        pageTitle.subTitle,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress indicator
                    KycPageProgressIndicator(
                      isDark: isDark,
                      currentStep: pageTitle.step,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  primary: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: pageBody,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<KycBloc, KycState>(
        builder: (context, state) {
          final bool isLoading = state is KycLoading;
          return GestureDetector(
            onTap: isLoading ? null : () => pageTitle.pageButton!(),
            child: Container(
              width: devWidth * 0.9,
              height: 48.0,
              padding: const EdgeInsets.all(15),
              margin: EdgeInsets.only(
                bottom: devHeight * 0.04,
                left: 16.0,
                right: 16.0,
                top: 8.0,
              ),
              decoration: ShapeDecoration(
                color: isDark ? AppColors.primary : const Color(0xFF1B3A2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      spacing: 5.0,
                      children: [
                        Text(
                          pageTitle.buttonCaption!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
