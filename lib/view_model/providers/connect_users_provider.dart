import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allUsersProvider = StreamProvider<List<ChatUser>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  });
});
final followingUsersProvider =
    StreamProvider.family<Set<String>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('following')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.id).toSet();
  });
});

final followUserProvider = Provider((ref) {
  return (String currentUserId, String userIdToFollow) async {
    try {
      // Add the user to the 'my_users' subcollection of the current user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(userIdToFollow)
          .set({'timeStamp': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userIdToFollow)
          .set({'timeStamp': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdToFollow)
          .collection('follower')
          .doc(currentUserId)
          .set({'timeStamp': Timestamp.now()});

      return true; // Indicate the follow action was successful
    } catch (e) {
      // If there's an error, you can handle it here
      return false; // Indicate the follow action failed
    }
  };
});