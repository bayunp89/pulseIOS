import 'package:flutter/material.dart';
//import 'package:login_page/screens/signup_screen.dart';


class WelcomeButton extends StatelessWidget{
  const WelcomeButton({super.key, this.buttontext, this.onTap, this.color, this.textColor});
  final String? buttontext;
  final Widget? onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (e) => onTap!,
            ),
            );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color!,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),),),
          child: Text(
            buttontext!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor!,
            ),
          ),
      ),
    );
  }
}