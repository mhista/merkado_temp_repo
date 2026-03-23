import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_sign_in_service.dart';
import 'google_sign_in_exception.dart';

class GoogleFirebaseIntegration {
  final GoogleSignInService googleService;
  final FirebaseAuth firebaseAuth;

  GoogleFirebaseIntegration({
    required this.googleService,
    FirebaseAuth? firebaseAuth,
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Authenticate with Google
      final googleUser = await googleService.signIn();

      // 2. Get tokens (V7.0: synchronous!)
      final googleAuth = googleUser.authentication;

      // 3. Firebase credential
      final credential = GoogleAuthProvider.credential(
        // accessToken: googleUser.,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      // debugPrint('✅ Firebase sign-in: ${userCredential.user!.uid}');
      return userCredential;
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      throw GoogleAuthException.generic('Firebase sign-in failed', e);
    }
  }

  Future<UserCredential> linkWithGoogle() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw GoogleAuthException.generic('No Firebase user signed in');
    }

    final googleUser = await googleService.signIn();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      // accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await currentUser.linkWithCredential(credential);
  }

  Future<void> unlinkFromGoogle() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return;

    await currentUser.unlink(GoogleAuthProvider.PROVIDER_ID);
    await googleService.disconnect();
  }
}
