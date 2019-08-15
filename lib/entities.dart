class Friend {
  const Friend({this.name});

  final String name;
}

class Comment {
  const Comment(this.text,this.poster,{this.replyer});

  final String text;

  final Friend poster;

  final Friend replyer;

}
