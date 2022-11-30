// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swasearch/Article.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'Article.dart';
import 'Answer.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      title: 'Swasearch',
      home: Scaffold(
        body: Center(child: SearchList()),
      ),
    );
  }
}

class SearchList extends StatefulWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  //late Future<List<Article>> futureArticles;
  var question = '';

  @override
  void initState() {
    super.initState();
  }


  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    var userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
    print(userCredential);
    return userCredential;

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  var loading = false;
  Future<List<Article>> fetchArticles(String country) async {

    if (country == '') {
      return <Article>[];
    }
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=' + country));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var dec = jsonDecode(response.body);
      var result = <Article>[];
      for (var i = 0; i < dec.length; i = i + 1) {
        result.add(Article.fromJson(dec[i]));
      }
      print(result);
      loading=false;
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void goToCustomSearch() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => Inference()));
  }

  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    var _controller = TextEditingController();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          question = _controller.value.text;
                        });
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  goToCustomSearch();
                },
                icon: Icon(Icons.search))
          ],
        ),
        body: Center(
          child: FutureBuilder<List<Article>>(
            future: question == '' ? null : fetchArticles(question),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(loading){
                  return CircularProgressIndicator();
                }
                return ListView.builder(
                  itemBuilder: (context, index) {
                    var title = snapshot.data?[index].title;
                    return Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.check_circle),
                            title: Text(title!),
                            subtitle: const Text(
                                'Music by Julie Gable. Lyrics by Sidney Stein.'),
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
                  },
                  padding: EdgeInsets.all(16.0),
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
        ),
      ),
    );
  }
}

class Inference extends StatefulWidget {
  const Inference({Key? key}) : super(key: key);

  @override
  State<Inference> createState() => _InferenceState();
}

class _InferenceState extends State<Inference> {
  var question='';
  var loading=false;

  Future<Answer> fetchArticles(String question) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(
        'https://www.boredapi.com/api/activity'));

    if (response.statusCode == 200) {
      var dec = jsonDecode(response.body);
      var result =Answer.fromJson(dec);
      loading=false;
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    var controller=TextEditingController();
    return MaterialApp(
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
        body: Center(
            child: Column(
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
                            });
                          },
                          child: Text("Submit")),
                    )
                  ],
                ),
              ),
                  FutureBuilder<Answer>(
                    future: question == '' ? null : fetchArticles(question),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var answer=snapshot.data?.title;

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
            ])),
      ),
    );
  }
}
