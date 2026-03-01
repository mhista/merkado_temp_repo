import 'dart:async';

import 'package:common_designs/common_designs.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

import '../styles.dart';

/// OtpResendTimer
/// ==============
/// Self-contained countdown timer widget for OTP resend.
/// Isolated in its own StatefulWidget so the countdown rebuilds
/// only this widget — the rest of the OTP screen is untouched.
///
/// Behaviour:
///   - Counts down from [duration] (default 30s)
///   - While counting: shows "Resend OTP in 00:XX" (timer in blue)
///   - When expired: shows an active "Resend OTP" button
///   - Tapping resend calls [onResend] and resets the countdown
///   - [onResend] is async — the button shows a spinner while it runs
///   - If [onResend] throws, the timer resets anyway (safe UX)
class OtpResendTimer extends StatefulWidget {
  /// Called when the user taps "Resend OTP" after the timer expires.
  /// Typically calls cubit.resendOtp(email: ...).
  final Future<void> Function() onResend;

  /// How long to count down before enabling the resend button.
  final Duration duration;

  const OtpResendTimer({
    super.key,
    required this.onResend,
    this.duration = const Duration(seconds: 30),
  });

  @override
  State<OtpResendTimer> createState() => _OtpResendTimerState();
}

class _OtpResendTimerState extends State<OtpResendTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _reset() {
    setState(() => _remainingSeconds = widget.duration.inSeconds);
    _startTimer();
  }

  Future<void> _handleResend() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      await widget.onResend();
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
        _reset();
      }
    }
  }

  /// Formats remaining seconds as MM:SS.
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _canResend => _remainingSeconds == 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xxs,
      children: [
        StyledText(
          "Didn't receive the code?",
          style: LoginPageStyler.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ).textAlign(TextAlign.center),
        ),
        if (!_canResend)
          // ── Counting down ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.xxs,
            children: [
              StyledText(
                'Resend OTP in',
                style: LoginPageStyler.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ).textAlign(TextAlign.center),
              ),
              StyledText(
                _formattedTime,
                style: LoginPageStyler.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ).textAlign(TextAlign.center).color(Colors.blue),
              ),
            ],
          )
        else
          // ── Timer expired — show resend button ─────────────────────────
          TextButton(
            onPressed: _isResending ? null : _handleResend,
            child: _isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : StyledText(
                    'Resend OTP',
                    style: LoginPageStyler.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ).color(Colors.blue),
                  ),
          ),
      ],
    );
  }
}