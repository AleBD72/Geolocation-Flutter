import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:login_app_proyecto/reusable_widgets/reusable_widget.dart';

import '../utils/color_utils.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key ? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sing Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors:[
          hexStringToColor("2E0249"), //
          hexStringToColor("A91079"),
          hexStringToColor("570A57")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,MediaQuery.of(context).size.height * 0.2, 20, 0
            ),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              reusableTextField("Ingrese el nombre de usuario", Icons.person_outline, false, 
              _userNameTextController),
              const SizedBox(
                height: 20,
              ),
              reusableTextField("Ingrese su correo electrónico", Icons.mail_outlined, false, 
              _emailTextController),
              const SizedBox(
                height: 20,
              ),
              reusableTextField("Ingrese una Contraseña", Icons.lock_outline, true, 
              _passwordTextController),
              const SizedBox(
                height: 20,
              ),
              signInSignUpButton(context, false, (){
                FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailTextController.text, 
                  password: _passwordTextController.text
                ).then((userCredential){
                    final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
                    String userName = _userNameTextController.text;
                    String userId = userCredential.user!.uid;

                    databaseReference.child('user').child(userId).set({
                      'username': userName,
                    }).then((_){
                      print("Nombre de usuario guardado de en la base de datos");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    }).catchError((error){
                      print("Error al guardar el nombre de usuario: $error");
                    });
                  }).catchError((error){
                    print("Error al crear la cuenta: $error");
                  });
                
                  /*.then((value) {
                  print("Nueva cuenta creada");
                  Navigator.push(context, 
                  MaterialPageRoute(builder:(context) => HomeScreen()));
                }).onError((error, stackTrace) {
                  print("Error ${error.toString()}");
                });*/
                
              })
              

            ],
          ),),
        ),
      ),
    );
  }
}