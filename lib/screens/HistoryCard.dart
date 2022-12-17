import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swasearch/Context.dart';

class HistoryCard extends StatelessWidget {
  final Context _context;
  HistoryCard(this._context) ;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [

                  Text("${_context.question}",
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),),
                    Text(" Context : ${_context.context}",
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
              Padding(padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text("${_context.created}"),
                  const Spacer(),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                    child: const Text('Delete'),
                    onPressed: () {


                    },
                  ),

                ],
              )
              )

              
            ],
          ),

        ),
      );
  }
}
