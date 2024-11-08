import 'package:flutter/material.dart';
import 'package:libnotif/admin.dart';
import 'package:libnotif/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

const LOGIN = "LOGIN_KEY";
const REGISTERNO = "REGISTER_NO";
const ADMIN = "ADMIN";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyDzOAkXITMeo1Wn2V-DqPNU8DCmgHlBsKk',
          appId: '1:957077238857:android:6b6d3118f33f08fd32fb98',
          messagingSenderId: '957077238857',
          projectId: 'libn-7d7ca',
          storageBucket: 'libn-7d7ca.appspot.com'));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        backgroundColor: Color(0xff99baff),
        body: SafeArea(
          child: Stack(
            // Use Stack to position elements on top of each other
            children: [
              // Centered content with logo and text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'Assets/library-icon.webp',
                            height: 100,
                          ),
                          Text(
                            "LibNotif.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Positioned button above the bottom navigation bar
              Positioned(
                bottom: 100.0, // Adjust spacing from bottom as needed
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 40,
                    child: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () {
                          // Navigate to a new screen named "SecondScreen"
                          checkLogin(context);
                        },
                        child: Text(
                          "Get Started",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkLogin(BuildContext context) async {
    final sharedPref = await SharedPreferences.getInstance();
    final _userLogin = sharedPref.getBool(LOGIN);
    final _registerNo = sharedPref.getString(REGISTERNO);
    final _admin = sharedPref.getBool(ADMIN);

    if (_admin != null && _admin == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (_userLogin == null || _userLogin == false) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(loggedInEmail: _registerNo!),
        ),
      );
    }
  }
}
