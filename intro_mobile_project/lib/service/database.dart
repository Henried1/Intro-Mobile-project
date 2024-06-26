import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(String email, String username) async {
    await _db.collection("Users").doc(email).set({
      'Email': email,
      'Username': username,
      'Following': [],
    });
  }

  Future<void> followUser(String currentUserEmail, String userEmail) async {
    DocumentReference currentUserRef =
        _db.collection("Users").doc(currentUserEmail);

    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);

        if (currentUserSnapshot.exists) {
          List<dynamic> following =
              List.from(currentUserSnapshot['Following'] ?? []);

          if (!following.contains(userEmail)) {
            following.add(userEmail);
            transaction.update(currentUserRef, {'Following': following});
          } else {}
        } else {}
      });
    } catch (e) {}
  }

  Future<void> unfollowUser(String currentUserEmail, String userEmail) async {
    DocumentReference currentUserRef =
        _db.collection("Users").doc(currentUserEmail);

    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);

        if (currentUserSnapshot.exists) {
          List<dynamic> following =
              List.from(currentUserSnapshot['Following'] ?? []);

          if (following.contains(userEmail)) {
            following.remove(userEmail);
            transaction.update(currentUserRef, {'Following': following});
          } else {}
        } else {}
      });
    } catch (e) {}
  }

  Stream<QuerySnapshot> getUsers() {
    return _db.collection('Users').snapshots();
  }

  final CollectionReference bookingCollection =
      FirebaseFirestore.instance.collection('bookings');

  Stream<QuerySnapshot> getBookedSlots(DateTime selectedDay) {
    DateTime startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0);
    DateTime endOfDay = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);

    return _db
        .collection('BookedSlots')
        .where('Date', isGreaterThanOrEqualTo: startOfDay)
        .where('Date', isLessThanOrEqualTo: endOfDay)
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
      'isEnded': false,
    });

    return true;
  }

  Stream<QuerySnapshot> getPublicMatches() {
    return _db
        .collection('Reservations')
        .where('isEnded', isEqualTo: false)
        .where('isPrivate', isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserMatches(String userEmail) {
    return _db
        .collection('Reservations')
        .where('CurrentPlayers', arrayContains: userEmail)
        .where('isEnded', isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getMatchHistory(String userEmail) {
    return _db
        .collection('MatchHistory')
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

  Future<void> leaveMatch(String matchId, String userEmail) async {
    DocumentReference matchRef = _db.collection('Reservations').doc(matchId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot matchSnapshot = await transaction.get(matchRef);
      if (matchSnapshot.exists) {
        List currentPlayers = List.from(matchSnapshot['CurrentPlayers'] ?? []);
        if (currentPlayers.contains(userEmail)) {
          currentPlayers.remove(userEmail);
          transaction.update(matchRef, {'CurrentPlayers': currentPlayers});
        }
      }
    });
  }

  Future<void> addMatchResult(String matchId, String result) async {
    DocumentReference matchRef = _db.collection('Reservations').doc(matchId);
    await matchRef.update({
      'Result': result,
    });

    DocumentSnapshot matchSnapshot = await matchRef.get();
    if (matchSnapshot.exists) {
      Map<String, dynamic> matchData =
          matchSnapshot.data() as Map<String, dynamic>;
      matchData['Result'] = result;
      await _db.collection('MatchHistory').doc(matchId).set(matchData);
    }
  }

  Future<void> setMatchWinner(String matchId, String winnerEmail) async {
    DocumentReference matchRef = _db.collection('Reservations').doc(matchId);
    await matchRef.update({
      'Winner': winnerEmail,
    });

    DocumentSnapshot matchSnapshot = await matchRef.get();
    if (matchSnapshot.exists) {
      Map<String, dynamic> matchData =
          matchSnapshot.data() as Map<String, dynamic>;
      matchData['Winner'] = winnerEmail;
      await _db.collection('MatchHistory').doc(matchId).set(matchData);
    }
  }

  Future<void> endMatch(String matchId, String userEmail) async {
    DocumentReference matchRef = _db.collection('Reservations').doc(matchId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot matchSnapshot = await transaction.get(matchRef);
      if (matchSnapshot.exists) {
        List currentPlayers = List.from(matchSnapshot['CurrentPlayers'] ?? []);
        if (currentPlayers.contains(userEmail)) {
          transaction.update(matchRef, {'isEnded': true});

          Map<String, dynamic> matchData =
              matchSnapshot.data() as Map<String, dynamic>;
          matchData['isEnded'] = true;
          await _db.collection('MatchHistory').doc(matchId).set(matchData);
        }
      }
    });
  }
}
