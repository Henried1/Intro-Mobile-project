import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(String email, String username) async {
    await _db.collection("Users").doc(email).set({
      'Email: ': email,
      'Username: ': username,
    });
  }

  Future<void> addBooking(
      String email, DateTime date, int time, int players) async {
    await _db.collection("Reservations").add({
      'Email: ': email,
      'Date: ': date,
      'Time: ': time,
      'Players': players,
    });
  }
}
