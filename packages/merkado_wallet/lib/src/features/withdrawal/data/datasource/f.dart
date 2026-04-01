// // ═════════════════════════════════════════════════════════════════════
// // FILE: features/deal/presentation/pages/create_deal/create_deal_page.dart
// //
// // Fixes in this version:
// //   1. BlocListener listenWhen now covers publishSuccess, draftSaved,
// //      AND publishError — not just step changes.
// //   2. Publish success:
// //        • Edit mode   → pops the screen (back to deal detail)
// //        • Create mode → pops back to dashboard (or push to deal room)
// //   3. Draft saved → success snackbar
// //   4. Publish error → error snackbar
// //   5. _showSnackBar helper centralises SnackBar styling.
// // ═════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mycut/core/constants/colors.dart';
// import 'package:mycut/core/di/injection_container.dart';
// import 'package:mycut/features/deal/create_deal/domain/entities/create_draft_deal.dart';
// import 'package:mycut/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
// import 'package:mycut/shared/widgets/bars/app_bar.dart';

// import '../../../../../../core/services/draft/draft_persistance.dart';
// import '../../../../../../shared/widgets/stepper/mycut_stepper.dart';
// import '../../cubits/create_deal_cubit.dart';
// import '../add_participants_flow.dart/widgets/draft_restore_banner.dart';
// import 'create_deal_basics_step.dart';
// import 'create_deal_participants.dart';
// import 'create_deal_review.dart';
// import 'create_deal_structure_step.dart';
// import 'widgets/create_deal_stepper.dart';

// class CreateDealPage extends StatefulWidget {
//   const CreateDealPage({super.key, this.isEditMode = false});
//   final bool isEditMode;

//   @override
//   State<CreateDealPage> createState() => _CreateDealPageState();
// }

// class _CreateDealPageState extends State<CreateDealPage> {
//   late final PageController _pageController;
//   late final CreateDealCubit _cubit;
//   CreateDealDraft? _savedDraft;

//   static const List<Widget> _steps = [
//     CreateDealBasicsStep(),
//     CreateDealStructureStep(),
//     CreateDealParticipantsStep(),
//     CreateDealReviewStep(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _cubit = getIt<CreateDealCubit>();

//     getIt<ProfileCubit>().loadProfile();
//     final currentUser = getIt<ProfileCubit>().currentUser;
//     if (!widget.isEditMode && currentUser != null) {
//       _cubit.initialize(currentUser);
//     }
//     if (!widget.isEditMode) _restoreDraft();
//     _pageController = PageController(initialPage: _cubit.state.currentStep);
//   }

//   Future<void> _restoreDraft() async {
//     final saved = await DraftPersistence.load();
//     if (saved != null && mounted) setState(() => _savedDraft = saved);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // ── Snackbar helper ───────────────────────────────────────────────

//   void _showSnackBar({
//     required String message,
//     required _SnackBarType type,
//   }) {
//     if (!mounted) return;
//     final (bg, icon, textColor) = switch (type) {
//       _SnackBarType.success => (
//           const Color(0xFF1A3828),
//           Icons.check_circle_outline_rounded,
//           Colors.white,
//         ),
//       _SnackBarType.info => (
//           const Color(0xFF1E3A5F),
//           Icons.info_outline_rounded,
//           Colors.white,
//         ),
//       _SnackBarType.error => (
//           const Color(0xFFB71C1C),
//           Icons.error_outline_rounded,
//           Colors.white,
//         ),
//     };

//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: bg,
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         duration: type == _SnackBarType.error
//             ? const Duration(seconds: 5)
//             : const Duration(seconds: 3),
//         content: Row(
//           children: [
//             Icon(icon, color: textColor, size: 18),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: textColor,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Navigation helper ─────────────────────────────────────────────

//   void _onPublishSuccess() {
//     if (!mounted) return;

//     if (widget.isEditMode) {
//       // Go back to deal detail screen
//       Navigator.of(context).pop(true); // true = signal to refresh
//     } else {
//       // Pop back to dashboard (or push to negotiation room if you have the ID)
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CreateDealCubit, CreateDealState>(
//       bloc: _cubit,
//       listenWhen: (prev, curr) =>
//           // Step navigation
//           prev.currentStep != curr.currentStep ||
//           // Publish success (rising edge only)
//           (!prev.publishSuccess && curr.publishSuccess) ||
//           // Draft saved (rising edge only)
//           (!prev.draftSaved && curr.draftSaved) ||
//           // New error appeared
//           (curr.publishError != null && prev.publishError != curr.publishError),
//       listener: (_, state) {
//         // ── 1. Publish success ──────────────────────────────────────
//         if (state.publishSuccess) {
//           _showSnackBar(
//             message: widget.isEditMode
//                 ? 'Deal updated successfully!'
//                 : 'Deal published! Participants will be notified.',
//             type: _SnackBarType.success,
//           );
//           // Small delay so the snackbar is visible before pop
//           Future.delayed(const Duration(milliseconds: 600), _onPublishSuccess);
//           return;
//         }

//         // ── 2. Draft saved ──────────────────────────────────────────
//         if (state.draftSaved) {
//           _showSnackBar(
//             message: 'Draft saved — you can continue later.',
//             type: _SnackBarType.info,
//           );
//           // Don't return — let step changes still be processed below
//           // if they happened in the same emit (they usually don't).
//         }

//         // ── 3. Publish / save error ─────────────────────────────────
//         if (state.publishError != null) {
//           _showSnackBar(
//             message: state.publishError!,
//             type: _SnackBarType.error,
//           );
//           return;
//         }

//         // ── 4. Step changed — animate PageView ─────────────────────
//         if (_pageController.hasClients) {
//           _pageController.animateToPage(
//             state.currentStep,
//             duration: const Duration(milliseconds: 320),
//             curve: Curves.easeInOut,
//           );
//         }
//         FocusScope.of(context).unfocus();

//         // Auto-save draft on each step advance (create mode only)
//         if (!widget.isEditMode && !state.draftSaved) {
//           _cubit.saveAsDraft();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: MyCutExtraColors.scaffoldColor,
//         appBar: const MyCutAppBar(
//           showTitle: true,
//           showPop: true,
//         ),
//         body: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: Column(
//             children: [
//               // ── Stepper ─────────────────────────────────────────
//               BlocBuilder<CreateDealCubit, CreateDealState>(
//                 bloc: _cubit,
//                 buildWhen: (prev, curr) =>
//                     prev.currentStep != curr.currentStep,
//                 builder: (_, state) => CreateDealStepper(
//                   currentStep: state.currentStep,
//                   onStepTapped: (i) {
//                     if (i < state.currentStep) _cubit.goToStep(i);
//                   },
//                 ),
//               ),

//               // ── Draft restore banner ────────────────────────────
//               if (_savedDraft != null)
//                 DraftRestoreBanner(
//                   savedDraft: _savedDraft!,
//                   onRestore: () {
//                     _cubit.restoreFromSaved(_savedDraft!);
//                     DraftPersistence.clear();
//                     setState(() => _savedDraft = null);
//                   },
//                   onDiscard: () {
//                     DraftPersistence.clear();
//                     setState(() => _savedDraft = null);
//                   },
//                 ),

//               // ── Steps ───────────────────────────────────────────
//               Expanded(
//                 child: PageView(
//                   controller: _pageController,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: _steps,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum _SnackBarType { success, info, error }