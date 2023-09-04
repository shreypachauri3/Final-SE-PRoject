import 'package:delivery/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class selectHostel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Selection',
      home: HostelSelectionScreen(),
    );
  }
}

class HostelSelectionScreen extends StatefulWidget {
  @override
  _HostelSelectionScreenState createState() => _HostelSelectionScreenState();
}

class _HostelSelectionScreenState extends State<HostelSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedHostel = "Hostel D"; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hostel Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedHostel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedHostel = newValue!;
                });
              },
              items: <String>[
                'Hostel D',
                'Hostel A',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Get the current user
                User? user = _auth.currentUser;

                if (user != null) {
                  String userId = user.uid;
                  // Upload the selected hostel to Firestore
                  await _firestore.collection('Users').doc(userId).set({
                    'name': user.displayName,
                    'phnos':user.phoneNumber,
                    'email':user.email,
                    'hostel':selectedHostel
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hostel selection uploaded successfully.'),
                    ),
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantList(),
                      ));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
