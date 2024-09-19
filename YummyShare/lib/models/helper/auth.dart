import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  // Creating an instance of FirebaseAuth
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Getter to retrieve the current authenticated user
  User? get currentUser => firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Asynchronous method to log in with email and password
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Using FirebaseAuth to sign in with email and password
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Asynchronous method to sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Using FirebaseAuth to create a new user with email and password
    await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Asynchronous method to sign out the current user
  Future<void> signOut() async {
    // Using FirebaseAuth to sign out the current user
    await firebaseAuth.signOut();
  }
}
