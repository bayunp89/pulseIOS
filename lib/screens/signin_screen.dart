import 'package:flutter/material.dart';
import 'package:app_pulse/screens/forget.passwors.dart';
import 'package:app_pulse/screens/home.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:app_pulse/widgets/custom_scaffold.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final myBox = Hive.box('userData');
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool rememberPassword = true;
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(flex: 1, child: SizedBox(height: 10)),
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
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
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
                      rowForgetPass(),
                      const SizedBox(height: 20),
                      buttonSignin(context),
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

  SizedBox buttonSignin(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formSignInKey.currentState!.validate()) {
            // Assuming the user exists in the Hive box
            if (myBox.containsKey(_email.text) &&
                myBox.get(_email.text)[1] == _pass.text) {
              Fluttertoast.showToast(
                msg: "Sign In Successful",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => homeScreen(emailID: _email.text),
                ),
              );
            }
            else {
              Fluttertoast.showToast(
                msg: "Invalid email or password",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
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
          'Sign In',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Row rowForgetPass() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberPassword,
              onChanged: (value) {
                setState(() {
                  rememberPassword = value!;
                });
              },
              activeColor: lightColorScheme.primary,
            ),
            const Text('Remember Me'),
          ],
        ),
        TextButton(
          onPressed: () {
            // Navigate to Forgot Password screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetPasswordScreen(),
              ),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
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
        if (!myBox.containsKey(value)) {
          return 'User does not exist';
        }
        return null;
      },
    );
  }
}
