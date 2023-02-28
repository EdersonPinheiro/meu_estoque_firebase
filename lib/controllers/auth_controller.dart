import 'package:estoque/constants/constants.dart';
import 'package:estoque/pages/home_page.dart';
import 'package:estoque/pages/login_page.dart';
import 'package:estoque/pages/userInformacoes.dart';
import 'package:estoque/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../keys.dart';

class AuthController extends GetxController {
  static AuthController authInstance = Get.find();
  late Rx<User?> firebaseUser;
  ProductService productService = ProductService();
  UserInformacoes? userInformacoes;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(auth
        .currentUser); //atribui o usuário atual da autenticação firebase a ela.
    firebaseUser.bindStream(auth
        .userChanges()); //sempre que o usuário alterar, o fluxo emitirá o novo valor e o firebaseUserserá atualizado.
    ever(firebaseUser,
        setInitialScreen); //sempre que o fluxo de firebaseUser muda
  }

  setInitialScreen(User? user) {
    if (user != null) {
      // user is logged in
      Get.to(() => const HomePage());
    } else {
      // user is null as in user is not available or not logged in
      Get.to(() => const LoginPage());
    }
  }

  void register(String email, String password, String userName) async {
    UserCredential userCredential;
    var userId = auth.currentUser?.uid;
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      productService.db.collection("users").doc(auth.currentUser?.uid).set({
        "email": email,
        "uid": auth.currentUser?.uid,
        "user_name": userName,
        "image": "https://source.unsplash.com/random/200x200",
        "prime": false,
      });
    } on FirebaseAuthException catch (e) {
      // this is solely for the Firebase Auth Exception
      // for example : password did not match
      print(e.message);
      // Get.snackbar("Error", e.message!);
      Get.snackbar(
        "Error",
        e.message!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // this is temporary. you can handle different kinds of activities
      //such as dialogue to indicate what's wrong
      print(e.toString());
    }
  }

  void login(String email, String password) async {
    try {
      // Verifica se o operador existe na tabela de operadores
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Usuario nao encontrado", "!");
    }
  }

  void signOut() {
    try {
      auth.signOut();
      onReady();
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteAccount() async {
    auth.currentUser?.delete();
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      try {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        await auth.signInWithCredential(authCredential);

        productService.db.collection("users").doc(auth.currentUser?.uid).set({
          "email": auth.currentUser?.email,
          "uid": auth.currentUser?.uid,
          "user_name": auth.currentUser?.displayName,
          "image": auth.currentUser?.photoURL,
          "prime": false,
        });
      } on FirebaseAuthException catch (e) {
        Keys.scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text(e.message!),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: Text("Conta não selecionada!"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
