//hier gaan we widgets zetten die ongeveer overal moeten staan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intro_mobile_project/model/user_account.dart';

Stream<UserAccount> readUserByLive(String email) {
  final docUser = FirebaseFirestore.instance.collection('users').doc(email);
  return docUser.snapshots().map((snapshot) {
    if (snapshot.exists) {
      return UserAccount.fromJson(snapshot.data()!);
    } else {
      return UserAccount(
        id: '',
        email: '',
        password: '',
        username: '',
      );
    }
  });
}

Future<UserAccount?> readUserOnce(String userEmail) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(userEmail);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    return UserAccount.fromJson(snapshot.data()!);
  }
  return null;
}
