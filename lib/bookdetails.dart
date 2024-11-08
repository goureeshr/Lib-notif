import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'profile.dart';

class BookDetails extends StatefulWidget {
  final Map<String, String> book;
  final String loggedInEmail;

  const BookDetails({Key? key, required this.book, required this.loggedInEmail})
      : super(key: key);

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  int indexNum = 1;
  DateTime _lastBackButtonPressTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String returnDate = widget.book['ReturnDate'] ?? 'Unknown';
    String takeDate = widget.book['TakeDate'] ?? 'Unknown';
    DateTime presentDate = DateTime.now();
    DateTime returnDateTime =
        returnDate != 'Unknown' ? DateTime.parse(returnDate) : DateTime.now();
    DateTime takeDateTime =
        takeDate != 'Unknown' ? DateTime.parse(takeDate) : DateTime.now();
    Duration difference = presentDate.difference(returnDateTime);
    int fine = difference.inDays * 1;
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
                  MaterialPageRoute(builder: (context) => Login()));
            } else if (index == 1) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      HomePage(loggedInEmail: widget.loggedInEmail)));
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      Profile(loggedInEmail: widget.loggedInEmail)));
            }
            setState(() {
              indexNum = index;
            });
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Book Details",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Container(
                    width: 300,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Image.asset(
                                'Assets/book.png',
                                height: 150,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                '${widget.book['BookName'] ?? 'Noname'}',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author: ${widget.book['Author'] ?? 'Unknown'}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'Taken Date: ${takeDateTime.day}/${takeDateTime.month}/${takeDateTime.year}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'Return Date: ${returnDateTime.day}/${returnDateTime.month}/${returnDateTime.year}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'Fine: ${fine > 0 ? fine.toString() : 'No Fines'}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}