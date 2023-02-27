import 'package:estoque/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseStorage storageF = FirebaseStorage.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final Future<FirebaseApp> firebaseInitialization = Firebase.initializeApp(
  name: defaultFirebaseAppName,
  options: DefaultFirebaseOptions.currentPlatform
);