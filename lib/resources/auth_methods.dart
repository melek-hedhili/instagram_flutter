import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List file}) async {
    String res = "Some Error Accured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file.isNotEmpty ||
          file != null) {
        await Firebase.initializeApp();
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        //add user to our database
        String photoUrl = await StorageMethods()
            .uploadImageToStorage("profilePics", file, false);
        model.User user = model.User(
            email: email,
            uid: userCredential.user!.uid,
            photoUrl: photoUrl,
            username: username,
            bio: bio,
            followers: [],
            following: []);
        await _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(user.toJson());

        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = "Please enter a valid email";
      } else if (err.code == 'weak-password') {
        res = "Please enter a strong password";
      } else if (err.code == 'email-already-in-use') {
        res = "Email already in use";
      } else if (err.code == 'operation-not-allowed') {
        res = "Operation not allowed";
      } else {
        res = err.message!;
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some Error Accured";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        res = "User not found";
      } else if (error.code == 'wrong-password') {
        res = "Wrong password";
      } else if (error.code == 'invalid-email') {
        res = "Please enter a valid email";
      } else if (error.code == 'user-disabled') {
        res = "User disabled";
      } else if (error.code == "invalid-credential") {
        res = "Invalid Credentials";
      } else if (error.code == "invalid_login_credentials".toUpperCase()) {
        res = "User doesn't exist";
      } else {
        res = error.code!;
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
