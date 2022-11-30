
class Article {
  final String title;
  final String url;
  final String answer;
  final String score;
  final String start;
  final String end;

  const Article({
    required this.title,
    required this.url,
    required this.answer,
    required this.score,
    required this.start,
    required this.end,

  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['name'],
      url: json['country'],
      answer: json['name'],
      score: json['country'],
      end: json['name'],
      start: json['name'],

    );
  }
}