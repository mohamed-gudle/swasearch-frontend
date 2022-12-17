import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swasearch/screens/search.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var authorized=false;




  Future<UserCredential> _signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    var userCredential =
    await FirebaseAuth.instance.signInWithPopup(googleProvider);
    setState(() {
      authorized=true;
    });
    _goToSearch();

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    return userCredential;
  }

  void _goToSearch() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => SearchList()));
  }

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
            children: [Image.asset('assets/images/1.png',width: 500.0,height: 300.0,),
              TextButton(

                onPressed:  _goToSearch,
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xFF926F34)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.all(10)),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    height: 1.0,
                    fontSize: 20,
                    color: Colors.white,

                  ),
                ),
              )],
          ),

        ),
      ),
    );
  }
}