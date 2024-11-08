import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  final String loggedInEmail;
  const Profile({Key? key, required this.loggedInEmail}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int indexNum = 2;
  DateTime _lastBackButtonPressTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastBackButtonPressTime == null ||
            DateTime.now().difference(_lastBackButtonPressTime) >
                Duration(seconds: 2)) {
          _lastBackButtonPressTime = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xff99baff),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  color: Colors.white,
                  height: 60,
                  width: 500,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, top: 7),
                    child: Text(
                      "Profile",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData &&
                              snapshot.data!.exists) {
                            Map<String, dynamic>? data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            if (data != null &&
                                data.containsKey('Name') &&
                                data.containsKey('RegNo') &&
                                data.containsKey('DOB')) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.blue, // Set background color for the avatar
  child: Icon(
    Icons.person, // Choose the profile icon from available icons
    size: 100, // Adjust the size of the icon as needed
    color: Colors.white, // Replace with your image URL
                                    )  ),
                                  SizedBox(height: 20),
                                  Text(
                                    data['Name'],
                                    style: TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    data['RegNo'],
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    data['DOB'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    data['Email'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              );
                            } else {
                              return Text('Required fields are missing.');
                            }
                          } else {
                            return Text('Document does not exist.');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'SignOut'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          iconSize: 20,
          unselectedFontSize: 10,
          selectedFontSize: 12,
          showSelectedLabels: true,
          selectedItemColor: Colors.indigo,
          currentIndex: indexNum,
          onTap: (int index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Login()),
              );
            } else if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      HomePage(loggedInEmail: widget.loggedInEmail),
                ),
              );
            }
            setState(() {
              indexNum = index;
            });
          },
        ),
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchData() async {
  try {
    // Query the "entries" collection for the document with a specific document ID
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('entries')
        .where('RegNo', isEqualTo: widget.loggedInEmail)
        .get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Since email is unique, we expect only one document to match the query
      DocumentSnapshot<Map<String, dynamic>> snapshot = querySnapshot.docs.first;
      return snapshot;
    } else {
      // Handle case where no document matches the query
      throw Exception("Document not found for email: ${widget.loggedInEmail}");
    }
  } catch (e) {
    print("Error fetching user details: $e");
    rethrow; // Re-throw the error to be handled by the caller
  }
}

}