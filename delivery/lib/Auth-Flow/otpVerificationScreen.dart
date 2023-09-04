import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTP extends StatefulWidget {
  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  TextEditingController phoneNumberController = TextEditingController();
  String verificationId = '';
  void sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        setState(() {
          phoneNumberController.text = "";
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP() async {
    print(phoneNumberController.text);
    String smCode = phoneNumberController.text;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smCode);
    try {
      FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Enter Phone Number'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              ElevatedButton(
                onPressed: sendOTP,
                child: Text('Send OTP'),
              ),
              if (verificationId != '')
                TextField(
                  decoration: InputDecoration(
                    labelText: 'OTP',
                  ),
                  controller: phoneNumberController,
                ),
              if (verificationId != '')
                ElevatedButton(
                  onPressed: verifyOTP,
                  child: Text('Enter OTP'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
