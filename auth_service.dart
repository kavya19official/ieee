import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }
      
      // Verify email domain if restriction is enabled
      if (AppConfig.enforceEmailDomainRestriction) {
        if (!googleUser.email.endsWith('@${AppConfig.allowedEmailDomain}')) {
          await _googleSignIn.signOut();
          throw Exception(
            'Only ${AppConfig.allowedEmailDomain} email addresses are allowed'
          );
        }
      }
      
      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }
      
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        // Create new user document
        final newUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toFirestore());
        return newUser;
      } else {
        // Update last login time
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': Timestamp.now(),
        });
        
        return AppUser.fromFirestore(userDoc);
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Get current user data
  Future<AppUser?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;
      
      return AppUser.fromFirestore(userDoc);
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  // Check if user has permission
  Future<bool> checkPermission(String permission) async {
    try {
      final userData = await getCurrentUserData();
      return userData?.hasPermission(permission) ?? false;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
      
      // Sign out from Google
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
  
  // Verify email domain
  bool verifyEmailDomain(String email) {
    if (!AppConfig.enforceEmailDomainRestriction) return true;
    return email.endsWith('@${AppConfig.allowedEmailDomain}');
  }
}
