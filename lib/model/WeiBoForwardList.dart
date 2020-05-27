import 'WeiBoDetail.dart';

class ForwardList {
  List<Forward> list;

  ForwardList({
    this.list,
  });

  ForwardList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = List<Forward>();
      json['list'].forEach((v) {
        list.add(Forward.fromJson(v));
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
