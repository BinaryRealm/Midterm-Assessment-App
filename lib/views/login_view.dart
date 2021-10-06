import 'package:auth_app/driver.dart';
import 'package:auth_app/views/phone_login_view.dart';
import 'package:auth_app/views/register_view.dart';
import 'package:auth_app/auth_class.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/ui/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController, _passwordController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  bool _loading = false;
  String _email = "";
  String _password = "";
  User? user;

  void handleLink(Uri link) async {
    if (link != null) {
      user = await FireAuthClass.loginEmailAndLink(
          email: _emailController.text, link: link);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (con) => AppDriver()));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final Uri? deepLink = dynamicLink?.link;

        if (deepLink != null) {
          //Navigator.pushNamed(context, deepLink.path);
          handleLink(deepLink);
        }
      }, onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      });

      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        //Navigator.pushNamed(context, deepLink.path);
        handleLink(deepLink);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailInput = TextFormField(
      autocorrect: false,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: "EMAIL ADDRESS",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Email'),
    );
    final passwordInput = TextFormField(
      autocorrect: false,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "PASSWORD",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );
    final submitButton = OutlinedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing Data')));
          _email = _emailController.text;
          _password = _passwordController.text;

          // _emailController.clear();
          // _passwordController.clear();

          setState(() {
            _loading = true;
          });
          user = await FireAuthClass.loginEmailPassword(
              email: _email, password: _password);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (con) => AppDriver()));

          setState(() {
            _loading = false;
          });
        }
      },
      child: const Text('Login'),
    );
    final anonymousButton = OutlinedButton(
      onPressed: () async {
        setState(() {
          _loading = true;
        });
        user = await FireAuthClass.loginAnon();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (con) => AppDriver()));
        setState(() {
          _loading = false;
        });
      },
      child: const Text('Login Anonymous'),
    );
    final emailLoginButton = OutlinedButton(
      onPressed: () async {
        _email = _emailController.text;

        // _emailController.clear();
        // _passwordController.clear();

        setState(() {
          _loading = true;
        });
        FireAuthClass.sendLoginEmailNoPassword(email: _email);

        setState(() {
          _loading = false;
        });
      },
      child: const Text('Email Login without Password'),
    );
    final phoneButton = OutlinedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (con) => const PhoneLoginPage()));
      },
      child: const Text('Go to phone login page'),
    );
    final registerButton = OutlinedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (con) => const RegisterPage()));
      },
      child: const Text('Register'),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            user != null
                ? Container() //Text(_auth.currentUser!.uid)
                : _loading
                    ? Loading()
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            emailInput,
                            const SizedBox(height: 10.0),
                            passwordInput,
                            submitButton,
                            emailLoginButton,
                            phoneButton,
                            anonymousButton,
                            registerButton
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
