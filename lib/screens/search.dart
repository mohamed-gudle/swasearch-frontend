
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swasearch/Article.dart';
import 'package:http/http.dart' as http;
import 'package:swasearch/screens/home.dart';
import '../Authentication.dart';
import 'inference.dart';

class SearchList extends StatefulWidget {
  const SearchList({Key? key, required User user}) :
        _user = user,
        super(key: key);
  final User _user;

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  late User _user;
  bool _isSigningOut= false;
  var loading = false;
  var _question='';
  final _controller = TextEditingController();

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


  @override
  void initState() {
    _user= widget._user;
    super.initState();

  }

  Future<List<Article>> fetchArticles(String question) async {
    if (question == '') {
      return <Article>[];
    }
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(
        'http://34.79.199.157/search?question=$question'));

    if (response.statusCode == 200) {

      var dec = jsonDecode(response.body);
      var result = <Article>[];
      for (var i = 0; i < dec.length; i = i + 1) {
        result.add(Article.fromJson(dec[i]));

      }
      loading=false;
      return result;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  void _goToCustomSearch() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => Inference(user:_user)));
  }

  @override
  Widget build(BuildContext context) {


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
                onSubmitted: (value){
                  _question=_controller.value.text;
                },
                controller: _controller,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _question = _controller.value.text;
                        });
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          ),
          actions: [
            TextButton(
               onPressed: (){_goToCustomSearch();},
                child: const Text("Custom Search")
            ),
            _isSigningOut ?
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ) :
            TextButton(onPressed: ()async {
              setState(() {
                _isSigningOut = true;
              });
              await Authentication.signOut(context: context);
              setState(() {
                _isSigningOut = false;
              });
              Navigator.of(context)
                  .pushReplacement(_routeToSignInScreen());
            }, child: const Text("Sign Out")),
          ],
        ),
        body: Center(
          child: FutureBuilder<List<Article>>(
            future: _question == '' ? null : fetchArticles(_question),
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

              return const Text("You have not asked anything yet,\n search the answer to any swahili question and we shall retrieve it from the internet");
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