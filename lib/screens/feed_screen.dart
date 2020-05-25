import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/models/post_model.dart';
import 'package:flutter_instagram_clone/models/user_model.dart';
import 'package:flutter_instagram_clone/services/database_service.dart';
import 'package:flutter_instagram_clone/widgets/post_view.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  /// SETUP FEED is unnecessary because we switched it from a FutureBuilder to a StreamBuilder

  // List<Post> _posts = [];

  // @override
  // void initState() {
  //   super.initState();
  //   _setupFeed();
  // }

  // _setupFeed() async {
  //   List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
  //   setState(() {
  //     _posts = posts;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: DatabaseService.getFeedPosts(widget.currentUserId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          final List<Post> posts = snapshot.data;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = posts[index];
              return FutureBuilder(
                future: DatabaseService.getUserWithId(post.authorId),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  User author = snapshot.data;
                  return PostView(
                    currentUserId: widget.currentUserId,
                    post: post,
                    author: author,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
