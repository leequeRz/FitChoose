import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of users
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // CREATE: add a new user
  Future<bool> addUser({
    required String username,
    // required String gender,
  }) async {
    try {
      await users.add({
        'username': username,
        // 'gender': gender,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print("Failed to add user: $e");
      return false;
    }
  }
  // READ: get users from database

  // UPDATE: update user details

  // DELETE: delete a user
}
