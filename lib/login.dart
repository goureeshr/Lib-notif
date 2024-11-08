import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libnotif/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'admin_login.dart'; // Import your admin login page

class Authentication {
  static String loggedInEmail = "";
  static String loggedInPassword = "";
}

class Login extends StatelessWidget {
  final _registerNoController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff99baff),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 200, left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "Sign In To \nYour Account",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 40,
                width: 300,
                child: TextFormField(
                  controller: _registerNoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                    hintText: 'RegisterNo.',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 300,
                height: 40,
                child: TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                    hintText: 'DOB (yyyy-mm-dd)', // Add description here
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: EdgeInsets.only(left: 100),
                child: ElevatedButton(
                  onPressed: () {
                    checklogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(19, 18, 18, 0.867),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20), // Add some space between the buttons
              Padding(
                padding: EdgeInsets.only(left: 100),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(19, 18, 18, 0.867),
                  ),
                  child: Text(
                    "Admin",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checklogin(BuildContext ctx) async {
    final _registerNo = _registerNoController.text;
    final _dob = _dobController.text;

    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _registerNo)
          .where('password', isEqualTo: _dob)
          .get();

      final List<DocumentSnapshot> documents = result.docs;

      // Remove duplicate entries
      if (documents.length > 1) {
        for (int i = 0; i < documents.length - 1; i++) {
          final doc1 = documents[i];
          final doc2 = documents[i + 1];
          if (doc1['email'] == doc2['email'] &&
              doc1['password'] == doc2['password']) {
            await doc1.reference.delete();
          }
        }
      }

      if (documents.isNotEmpty) {
        Authentication.loggedInEmail = _registerNo;
        Authentication.loggedInPassword = _dob;
        final sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(LOGIN, true);
        sharedPref.setString(REGISTERNO, _registerNo);

        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) => HomePage(loggedInEmail: _registerNo),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              "Unable to Sign In: RegisterNo & DOB do not match",
              style: TextStyle(fontSize: 11),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            "An error occurred. Please try again later.",
            style: TextStyle(fontSize: 11),
          ),
        ),
      );
    }
  }
}
