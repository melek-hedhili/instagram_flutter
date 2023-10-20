import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: []);
      _firestore.collection("posts").doc(postId).set(post.toJson());
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid) async {
    try {
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      });
      print("post liked");
    } catch (e) {
      print(e);
    }
  }

  Future<void> unlikePost(String postId, String uid) async {
    try {
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
      print("post unliked");
    } catch (e) {
      print(e);
    }
  }

  Future<void> postComment(String postId, String uid, String username,
      String caption, String profilePic) async {
    try {
      if (caption.isNotEmpty) {
        String commentId = Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'uid': uid,
          'commentId': commentId,
          'profilePic': profilePic,
          'username': username,
          'caption': caption,
          'datePublished': DateTime.now()
        });
        print("comment posted");
      } else {
        print("comment is empty");
      }
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }

  Future<void> likeComment(String postId, String commentId, String uid) async {
    try {
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        "likes": FieldValue.arrayUnion([uid])
      });
      print("comment liked");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> unlikeComment(
      String postId, String commentId, String uid) async {
    try {
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        "likes": FieldValue.arrayRemove([uid])
      });
      print("comment unliked");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      _firestore.collection('posts').doc(postId).delete();
      print("post deleted");
    } catch (e) {
      print(e.toString());
    }
  }
}
