import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat/dash_chat.dart';

final ChatUser user = ChatUser(
  name: "Kojmas",
  uid: "2",
);

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return chatPanel();
  }
}

class chatPanel extends StatefulWidget {
  const chatPanel({Key? key}) : super(key: key);

  @override
  State<chatPanel> createState() => _chatPanelState();
}

class _chatPanelState extends State<chatPanel> {
  int currentlyDisplayed = -1;

  final ChatUser user = ChatUser(
    name: "Kojmas",
    uid: "2",
  );

  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  List<ChatMessage> messages = <ChatMessage>[];
  var m = <ChatMessage>[];
  String uid2 = '';

  void displayChatWindow(int index, List<Map<String, String>> chatmates) {
    setState(() {
      currentlyDisplayed = index;
    });
    _pushChatConversation(index, chatmates);
  }

  Widget chatmateConversation(
      String chatmate, String uid, BuildContext context) {
    TextEditingController fieldController = TextEditingController();

    void onSend(ChatMessage message) {
      print(message.toJson());
      message.customProperties = {'messageTo': uid};
      FirebaseFirestore.instance
          .collection('messages')
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(message.toJson());

      setState(() {
        messages.add(ChatMessage(
          text: message.text,
          createdAt: DateTime.now(),
          user: message.user,
        ));

        messages = [...messages];
      });
    }

    return Scaffold(
      appBar: AppBar(title: Row(children: [Text(chatmate)])),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .orderBy("createdAt")
              .snapshots(),
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
              messages = items
                  .map((i) =>
                      ChatMessage.fromJson(i.data()! as Map<dynamic, dynamic>))
                  .toList()
                  .where((i) =>
                      (i.user.uid == user.uid &&
                          i.customProperties!['messageTo'] == uid) ||
                      (i.user.uid == uid &&
                          i.customProperties!['messageTo'] == user.uid))
                  .toList();
              return DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: onSend,
                sendOnEnter: true,
                textInputAction: TextInputAction.send,
                user: user,
                inputDecoration:
                    InputDecoration.collapsed(hintText: "Add message here..."),
                dateFormat: DateFormat('yyyy-MMM-dd'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: false,
                showAvatarForEveryMessage: false,
                scrollToBottom: false,
                inputMaxLines: 5,
                messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                alwaysShowSend: true,
                inputTextStyle: TextStyle(fontSize: 16.0),
                inputContainerStyle: BoxDecoration(
                  border: Border.all(width: 0.0),
                  color: Colors.white,
                ),
                onQuickReply: (Reply reply) {
                  setState(() {
                    messages.add(ChatMessage(
                        text: reply.value,
                        createdAt: DateTime.now(),
                        user: user));

                    messages = [...messages];
                  });
                },
                onLoadEarlier: () {
                  print("laoding...");
                },
                shouldShowLoadEarlier: false,
                showTraillingBeforeSend: true,
              );
            }
          }),
    );
  }

  void _pushChatConversation(int index, List<Map<String, String>> chatmates) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return chatmateConversation(chatmates[index]['name'] as String,
              chatmates[index]['uid'] as String, context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              return chatmatesList(friends, displayChatWindow);
            }
          }),
    );
  }
}

Widget chatmatesList(
    List<Map<String, String>> chatmates, Function displayChatWindow) {
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
          onTap: () => displayChatWindow(index, chatmates));
    },
  ));
}
