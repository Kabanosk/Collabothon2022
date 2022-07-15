import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabothon/main_view_un.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:dash_chat/dash_chat.dart';
import './chat_view.dart';

bool isVolunteer = false;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return loginPanel();
  }
}

class loginPanel extends StatefulWidget {
  const loginPanel({Key? key}) : super(key: key);

  @override
  State<loginPanel> createState() => _loginPanelState();
}

class _loginPanelState extends State<loginPanel> {
  void chooseLogin(int index, List<Map<String, String>> profiles) {
    user.name = profiles[index]['name'];
    user.uid = profiles[index]['uid'];
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [Text('Choose your profile')])),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            } else {
              List<DocumentSnapshot> items = snapshot.data!.docs;
              List<Map<String, String>> profiles = items
                  .map((i) =>
                      {'name': i['name'] as String, 'uid': i['uid'] as String})
                  .toList();
              return chatmatesList(profiles, chooseLogin);
            }
          }),
    );
  }
}

Widget chatmatesList(List<Map<String, String>> profiles, Function chooseLogin) {
  return Scaffold(
      body: ListView.builder(
    itemCount: profiles.length * 2,
    padding: const EdgeInsets.all(16.0),
    itemBuilder: (context, i) {
      if (i.isOdd) return const Divider();

      final index = i ~/ 2;

      return ListTile(
          title: Text(
            profiles[index]['name']!,
            style: const TextStyle(fontSize: 18, color: Color(0xFF000000)),
          ),
          leading: const Icon(
            Icons.person,
            color: Colors.blueAccent,
            semanticLabel: 'Filter categories',
          ),
          onTap: () => chooseLogin(index, profiles));
    },
  ));
}
