
class Context {
  final String context;
  final String question;
  final String answer;
  final int score;



  const Context({
    required this.context,
    required this.question,
    required this.answer,
    required this.score,



  });

  factory Context.fromJson(Map<String, dynamic> json) {
    return Context(
      context: json['context'],
      question: json['url'],
      answer: json['answer'],
      score: json['score'],

    );
  }
}