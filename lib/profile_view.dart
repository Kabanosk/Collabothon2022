// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Widget _profileImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/pope.png'),
            fit: BoxFit.fill,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cool profile'),
          // leading: Text(location!.longitude.toString()),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
          children: [
            _profileImage(),
            Text(
              'Jan Papież 2',
              style: TextStyle(fontSize: 25, letterSpacing: 1),
            ),
            Text('jp2gmd@gmail.com',
                style: TextStyle(fontSize: 25, letterSpacing: 1)),
            Row(
              children: [
                TextButton(
                    child: Text('Switch\n profile role',
                        textAlign: TextAlign.center),
                    onPressed: () => {},
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        textStyle: TextStyle(fontSize: 17))),
                TextButton(
                    child: Text('Wyloguj'),
                    onPressed: () => {},
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.all(30),
                        textStyle: TextStyle(fontSize: 17))),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ))));
  }
}
