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
import 'package:swasearch/Context.dart';
import 'package:swasearch/screens/History.dart';

import '../Answer.dart';

class Inference extends StatefulWidget {
  const Inference({Key? key, required User user})
      : _user = user,
        super(key: key);
  final User _user;
  @override
  State<Inference> createState() => _InferenceState();
}

class _InferenceState extends State<Inference> {
  late User _user;
  var question = '';
  var sContext = '';
  var _loading = false;
  var controller = TextEditingController();
  var contextController = TextEditingController();

  Answer _answer = Answer(
    answer: '',
    score: null,
    start: null,
    end: null,
  );
  Context _context = Context();

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  Future<Answer> fetchArticles(String question, String context) async {
    setState(() {
      _loading = true;
    });
    final response = await http.get(Uri.parse(
      'http://34.79.199.157/qa?question=$question&context=$context',
    ));

    if (response.statusCode == 200) {
      var dec = jsonDecode(response.body);
      var result = Answer.fromJson(dec);
      _loading = false;
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
    final usersQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.email)
        .collection("searchHistory")
        .orderBy("Date");

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
          body: Row(
            children: [
              Expanded(
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
                                  hintText: "Question",
                                  border: OutlineInputBorder()),
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
                                  hintText: "Context",
                                  border: OutlineInputBorder()),
                              minLines: 5,
                              maxLines: 20,
                            ),
                          ),
                          Center(
                            child: TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(5)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered))
                                        return Colors.blue.withOpacity(0.4);
                                      if (states.contains(
                                              MaterialState.focused) ||
                                          states
                                              .contains(MaterialState.pressed))
                                        return Colors.blue.withOpacity(0.12);
                                      return null; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  _answerQuestion(controller.value.text,
                                      contextController.value.text);
                                },
                                child: Text("Get Answer")),
                          )
                        ],
                      ),
                    ),
                    _loading
                        ? const CircularProgressIndicator()
                        : AnswerWidget(answer: _answer),
                  ])),
              Expanded(

                  child: Column(
                      children:[
                        History(
                          callback: (Context acontext){
                            _setFields(acontext);

                          },
                user: _user,
              )]))
            ],
          )),
    );
  }

  Future<void> _answerQuestion(question, acontext) async {
    Answer answer = await fetchArticles(question, acontext);

    setState(() {
      _loading = false;
      _answer = answer;
    });

    _context.answer = answer.answer;
    _context.question = question;
    _context.context = acontext;
    _context.created = DateTime.now();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_user.email)
        .collection("History")
        .add(_context.toJson());
  }

  void _setFields(Context acontext) {
    controller.text=acontext.question!;
    contextController.text=acontext.context!;

  }
}

class AnswerWidget extends StatelessWidget {
  const AnswerWidget({
    Key? key,
    required this.answer,
  }) : super(key: key);

  final Answer? answer;

  @override
  Widget build(BuildContext context) {
    return answer?.answer == ''
        ? const Text("You have not searched for anything yet")
        : Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(
                    "Answer : ${answer!.answer}",
                    style: const TextStyle(
                        color: Color(0xff877d12),
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  subtitle: Text("Accuracy : ${answer!.score.toString()}"),
                ),
              ],
            ),
          );
  }
}
