class Answer{
  String answer;
  double? score;
  int? start;
  int? end;

  Answer({
    required this.answer,
    required this.score,
    required this.start,
    required this.end,

  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answer: json['answer'],
      score: json['score'],
      end: json['end'],
      start: json['start'],

    );
  }

}