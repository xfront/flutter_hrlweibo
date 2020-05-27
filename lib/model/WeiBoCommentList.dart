import 'WeiBoDetail.dart';

class CommentList {
  List<Comment> list;

  CommentList({
    this.list,
  });

  CommentList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = List<Comment>();
      json['list'].forEach((v) {
        list.add(Comment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
