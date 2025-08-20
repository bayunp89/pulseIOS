import 'package:flutter/material.dart';
import 'package:app_pulse/screens/signin_screen.dart';
import 'package:app_pulse/screens/signup_screen.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:app_pulse/widgets/custom_scaffold.dart';
import 'package:app_pulse/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(    
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 0), // Atur jarak 20 dari atas
              child: Center(
                child: RichText(textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [                   
                    TextSpan(                     
                      text: 'Welcome Back!\n',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                    TextSpan(
                      text:
                      '\nEnter personal details to your account',
                      style: TextStyle(
                        fontSize: 20,
                      ))                 
                  ],
                ),
                ),
              ),
            ),
          ),
           Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
            child: Row(
              children: [
                Expanded(child: WelcomeButton(
                  buttontext: 'Sign In',
                  onTap: SignInScreen(),
                  color: Colors.transparent,
                  textColor: Colors.white,
                  ),
                ),
                Expanded(child: WelcomeButton(
                  onTap: const SignUpScreen(),
                  buttontext: 'Sign Up',
                  color: Colors.white,
                  textColor: lightColorScheme.primary,
                  ),
                ), 
              ],
             ),
          ),
        ),
      ],
    ));
  }
}