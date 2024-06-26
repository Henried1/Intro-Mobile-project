import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intro_mobile_project/screens/signup_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as custom;
import 'package:intro_mobile_project/widgets/Registration&InlogWidget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? emailError;
  String? passwordError;

  // Function to handle sign-in
  void signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          emailError = 'Email or password cannot be empty.';
          passwordError = null;
        });
        return;
      }

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const custom.NavigationBar()),
          );
        } else {
          setState(() {
            emailError = 'Sign-in failed. Please try again.';
            passwordError = null;
          });
        }
      } catch (e) {
        print('Sign-in error: $e');
        setState(() {
          emailError = null;
          passwordError = 'Invalid credentials. Please try again.';
        });
      }
    }
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
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                logoWidget("assets/images/logo.png"),
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
                  onChanged: (_) {
                    setState(() {
                      emailError = null;
                    });
                  },
                ),
                if (emailError != null)
                  Text(
                    emailError!,
                    style: TextStyle(color: Colors.red),
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
                  onChanged: (_) {
                    setState(() {
                      passwordError = null;
                    });
                  },
                ),
                if (passwordError != null)
                  Text(
                    passwordError!,
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, signIn),
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
