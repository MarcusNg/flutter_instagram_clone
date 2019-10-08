import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/models/user_model.dart';
import 'package:flutter_instagram_clone/services/database_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _bio = '';

  @override
  void initState() { 
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Update user in database
      String _profileImageUrl = '';
      User user = User(
        id: widget.user.id,
        name: _name,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
      );
      // Database update
      DatabaseService.updateUser(user);
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60.0,
                    backgroundImage:
                        NetworkImage('https://i.redd.it/dmdqlcdpjlwz.jpg'),
                  ),
                  FlatButton(
                    onPressed: () => print('Change profile image'),
                    child: Text(
                      'Change Profile Image',
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 16.0),
                    ),
                  ),
                  TextFormField(
                    initialValue: _name,
                    style: TextStyle(fontSize: 18.0),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        size: 30.0,
                      ),
                      labelText: 'Name',
                    ),
                    validator: (input) => input.trim().length < 1
                        ? 'Please enter a valid name'
                        : null,
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    initialValue: _bio,
                    style: TextStyle(fontSize: 18.0),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.book,
                        size: 30.0,
                      ),
                      labelText: 'Bio',
                    ),
                    validator: (input) => input.trim().length > 150
                        ? 'Please enter a bio less than 150 characters'
                        : null,
                    onSaved: (input) => _bio = input,
                  ),
                  Container(
                    margin: EdgeInsets.all(40.0),
                    height: 40.0,
                    width: 250.0,
                    child: FlatButton(
                      onPressed: _submit,
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
