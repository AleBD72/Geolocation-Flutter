import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app_proyecto/reusable_widgets/reusable_widget.dart';
import 'package:login_app_proyecto/screens/home_screen.dart';
import 'package:login_app_proyecto/screens/signup_screen.dart';

import '../utils/color_utils.dart';


class SingInScreen extends StatefulWidget {
  const SingInScreen({super.key});

  @override
  State<SingInScreen> createState() => _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: LinearGradient(colors:[
          hexStringToColor("2E0249"), //
          hexStringToColor("A91079"),
          hexStringToColor("570A57")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(children: <Widget>[
              logoWidget("assets/images/location.png"),
              SizedBox(
                height: 30,
              ),
              reusableTextField("Ingrese su correo", Icons.person_outline, false, _emailTextController),
              SizedBox(
                height: 20,
              ),
              reusableTextField("Ingrese su contraseña", Icons.lock_outline, true, _passwordTextController),
              SizedBox(
                height: 20,
              ),
              signInSignUpButton(context, true, (){
                FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailTextController.text, 
                password: _passwordTextController.text).then((value){
                  Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen())
                  ).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                });
                
              }),
              signUpOption(),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption(){
    return Row (
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Aun no tienes una cuenta? ",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: (){
            Navigator.push(context, 
            // ignore: prefer_const_constructors
            MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            "Crear cuenta",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
