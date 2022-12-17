class Answer{
  final String answer;
  final double score;
  final int start;
  final int end;

  const Answer({
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