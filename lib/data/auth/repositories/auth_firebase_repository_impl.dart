import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/services/token_service.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/data/auth/models/user_model.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';
import 'package:logger/web.dart';

class AuthFirebaseRepositoryImpl implements AuthFirebaseRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final TokenService _tokenService;

  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  AuthFirebaseRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    TokenService? tokenService,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _tokenService = tokenService ?? TokenService();

  @override
  Stream<Either<Failure, UserEntity?>> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      try {
        if (user != null) {
          logger.d('🔐 Auth State Changed: User logged in - ${user.email}');
          return Right(_mapFirebaseUser(user));
        } else {
          logger.d('🔐 Auth State Changed: User logged out');
          return const Right(null);
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
        return Left(AuthFailure(message: _handleAuthException(e).toString()));
      } catch (e) {
        logger.e('🔥 Unknown Auth Error: $e');
        return Left(AuthFailure(message: 'Unknown error'));
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        logger.d('👤 Current User: ${firebaseUser.email}');
      } else {
        logger.d('👤 No current user found');
      }
      return Right(
        firebaseUser != null ? _mapFirebaseUser(firebaseUser) : null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      logger.d('🔐 Signing in with email: $email, $password');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the ID token for authentication
      final idToken = await userCredential.user!.getIdToken();

      if (idToken != null) {
        // Save authentication data
        await _tokenService.saveAuthData(
          authToken: idToken,
          userId: userCredential.user!.uid,
        );
        logger.d('💾 Authentication tokens saved');
      }

      logger.d('✅ Sign in successful: ${userCredential.user?.email}');

      return Right(_mapFirebaseUser(userCredential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailLink(String email) async {
    try {
      logger.d('📧 Sending email link to: $email');

      final actionCodeSettings = firebase_auth.ActionCodeSettings(
        url: 'https://locket-186a4.firebaseapp.com/verifyEmail',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.locket',
        androidPackageName: 'com.example.locket',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      logger.d('✅ Email link sent successfully to: $email');
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailLink(
    String email,
    String emailLink,
  ) async {
    try {
      logger.d('🔗 Signing in with email link: $email');
      final userCredential = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // Get the ID token for authentication
      final idToken = await userCredential.user!.getIdToken();

      if (idToken != null) {
        // Save authentication data
        await _tokenService.saveAuthData(
          authToken: idToken,
          userId: userCredential.user!.uid,
        );
        logger.d('💾 Authentication tokens saved');
      }

      logger.d(
        '✅ Email link sign in successful: ${userCredential.user?.email}',
      );
      return Right(_mapFirebaseUser(userCredential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyPhone(String phoneNumber) async {
    try {
      logger.d('📱 Verifying phone number: $phoneNumber');
      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          logger.d('✅ Phone verification auto-completed');
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          logger.e('🔥 Phone verification failed: ${e.code} - ${e.message}');
          completer.completeError(_handleAuthException(e));
        },
        codeSent: (id, resendToken) {
          logger.d('📨 SMS code sent to: $phoneNumber');
          completer.complete(id);
        },
        codeAutoRetrievalTimeout: (_) {
          logger.w('⏰ SMS code auto-retrieval timeout');
        },
      );

      final verificationId = await completer.future;
      logger.d('✅ Phone verification ID received');
      return Right(verificationId);
    } catch (e) {
      logger.e('🔥 Phone verification error: $e');
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithPhone(
    String phoneNumber,
    String verificationId,
    String smsCode,
  ) async {
    try {
      logger.d('📱 Signing in with phone: $phoneNumber');
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Get the ID token for authentication
      final idToken = await userCredential.user!.getIdToken();

      if (idToken != null) {
        // Save authentication data
        await _tokenService.saveAuthData(
          authToken: idToken,
          userId: userCredential.user!.uid,
        );
        logger.d('💾 Authentication tokens saved');
      }

      logger.d(
        '✅ Phone sign in successful: ${userCredential.user?.phoneNumber}',
      );
      return Right(_mapFirebaseUser(userCredential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      logger.d('👤 Creating user with email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.d('✅ User created successfully: ${userCredential.user?.email}');
      return Right(_mapFirebaseUser(userCredential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      logger.d('🚪 Signing out user');

      // Clear authentication tokens
      await _tokenService.clearAuthData();
      logger.d('🗑️ Authentication tokens cleared');

      await _firebaseAuth.signOut();
      logger.d('✅ Sign out successful');
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      logger.d('📧 Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logger.d('✅ Password reset email sent successfully');
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      await _firebaseAuth.currentUser?.updatePhotoURL(photoURL);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser?.updateEmail(newEmail);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _handleAuthException(e).toString()));
    }
  }

  UserEntity _mapFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      username: firebaseUser.displayName!,
      avatarUrl: firebaseUser.photoURL,
      isVerified: firebaseUser.emailVerified,
      passwordHash: '',
    );
  }

  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Không tìm thấy người dùng với email này.');
      case 'invalid-email':
        return Exception('Địa chỉ email không hợp lệ.');
      case 'wrong-password':
        return Exception('Mật khẩu không đúng.');
      case 'email-already-in-use':
        return Exception('Email đã được sử dụng.');
      case 'weak-password':
        return Exception('Mật khẩu quá yếu.');
      case 'requires-recent-login':
        return Exception('Vui lòng đăng nhập lại để thực hiện hành động này.');
      default:
        return Exception(e.message ?? 'Đã xảy ra lỗi.');
    }
  }
}
