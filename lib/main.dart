import 'package:flutter/material.dart';
import 'package:synology_image_viewer/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Welcome to Flutter', home: LoginScreen());
  }
}
