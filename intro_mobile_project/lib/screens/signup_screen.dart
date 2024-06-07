import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'dart:io';
import 'dart:math';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as custom;
import 'package:intro_mobile_project/widgets/Registration&InlogWidget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profilePicture;
  Color? avatarColor;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    avatarColor = getRandomColor();
  }

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
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: avatarColor,
                  backgroundImage: _profilePicture != null
                      ? FileImage(_profilePicture!)
                      : null,
                  child: _profilePicture == null
                      ? Text(
                          usernameController.text.isNotEmpty
                              ? usernameController.text[0].toUpperCase()
                              : '',
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Username',
                    labelStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.person_2_outlined, color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                  obscureText: false,
                  controller: usernameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Email address',
                    labelStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.email_outlined, color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
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
                  decoration: const InputDecoration(
                    labelText: 'Enter Password',
                    labelStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.lock, color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
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
                signInSignUpButton(context, false, () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text.toLowerCase(),
                              password: passwordController.text);

                      await FirestoreService().addUser(
                          emailController.text.toLowerCase(),
                          usernameController.text.toLowerCase());

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const custom.NavigationBar()),
                      );
                    } catch (e) {
                      // Handle errors, e.g., show a Snackbar with error message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to sign up: $e'),
                      ));
                    }
                  }
                }),
                signInOption()
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Row signInOption() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Already have an account?",
          style: TextStyle(color: Colors.black)),
      GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignInScreen()));
        },
        child: const Text(
          " Sign in",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }

  Color getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}
