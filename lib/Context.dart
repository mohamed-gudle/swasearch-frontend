
import 'Answer.dart';

class Context {
  String? context;
  String? question;
  String? answer;
  DateTime? created;

  Context();

  Map<String,dynamic> toJson()=> {'context':context, 'answer': answer,"created":created, "question":question};
  Context.fromSnapshot(snapshot)
      : context=snapshot.data()['context'],
        question=snapshot.data()['question'],
        answer=snapshot.data()['answer'],
        created=snapshot.data()['created'].toDate();

}