import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
import 'package:intro_mobile_project/utils/color_utils.dart';
import 'package:intro_mobile_project/widgets/Registratie&InlogWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                  child: Column(children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    textField("Enter Username", Icons.person_2_outlined, false,
                        usernameController),
                    const SizedBox(
                      height: 30,
                    ),
                    textField("Enter Email adress", Icons.email_outlined, false,
                        emailController),
                    const SizedBox(
                      height: 30,
                    ),
                    textField(
                        "Enter Password", Icons.lock, true, passwordController),
                    const SizedBox(
                      height: 20,
                    ),
                    signInSignUpButton(context, false, () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text)
                          .then((value) {
                        print("Succesful account creation");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                      FirebaseFirestore.instance
                          .collection("Users")
                          .doc(emailController.text)
                          .set({'username: ': emailController.text.split('@')});
                    }),
                  ])),
            )));
  }
}
