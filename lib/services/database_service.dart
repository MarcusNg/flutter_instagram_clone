import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/models/activity_model.dart';
import 'package:flutter_instagram_clone/models/comment_model.dart';
import 'package:flutter_instagram_clone/models/post_model.dart';
import 'package:flutter_instagram_clone/models/user_model.dart';
import 'package:flutter_instagram_clone/utilities/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersRef.document(user.id).updateData({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users =
        usersRef.where('name', isGreaterThanOrEqualTo: name).getDocuments();
    return users;
  }

  static void createPost(Post post) {
    postsRef.document(post.authorId).collection('userPosts').add({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
    });
  }

  static void followUser({String currentUserId, String userId}) {
    // Add user to current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .setData({});
    // Add current user to user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
  }

  static void unfollowUser({String currentUserId, String userId}) {
    // Remove user from current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // Remove current user from user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    return followingDoc.exists;
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection('userFollowing')
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection('userFollowers')
        .getDocuments();
    return followersSnapshot.documents.length;
  }

  static Future<List<Post>> getFeedPosts(String userId) async {
    QuerySnapshot feedSnapshot = await feedsRef
        .document(userId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        feedSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        userPostsSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.document(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  static void likePost({String currentUserId, Post post}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount + 1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .setData({});
      addActivityItem(currentUserId: currentUserId, post: post, comment: null);
    });
  }

  static void unlikePost({String currentUserId, Post post}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount - 1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  static Future<bool> didLikePost({String currentUserId, Post post}) async {
    DocumentSnapshot userDoc = await likesRef
        .document(post.id)
        .collection('postLikes')
        .document(currentUserId)
        .get();
    return userDoc.exists;
  }

  static void commentOnPost(
      {String currentUserId, Post post, String comment}) {
    commentsRef.document(post.id).collection('postComments').add({
      'content': comment,
      'authorId': currentUserId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
    addActivityItem(currentUserId: currentUserId, post: post, comment: comment);
  }

  static void addActivityItem(
      {String currentUserId, Post post, String comment}) {
    if (currentUserId != post.authorId) {
      activitiesRef.document(post.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'postId': post.id,
        'postImageUrl': post.imageUrl,
        'comment': comment,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .document(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Activity> activity = userActivitiesSnapshot.documents
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activity;
  }

  static Future<Post> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .document(postId)
        .get();
    return Post.fromDoc(postDocSnapshot);
  }

}
