import 'package:common_designs/common_designs.dart';
import 'package:flutter/material.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:mix/mix.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/styles.dart';

class TermsAndServiceWidget extends StatelessWidget {
  const TermsAndServiceWidget({super.key, required this.config});
  final MerkadoAuthConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kToolbarHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StyledText(
            'By continuing, you agree to ${config.appName} ',
            style: LoginPageStyler.textStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextButton(
            style: LoginPageStyler.textButtonStyle(),
            onPressed: () async {
              final url = Uri.parse(
                config.termsUrl ?? 'https://mycut.biz/terms-of-service',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: StyledText(
              'Terms ',
              style: LoginPageStyler.textStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          StyledText(
            '&',
            style: LoginPageStyler.textStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextButton(
            style: LoginPageStyler.textButtonStyle(),
            onPressed: () async {
              final url = Uri.parse(
                config.privacyUrl ?? 'https://mycut.biz/privacy-policy',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: StyledText(
              ' Privacy Policy',
              style: LoginPageStyler.textStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
