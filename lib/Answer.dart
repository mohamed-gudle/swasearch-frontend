class Answer{
  final String title;
  final String url;
  final String answer;
  final String score;
  final String start;
  final String end;

  const Answer({
    required this.title,
    required this.url,
    required this.answer,
    required this.score,
    required this.start,
    required this.end,

  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      title: json['activity'],
      url: json['country'],
      answer: json['name'],
      score: json['country'],
      end: json['name'],
      start: json['name'],

    );
  }

}