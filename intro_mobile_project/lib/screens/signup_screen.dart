import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:intro_mobile_project/widgets/registration&InlogWidget.dart';
import 'dart:io';
import 'dart:math';

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
                /*  ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _profilePicture = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Pick Profile Picture'),
                ),*/
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
                    setState(
                        () {}); // This will trigger a rebuild of the widget tree
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
                    await FirestoreService()
                        .addUser(emailController.text, usernameController.text);
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
