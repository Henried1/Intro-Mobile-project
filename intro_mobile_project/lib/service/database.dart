import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(String email, String username) async {
    await _db.collection("Users").doc(email).set({
      'Email': email,
      'Username': username,
    });
  }

  final CollectionReference bookingCollection =
      FirebaseFirestore.instance.collection('bookings');

  Stream<QuerySnapshot> getBookedSlots() {
    DateTime today = DateTime.now();
    DateTime end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return _db
        .collection('bookings')
        .where('dateTime', isGreaterThanOrEqualTo: today)
        .where('dateTime', isLessThanOrEqualTo: end)
        .snapshots();
  }

  Future<bool> addBooking(
      String email,
      DateTime date,
      int players,
      String fieldName,
      String fieldLocation,
      int timeslotIndex,
      bool isPrivate) async {
    String bookingId = "${date.toIso8601String()}_$timeslotIndex$fieldName";
    DocumentSnapshot bookingSnapshot =
        await _db.collection("BookedSlots").doc(bookingId).get();

    if (bookingSnapshot.exists) {
      return false;
    }

    await _db.collection("BookedSlots").doc(bookingId).set({
      'Email': email,
      'Date': date,
      'TimeslotIndex': timeslotIndex,
    });

    await _db.collection("Reservations").add({
      'Email': email,
      'Date': date,
      'Players': players,
      'CurrentPlayers': [email],
      'Field': fieldName,
      'Location': fieldLocation,
      'isPrivate': isPrivate,
    });

    return true;
  }

  Stream<QuerySnapshot> getPublicMatches() {
    return _db
        .collection('Reservations')
        .where('isPrivate', isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserMatches(String userEmail) {
    return _db
        .collection('Reservations')
        .where('CurrentPlayers', arrayContains: userEmail)
        .snapshots();
  }

  Future<void> joinMatch(String matchId, String userEmail) async {
    DocumentReference matchRef = _db.collection('Reservations').doc(matchId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot matchSnapshot = await transaction.get(matchRef);
      if (matchSnapshot.exists) {
        List currentPlayers = List.from(matchSnapshot['CurrentPlayers'] ?? []);
        int maxPlayers = matchSnapshot['Players'] ?? 0;
        if (!currentPlayers.contains(userEmail) &&
            currentPlayers.length < maxPlayers) {
          currentPlayers.add(userEmail);
          transaction.update(matchRef, {'CurrentPlayers': currentPlayers});
        }
      }
    });
  }
}
