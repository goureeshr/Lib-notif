import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'bookdetails.dart';
import 'login.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final String loggedInEmail;

  const HomePage({Key? key, required this.loggedInEmail}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DateTime> _dueDates = [];
  String _selectedFilter = 'All';

  int indexNum = 1;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  DateTime _lastBackButtonPressTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDueDates();
  }

  void _loadDueDates() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('entries')
        .where('RegNo', isEqualTo: widget.loggedInEmail)
        .get();

    setState(() {
      _dueDates = snapshot.docs.map((doc) {
        DateTime? returnDate = DateTime.tryParse(doc['ReturnDate'] ?? "");
        if (returnDate != null) {
          return DateTime(returnDate.year, returnDate.month, returnDate.day);
        } else {
          return DateTime.now();
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        // ignore: unnecessary_null_comparison
        if (_lastBackButtonPressTime == null ||
            now.difference(_lastBackButtonPressTime) > Duration(seconds: 2)) {
          _lastBackButtonPressTime = now;
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
        bottomNavigationBar: SizedBox(
          height: 50,
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: 'SignOut'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
            iconSize: 20,
            unselectedFontSize: 10,
            selectedFontSize: 12,
            showSelectedLabels: true,
            selectedItemColor: Colors.indigo,
            currentIndex: indexNum,
            onTap: (int index) async {
              if (index != indexNum) {
                if (index == 0) {
                  final sharedPref = await SharedPreferences.getInstance();
                  sharedPref.clear();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Login()));
                } else if (index == 2) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          Profile(loggedInEmail: widget.loggedInEmail)));
                }

                setState(() {
                  indexNum = index;
                });
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 0),
                  child: Container(
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    height: 40,
                    width: 500,
                    padding: EdgeInsets.only(left: 25, top: 3),
                    child: Text(
                      "LibNotif.",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 500,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    "Upcoming Due Dates",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Container(
                    color: Colors.white,
                    height: 400,
                    width: 332,
                    child: TableCalendar<DateTime>(
                      firstDay: DateTime(DateTime.now().year - 1),
                      lastDay: DateTime(DateTime.now().year + 10),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        DateTime normalizedDay =
                            DateTime(day.year, day.month, day.day);
                        return _dueDates.contains(normalizedDay);
                      },
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, events) {
                          if (_dueDates.contains(date)) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(date),
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 500,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    "Book History",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    items: <String>['All', 'Returned', 'Borrowed']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('entries')
                        .where('RegNo', isEqualTo: widget.loggedInEmail)
                        .where(
                          'BookStatus',
                          isEqualTo:
                              _selectedFilter == 'All' ? null : _selectedFilter,
                        )
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return Center(child: Text('Error fetching data'));
                      }
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic>? entry =
                              documents[index].data() as Map<String, dynamic>?;
                          if (entry == null)
                            return SizedBox
                                .shrink(); // Return an empty widget if entry is null
                          // Explicit cast to Map<String, String>
                          Map<String, String> entryStringMap =
                              Map<String, String>.from(entry);
                          return Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(Icons.book),
                                  title: Text(
                                      entryStringMap['BookName'] ?? 'No Name'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Author: ${entryStringMap['Author'] ?? 'Unknown'}'),
                                      Text(
                                          'Taken Date: ${_formatDate(entryStringMap['TakeDate']) ?? 'Unknown'}'),
                                      Text(
                                          'Status: ${entryStringMap['BookStatus'] ?? 'Unknown'}'),
                                    ],
                                  ),
                                  trailing: Text(_formatDate(
                                          entryStringMap['ReturnDate']) ??
                                      'Unknown'),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                          loggedInEmail: widget.loggedInEmail,
                                          book:
                                              entryStringMap, // Passing the book details
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString != null && dateString.isNotEmpty) {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } else {
      return null;
    }
  }
}