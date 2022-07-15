import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [Text('Friend List')])),
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
              List<Map<String, String>> friends = items
                  .map((i) =>
                      {'name': i['name'] as String, 'uid': i['uid'] as String})
                  .where((element) => element['uid'] != user.uid)
                  .toList();
              return chatmatesList(friends);
            }
          }),
    );
  }
}

Widget chatmatesList(List<Map<String, String>> chatmates) {
  return Scaffold(
      body: ListView.builder(
    itemCount: chatmates.length * 2,
    padding: const EdgeInsets.all(16.0),
    itemBuilder: (context, i) {
      if (i.isOdd) return const Divider();

      final index = i ~/ 2;

      return ListTile(
          title: Text(
            chatmates[index]['name']!,
            style: const TextStyle(fontSize: 18, color: Color(0xFF000000)),
          ),
          leading: const Icon(
            Icons.chat_bubble,
            color: Colors.blueAccent,
            semanticLabel: 'Filter categories',
          ),
          onTap: () {});
    },
  ));
}
