
import 'dart:async';
import 'dart:convert';


import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:swasearch/Article.dart';

import 'package:http/http.dart' as http;

import '../Answer.dart';

class Inference extends StatefulWidget {
  const Inference({Key? key}) : super(key: key);

  @override
  State<Inference> createState() => _InferenceState();
}

class _InferenceState extends State<Inference> {
  var question='';
  var sContext='';
  var loading=false;


  Future<Answer> fetchArticles(String question,String context) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(
      'http://34.140.165.64/qa?question=$question&context=$context',));

    if (response.statusCode == 200) {
      var dec = jsonDecode(response.body);
      var result =Answer.fromJson(dec);
      loading=false;
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load articles');
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final usersQuery = FirebaseFirestore.instance.collection('users').orderBy('name');

    if (FirebaseAuth.instance.currentUser != null) {
      goBack();
    }
    var controller=TextEditingController();
    var contextController=TextEditingController();
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        fontFamily: "overlock",
      ),
      home: Scaffold(

        appBar: AppBar(
          title: const Text("Direct Inference"),
          actions: [
            IconButton(
                onPressed: () {
                  goBack();
                },
                icon: const Icon(Icons.arrow_back))
          ],
        ),
        body:
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                                hintText: "Question", border: OutlineInputBorder()),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: contextController,
                            decoration: const InputDecoration(
                                hintText: "Context", border: OutlineInputBorder()),
                            minLines: 5,
                            maxLines: 20,
                          ),
                        ),
                        Center(
                          child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                                foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                                overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.blue.withOpacity(0.4);
                                    if (states.contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.blue.withOpacity(0.12);
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  question = controller.value.text;
                                  sContext = contextController.value.text;
                                });
                              },
                              child: Text("Submit")),
                        )
                      ],
                    ),
                  ),
                  FutureBuilder<Answer>(
                    future: question == '' ? null : fetchArticles(question,sContext),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var answer=snapshot.data?.answer;

                        if(loading){
                          return CircularProgressIndicator();
                        }
                        return Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.check_circle),
                                title: Text(answer!),
                                subtitle: Text(answer),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    child: const Text('BUY TICKETS'),
                                    onPressed: () {/* ... */},
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: const Text('LISTEN'),
                                    onPressed: () {/* ... */},
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      if (loading){
                        return const CircularProgressIndicator();
                      }

                      return const Text("You have not searched for anything yet");
                    },
                  ),
                ]),


      ),
    );
  }
}