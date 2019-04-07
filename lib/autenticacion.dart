import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> currentUser();

  Future<String> signIn(String email, String password);

  Future<String> createUser(String email, String password);

  Future<void> signOut();

  Future<String> signInWithGoogle(String accessToken, String idToken);

  Future<String> signInWithFacebook(String accessToken);


}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> createUser(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signInWithGoogle(String accessToken, String idToken) async {
    FirebaseUser user = await _firebaseAuth.signInWithGoogle(
      accessToken: accessToken,
      idToken: idToken,
    );
    return user.uid;
  }

  Future<String> signInWithFacebook(String token)async{
    FirebaseUser user =await _firebaseAuth.signInWithFacebook(accessToken: token);
    return user.uid;
  }


  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
