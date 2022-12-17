
class Article {
  final String title;
  final String url;
  final String answer;
  final double score;


  const Article({
    required this.title,
    required this.url,
    required this.answer,
    required this.score,


  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      url: json['url'],
      answer: json['answer'],
      score: json['score'],

    );
  }
}