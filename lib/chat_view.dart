import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:dash_chat/dash_chat.dart';

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

  // final ChatUser user = ChatUser(
  //   name: "Jan Papież 2",
  //   uid: "1",
  //   );

  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  List<ChatMessage> messages = <ChatMessage>[];
  var m = <ChatMessage>[];
  String uid2 = '';

  //Name specifies from who the text has been sent
  List<Map<String, Object>> chatmateMessages = [
    {
      'Id': 0,
      'Name': 'Jarek',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 1,
      'Name': 'Jarek',
      'Content': "Z chęcią Ci pomogę.",
      'Time': DateTime.now()
    },
    {
      'Id': 2,
      'Name': 'Kacper',
      'Content': "Wszystko będzie dorze.",
      'Time': DateTime.now()
    },
    {
      'Id': 3,
      'Name': 'Jarek',
      'Content': "On nie wiedział o...",
      'Time': DateTime.now()
    },
    {
      'Id': 4,
      'Name': 'Wojciech Fiołka',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 5,
      'Name': 'Paweł 2',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 6,
      'Name': 'Wojciech Fiołka',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
  ];

  //Name specifies to who the text hase been sent
  List<Map<String, Object>> userMessages = [
    {
      'Id': 0,
      'Name': 'Jarek',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 1,
      'Name': 'KAcper',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 2,
      'Name': 'Jarek',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 3,
      'Name': 'Jan',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 4,
      'Name': 'Paweł 2',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 5,
      'Name': 'Wojciech Fiołka',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
    {
      'Id': 6,
      'Name': 'Wojciech Fiołka',
      'Content': "Witaj kumplu!",
      'Time': DateTime.now()
    },
  ];

  // List<String> chatmates = [
  //   'Jarek',
  //   'Kacper',
  //   'Jan',
  //   'Paweł 2',
  //   'Wojciech Fiołka'
  // ];

  void displayChatWindow(int index, List<Map<String, String>> chatmates) {
    setState(() {
      currentlyDisplayed = index;
    });
    _pushChatConversation(index, chatmates);
  }

  Widget chatmateConversation(String chatmate, String uid,
      List<ChatMessage> messages, BuildContext context) {
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
              List<ChatMessage> messages = items
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
          return chatmateConversation(
              chatmates[index]['name'] as String,
              chatmates[index]['uid'] as String,
              getMessages(chatmates[index]['uid'] as String),
              context);
        },
      ),
    );
  }

  List<ChatMessage> getMessages(String chatmate) {
    List<Map<String, Object>> filteredChatmateMessages = chatmateMessages
        .where((element) => element['Name'] == chatmate)
        .toList();

    List<ChatMessage> chatmateWidgets = filteredChatmateMessages
        .map((e) => ChatMessage(
            text: e['Content'] as String,
            user: ChatUser(name: e['Name'] as String, uid: '0'),
            createdAt: e['Time'] as DateTime))
        .toList();

    List<Map<String, Object>> filteredUserMessages =
        userMessages.where((element) => element['Name'] == chatmate).toList();

    List<ChatMessage> userWidgets = filteredUserMessages
        .map((e) => ChatMessage(
              text: e['Content'] as String,
              user: ChatUser(name: 'Jan Paweł 2', uid: '1'),
              createdAt: e['Time'] as DateTime,
            ))
        .toList();

    chatmateWidgets.addAll(userWidgets);

    chatmateWidgets.sort((e1, e2) =>
        (e1 as ChatMessage).createdAt.compareTo((e2 as ChatMessage).createdAt));

    return chatmateWidgets;
  }

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
