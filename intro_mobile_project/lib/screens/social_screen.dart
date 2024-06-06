import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late Future<List<DocumentSnapshot>> usersFuture = fetchUsers();

  Future<List<DocumentSnapshot>> fetchUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    return querySnapshot.docs
        .where((doc) => doc.data()['Email'] != currentUser?.email)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Network'),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('following')
                      .doc(user.id)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      bool isFollowing = snapshot.data?.exists ?? false;
                      return ListTile(
                        title: Text(user['Username']),
                        subtitle: Text(user['Email']),
                        trailing: ElevatedButton(
                          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          onPressed: () async {
                            final currentUser =
                                FirebaseAuth.instance.currentUser;
                            if (isFollowing) {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(currentUser?.uid)
                                  .collection('following')
                                  .doc(user.id)
                                  .delete();
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.id)
                                  .collection('followers')
                                  .doc(currentUser?.uid)
                                  .delete();
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(currentUser?.uid)
                                  .collection('following')
                                  .doc(user.id)
                                  .set({});
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.id)
                                  .collection('followers')
                                  .doc(currentUser?.uid)
                                  .set({});
                            }
                            setState(() {
                              isFollowing = !isFollowing;
                            });
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
