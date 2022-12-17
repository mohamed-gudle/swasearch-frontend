import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swasearch/Context.dart';
import 'package:swasearch/screens/HistoryCard.dart';

class History extends StatefulWidget {
  const History({Key? key, required User user, required Function(Context) callback}) :
        _user=user,
        callback=callback,
        super(key: key);
  final _user;
  final callback;
  @override
  State<History> createState() => _HistoryState();
}


class _HistoryState extends State<History> {
  List<Object> _historyList=[];
  late User _user;
  late Function(Context) callback;


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getUsersHistory();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user=widget._user;
    callback=widget.callback;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(child: ListView.builder(
      shrinkWrap: true,
      itemCount: _historyList.length,
        itemBuilder: (context,index){
        return GestureDetector(
          onTap: (){callback(_historyList[index] as Context);},
            child:HistoryCard(_historyList[index] as Context)
        );
        }
        ));
  }

  Future getUsersHistory() async{
    final userEmail=_user.email;
    var data=await FirebaseFirestore.instance
        .collection("users")
        .doc(userEmail)
        .collection("History")
        .orderBy("created",descending: true)
        .get();
    setState(() {
      _historyList=List.from(data.docs.map((doc)=>Context.fromSnapshot(doc)));
    });
  }
}
