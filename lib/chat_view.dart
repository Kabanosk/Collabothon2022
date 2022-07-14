import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

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

  List<String> chatmates = [
    'Jarek',
    'Kacper',
    'Jan',
    'Paweł 2',
    'Wojciech Fiołka'
  ];

  void displayChatWindow(int index) {
    setState(() {
      currentlyDisplayed = index;
    });
  }

  List<Widget> getMessages(String chatmate) {
    List<Map<String, Object>> filteredChatmateMessages = chatmateMessages
        .where((element) => element['Name'] == chatmate)
        .toList();

    filteredChatmateMessages.sort((e1, e2) =>
        (e1['Time'] as DateTime).isBefore(e2['Time'] as DateTime) ? 1 : 0);

    List<Widget> chatmateWidgets = filteredChatmateMessages
        .map((e) => Container(
              child: Text(
                e['Content'] as String,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white, backgroundColor: Colors.blueAccent),
              ),
              width: MediaQuery.of(context).size.width,
            ))
        .toList();

    List<Map<String, Object>> filteredUserMessages =
        userMessages.where((element) => element['Name'] == chatmate).toList();

    filteredUserMessages.sort((e1, e2) =>
        (e1['Time'] as DateTime).isBefore(e2['Time'] as DateTime) ? 1 : 0);

    List<Widget> userWidgets = filteredUserMessages
        .map((e) => Container(
              child: Text(
                e['Content'] as String,
                textAlign: TextAlign.right,
                style:
                    TextStyle(color: Colors.blue, backgroundColor: Colors.grey),
              ),
              width: MediaQuery.of(context).size.width,
            ))
        .toList();
    chatmateWidgets.addAll(userWidgets);
    return chatmateWidgets;
  }

  @override
  Widget build(BuildContext) {
    return currentlyDisplayed == -1
        ? chatmatesList(chatmates, displayChatWindow)
        : chatmateConversation(
            chatmates[currentlyDisplayed],
            () => {displayChatWindow(-1)},
            getMessages(chatmates[currentlyDisplayed]),
            context);
  }
}

Widget chatmatesList(List<String> chatmates, Function displayChatWindow) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Recent contacts'),
      ),
      body: ListView.builder(
        itemCount: chatmates.length * 2,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;

          return ListTile(
              title: Text(
                chatmates[index],
                style: const TextStyle(fontSize: 18, color: Color(0xFF000000)),
              ),
              leading: const Icon(
                Icons
                    .chat_bubble, //można  z chatmates wyciągnąć rodzaj pomocy i wybrać ikonkę
                color: Colors.blueAccent,
                semanticLabel: 'Filter categories',
              ),
              onTap: () => displayChatWindow(index));
        },
      ));
}

Widget chatmateConversation(String chatmate, VoidCallback goBack,
    List<Widget> messages, BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: Row(children: [
      IconButton(onPressed: goBack, icon: Icon(Icons.arrow_back)),
      Text(chatmate)
    ])),
    body: SizedBox(
      child: SingleChildScrollView(child: Column(children: messages)),
      width: MediaQuery.of(context).size.width,
    ),
  );
}
