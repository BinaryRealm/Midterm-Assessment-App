import 'package:auth_app/driver.dart';
import 'package:auth_app/auth_class.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);
  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLoginPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _codeController;
  User? user;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneInput = TextFormField(
      autocorrect: false,
      controller: _phoneController,
      validator: (value) {
        /*if (value == null || value.isEmpty) {
          return 'Please enter a phone number';
        }*/
        return null;
      },
      decoration: const InputDecoration(
          labelText: "Phone Number",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Phone Number'),
    );
    final submitButton = OutlinedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Sending Sms')));
          await FireAuthClass.loginPhoneNumber(
              phoneNumber: _phoneController.text);
        }
      },
      child: const Text('Login with phone'),
    );

    final codeInput = TextFormField(
      autocorrect: false,
      controller: _codeController,
      validator: (value) {
        /*if (value == null || value.isEmpty) {
          return 'Please enter a code';
        }*/
        return null;
      },
      decoration: const InputDecoration(
          labelText: "Sms code",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Sms code'),
    );

    final submitButton2 = OutlinedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('processing...')));
          await FireAuthClass.confirmLoginPhoneNumber(
              verificationId: FireAuthClass.myVerificationId!,
              smsCode: _codeController.text);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (con) => AppDriver()));
        }
      },
      child: const Text('Submit phone sms code'),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  phoneInput,
                  const SizedBox(height: 10.0),
                  submitButton,
                  const SizedBox(height: 10.0),
                  codeInput,
                  const SizedBox(height: 10.0),
                  submitButton2
                ],
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
