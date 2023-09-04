import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/Auth-Flow/login_screen.dart';
import 'package:delivery/Homescreen.dart';
import 'package:delivery/firebase_options.dart';
import 'package:delivery/selecthostel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

String? selectedHostel;
Future<void> getHostelName() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? user = _auth.currentUser;

  if (user != null) {
    String userId = user.uid;

    // Fetch the hostel name from Firestore
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _firestore.collection('users').doc(userId).get();

    if (userDocument.exists) {
      selectedHostel = userDocument.data()?['hostel'];
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null || user.phoneNumber == null) {
      runApp(Material(child: MyApp()));
    } else {
      getHostelName();
      if (selectedHostel != 'NA')
        runApp(MaterialApp(home: selectHostel()));
      else {
        runApp(RestaurantList());
      }
    }
  });
}
