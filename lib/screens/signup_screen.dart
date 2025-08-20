import 'package:flutter/material.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:app_pulse/widgets/custom_scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupButton = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _site = TextEditingController();
  final TextEditingController _hostname = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _verifyPass = TextEditingController();
  final myBox = Hive.box('userData');

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(flex: 0, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _signupButton,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      textBoxEmail(),
                      const SizedBox(height: 20),
                      textBoxPass(),
                      const SizedBox(height: 20),
                      textBoxVerifyPass(),
                      const SizedBox(height: 20),
                      textBoxSite(),
                      const SizedBox(height: 20),
                      textBoxHostname(),
                      const SizedBox(height: 20),
                      buttonSignup(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buttonSignup(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_signupButton.currentState!.validate()) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Sign Up'),
                  content: const Text('Are you sure you want to sign up?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (myBox.containsKey(_email.text)) {
                          Fluttertoast.showToast(
                            msg: "Email already exists",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        } else {
                          myBox.put(_email.text, [
                            _email.text,
                            _pass.text,
                            _site.text,
                            _hostname.text,
                          ]);
                          _email.clear();
                          _pass.clear();
                          _verifyPass.clear();
                          _site.clear();
                          _hostname.clear();
                          Fluttertoast.showToast(
                            msg: "Sign Up Successful",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                          Navigator.pop(context); // Close the dialog
                        }
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          } else {
            Fluttertoast.showToast(
              msg: "Please fill in all fields correctly",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  TextFormField textBoxPass() {
    return TextFormField(
      controller: _pass,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  TextFormField textBoxEmail() {
    return TextFormField(
      controller: _email,
      decoration: InputDecoration(
        labelText: 'Username or Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or username';
        }
        return null;
      },
    );
  }

  TextFormField textBoxVerifyPass() {
    return TextFormField(
      controller: _verifyPass,
      decoration: InputDecoration(
        labelText: 'Verify Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your verify password';
        }
        if (value != _pass.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  TextFormField textBoxSite() {
    return TextFormField(
      controller: _site,
      decoration: InputDecoration(
        labelText: 'Site',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Site';
        }
        return null;
      },
    );
  }

  TextFormField textBoxHostname() {
    return TextFormField(
      controller: _hostname,
      decoration: InputDecoration(
        labelText: 'Hostname or IP Address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your hostname or IP address';
        }
        return null;
      },
    );
  }
}
