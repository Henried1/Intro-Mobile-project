import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
import 'package:intro_mobile_project/screens/signup_screen.dart';
import 'package:intro_mobile_project/utils/color_utils.dart';
import 'package:intro_mobile_project/widgets/registration&InlogWidget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                logoWidget("assets/images/logo.png"),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter Email address',
                    labelStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.email_outlined, color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.black),
                  obscureText: false,
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    labelStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.lock, color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text)
                        .then((value) {
                      print("Succesful sign in");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  }
                }),
                signUpOption(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have an account?",
          style: TextStyle(color: Colors.black)),
      GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()));
        },
        child: const Text(
          " Sign up",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }
}
