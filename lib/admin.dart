import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff99baff), // Set background color
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Navigate back to AdminLoginPage on logout button press
              final sharedPref = await SharedPreferences.getInstance();
              sharedPref.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: AdminCrud(),
    );
  }
}

class AdminCrud extends StatefulWidget {
  const AdminCrud({Key? key}) : super(key: key);

  @override
  _AdminCrudState createState() => _AdminCrudState();
}

class _AdminCrudState extends State<AdminCrud> {
  final _regNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _deptController = TextEditingController();
  final _emailController = TextEditingController();
  final _bookNameController = TextEditingController();
  final _authorController = TextEditingController();

  late bool _manualTakeDate;
  late DateTime _takeDate;
  late DateTime _returnDate;
  String _bookStatus = 'borrowed';
  int _extendCount = 0;

  @override
  void initState() {
    super.initState();
    _manualTakeDate = false;
    _takeDate = DateTime.now();
    _returnDate = _takeDate.add(const Duration(days: 15));
  }

  Future<void> _addEntry() async {
    final regNo = _regNoController.text;
    final name = _nameController.text;
    final dob = _dobController.text;
    final dept = _deptController.text;
    final email = _emailController.text;
    final bookName = _bookNameController.text;
    final author = _authorController.text;

    if (regNo.isEmpty ||
        name.isEmpty ||
        dob.isEmpty ||
        dept.isEmpty ||
        email.isEmpty ||
        bookName.isEmpty ||
        author.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    final entry = {
      'RegNo': regNo,
      'Name': name,
      'DOB': dob,
      'Dept': dept,
      'Email': email,
      'BookName': bookName,
      'Author': author,
      if (_manualTakeDate) 'TakeDate': _takeDate.toString(),
      'ReturnDate': _manualTakeDate
          ? _takeDate.add(const Duration(days: 15)).toString()
          : _returnDate.toString(),
      'BookStatus': _bookStatus,
    };

    final entryRef =
        await FirebaseFirestore.instance.collection('entries').add(entry);

    // Add user data to 'users' collection
    await FirebaseFirestore.instance.collection('users').add({
      'email': regNo.toString(),
      'password': dob.toString(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry added successfully'),
      ),
    );

    setState(() {
      _regNoController.clear();
      _nameController.clear();
      _dobController.clear();
      _deptController.clear();
      _emailController.clear();
      _bookNameController.clear();
      _authorController.clear();
      if (!_manualTakeDate) _takeDate = DateTime.now();
      _returnDate = _manualTakeDate
          ? _takeDate.add(const Duration(days: 15))
          : DateTime.now().add(const Duration(days: 15));
      _bookStatus = 'Borrowed';
      _extendCount = 0;
    });
  }

  Future<void> _deleteEntry(String id) async {
    await FirebaseFirestore.instance.collection('entries').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry deleted successfully'),
      ),
    );
  }

  Future<void> _returnBook(String id) async {
    await FirebaseFirestore.instance
        .collection('entries')
        .doc(id)
        .update({'BookStatus': 'Returned'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Book returned successfully'),
      ),
    );
  }

  Future<void> _extendReturnDate(String id) async {
    if (_extendCount < 2) {
      _extendCount++;
      final newReturnDate = _returnDate.add(const Duration(days: 15));
      await FirebaseFirestore.instance
          .collection('entries')
          .doc(id)
          .update({'ReturnDate': newReturnDate.toString()});
      setState(() {
        _returnDate = newReturnDate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return date extended by 15 days'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only extend return date two times.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Information',
                    style: Theme.of(context).textTheme.headline6),
                TextField(
                  controller: _regNoController,
                  decoration: const InputDecoration(
                    labelText: 'Reg No',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dob = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (dob != null) {
                      _dobController.text = dob.toString().substring(0, 10);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'DOB',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: null,
                  decoration: const InputDecoration(
                    labelText: 'Dept',
                  ),
                  items: ['CSE', 'IT', 'MECH', 'EEE', 'CIVIL'].map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _deptController.text = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bookNameController,
                  decoration: const InputDecoration(
                    labelText: 'Book Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Manual Take Date:'),
                    Switch(
                      value: _manualTakeDate,
                      onChanged: (value) {
                        setState(() {
                          _manualTakeDate = value;
                        });
                      },
                    ),
                  ],
                ),
                if (_manualTakeDate)
                  TextField(
                    readOnly: true,
                    onTap: () async {
                      final DateTime? takeDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (takeDate != null) {
                        setState(() {
                          _takeDate = takeDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _takeDate.toString().substring(0, 10),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Take Date',
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addEntry,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('entries').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final entries = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index].data() as Map<String, dynamic>;
                  final id = entries[index].id;
                  return EntryCard(
                    entry: entry,
                    deleteEntry: () => _deleteEntry(id),
                    returnBook: () => _returnBook(id),
                    extendReturnDate: () => _extendReturnDate(id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class EntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback deleteEntry;
  final VoidCallback returnBook;
  final VoidCallback extendReturnDate;

  const EntryCard({
    required this.entry,
    required this.deleteEntry,
    required this.returnBook,
    required this.extendReturnDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${entry['Name']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Reg No: ${entry['RegNo']}'),
            Text('Book Name: ${entry['BookName']}'),
            Text('Return Date: ${_formatDate(entry['ReturnDate'])}'),
            if (entry['TakeDate'] != null)
              Text('Take Date: ${_formatDate(entry['TakeDate'])}'),
            Text('Status: ${entry['BookStatus']}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: deleteEntry,
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () => returnBook(),
                  child: const Text('Return'),
                ),
                ElevatedButton(
                  onPressed: () => extendReturnDate(),
                  child: const Text('Extend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateTime) {
    final date = DateTime.parse(dateTime);
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    return formattedDate;
  }
}
