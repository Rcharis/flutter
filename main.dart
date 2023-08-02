import 'package:stb_01/CircleProgress.dart';

import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Dashboard1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class DefaultFirebaseOptions {
  static const currentPlatform = FirebaseOptions(
    appId: '1:289012125908:android:dd3be443b9a674135c6b41',
    projectId: 'stb01-a7ad4',
    messagingSenderId: '289012125908',
    databaseURL: 'https://stb01-a7ad4-default-rtdb.asia-southeast1.firebasedatabase.app/',
    storageBucket: 'stb01-a7ad4.appspot.com',
    apiKey: 'AIzaSyDDBGH9XnVA2SFHaFjLUvWQLlYdmF4L4GQ',
  );
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Temp & humid App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginScreen(
        title: 'ESP32 Temp & humid App',
        key: ValueKey('login_screen_key'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String title;

  LoginScreen({required Key key, required this.title}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  GoogleSignInAccount? _currentUser;


  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });

      if (_currentUser != null) {
        _handleFirebase();
      }
    });


    _googleSignIn.signInSilently(); //Auto login if previous login was success
  }

  void _handleFirebase() async {
    GoogleSignInAuthentication googleAuth = await _currentUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );


    final UserCredential userCredential =
    await firebaseAuth.signInWithCredential(credential);

    final User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      print('Login');

      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Dashboard()));
    }
  }


  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: Text('Google Sign in'),
          style: ElevatedButton.styleFrom(primary: Colors.amber),
        ),

      ),
    );
  }
}