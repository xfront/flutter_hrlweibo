import 'VedioCategory.dart';

class VedioCategoryList {
  int status;
  List<VedioCategory> data;

  VedioCategoryList({this.status, this.data});

  VedioCategoryList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = List<VedioCategory>();
      json['data'].forEach((v) {
        data.add(VedioCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
