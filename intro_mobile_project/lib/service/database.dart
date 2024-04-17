class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(String email, String username) async {
    await _db.collection("Users").doc(email).set({
      'Email: ': email,
      'Username: ': username,
    });
  }
}
