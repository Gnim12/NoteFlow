import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleSignInInitialized = false;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<void> updateEmail(String email) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(email);
  }

  Future<void> updatePassword(String password) async {
    await _auth.currentUser?.updatePassword(password);
  }

  Future<void> reauthenticate(String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  /// ==========================
  /// GOOGLE SIGN-IN
  /// ==========================

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;

    // Sur Android, l'identifiant du client web est lu automatiquement depuis
    // google-services.json (entrée oauth_client de type 3), à condition que
    // le SHA-1 de signature ait été enregistré côté Firebase.
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw StateError("Impossible d'obtenir le jeton d'identité Google.");
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    return _auth.signInWithCredential(credential);
  }
}
