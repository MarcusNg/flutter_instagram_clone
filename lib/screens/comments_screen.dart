import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/models/comment_model.dart';
import 'package:flutter_instagram_clone/models/post_model.dart';
import 'package:flutter_instagram_clone/models/user_data.dart';
import 'package:flutter_instagram_clone/models/user_model.dart';
import 'package:flutter_instagram_clone/services/database_service.dart';
import 'package:flutter_instagram_clone/utilities/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final int likeCount;

  CommentsScreen({this.post, this.likeCount});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;

  _buildComment(Comment comment) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(comment.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User author = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.grey,
            backgroundImage: author.profileImageUrl.isEmpty
                ? AssetImage('assets/images/user_placeholder.jpg')
                : CachedNetworkImageProvider(author.profileImageUrl),
          ),
          title: Text(author.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(comment.content),
              SizedBox(height: 6.0),
              Text(
                DateFormat.yMd().add_jm().format(comment.timestamp.toDate()),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildCommentTF() {
    final currentUserId = Provider.of<UserData>(context).currentUserId;
    return IconTheme(
      data: IconThemeData(
        color: _isCommenting
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (comment) {
                  setState(() {
                    _isCommenting = comment.length > 0;
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Write a comment...'),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_isCommenting) {
                    DatabaseService.commentOnPost(
                      currentUserId: currentUserId,
                      post: widget.post,
                      comment: _commentController.text,
                    );
                    _commentController.clear();
                    setState(() {
                      _isCommenting = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '${widget.likeCount} likes',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          StreamBuilder(
            stream: commentsRef
                .document(widget.post.id)
                .collection('postComments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    Comment comment =
                        Comment.fromDoc(snapshot.data.documents[index]);
                    return _buildComment(comment);
                  },
                ),
              );
            },
          ),
          Divider(height: 1.0),
          _buildCommentTF(),
        ],
      ),
    );
  }
}
