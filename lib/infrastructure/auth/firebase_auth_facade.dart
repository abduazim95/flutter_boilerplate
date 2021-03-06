import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:note/domain/auth/auth_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:note/domain/auth/i_auth_facade.dart';
import 'package:note/domain/auth/value_objects.dart';

@LazySingleton(as: IAuthFacade)
class FirebaseAuthFacade implements IAuthFacade {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  
  FirebaseAuthFacade(
    this._firebaseAuth,
    this._googleSignIn
  );

  @override
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({@required EmailAddress emailAddress, @required Password password}) async {
    final emailAddressStr = emailAddress.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: emailAddressStr, password: passwordStr);
      return right(unit);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'email-already-in-use': {
          return left(const AuthFailure.emailAlreadyInUse());
        }
        default: {
          return left(const AuthFailure.serverError());
        }
      }
    }
  }
  
  @override
  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({@required EmailAddress emailAddress, @required Password password})  async {
    final emailAddressStr = emailAddress.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: emailAddressStr, password: passwordStr);
      return right(unit);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password': {
          return left(const AuthFailure.invalidEmailAndPasswordCombination());
        }
        default: {
          return left(const AuthFailure.serverError());
        }
      }
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(const AuthFailure.cancelledByUser());
      }
      final googleAuthentication =  await googleUser.authentication;
      
      final authCredential = GoogleAuthProvider.credential(accessToken: googleAuthentication.accessToken, idToken: googleAuthentication.idToken);
      
      return _firebaseAuth
        .signInWithCredential(authCredential)
        .then((r) => right(unit));
    } on PlatformException catch (_) {
      return left(const AuthFailure.serverError());
    }
  }
}