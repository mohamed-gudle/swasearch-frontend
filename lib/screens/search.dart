
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swasearch/Article.dart';

import 'package:http/http.dart' as http;

import 'inference.dart';

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

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

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
        'http://34.140.165.64/search?question=$question'));

    if (response.statusCode == 200) {

      var dec = jsonDecode(response.body);
      var result = <Article>[];
      for (var i = 0; i < dec.length; i = i + 1) {
        result.add(Article.fromJson(dec[i]));

      }
      loading=false;
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load articles');
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
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        fontFamily: "overlock",
        focusColor: const Color(0xFa997f30),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(5)),
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
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    var title = snapshot.data?[index].title;
                    var answer=snapshot.data?[index].answer;
                    return ListItem(title: title, answer: answer);
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

class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.title,
    required this.answer,
  }) : super(key: key);

  final String? title;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: answer!=""? const Icon(Icons.check_circle,color: Color(0xFa997f30),) : const Icon(Icons.abc),
            title: Text(title!),
            subtitle: Text(answer!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Visit Page'),
                onPressed: () {

                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}