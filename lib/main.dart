import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_view_un.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}
