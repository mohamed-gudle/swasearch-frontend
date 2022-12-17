import 'package:flutter/material.dart';
import '/GoogleSignInButton.dart';


import '../Authentication.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        fontFamily: "overlock",
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 500.0,
                height: 300.0,
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0x00000000),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
