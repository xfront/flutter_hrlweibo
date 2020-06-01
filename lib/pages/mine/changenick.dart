import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hrlweibo/public.dart';
import 'package:flutter_hrlweibo/util/toast_util.dart';

//修改昵称界面
class ChangeNickNamePage extends StatefulWidget {
  @override
  _ChangeNickNamePageState createState() => _ChangeNickNamePageState();
}

class _ChangeNickNamePageState extends State<ChangeNickNamePage> {
  TextEditingController _mEtController = TextEditingController();

  //#F3F1F4
  String mInputName = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
          title: Text(
            '修改昵称',
            style: TextStyle(fontSize: 16),
          ),
          elevation: 0.5,
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xffF3F1F4),
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                color: Color(0xffffffff),
                margin: EdgeInsets.only(top: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _mEtController,
                    decoration: InputDecoration(
                      hintText: "请输入您的昵称",
                      hintStyle:
                      TextStyle(color: Color(0xff999999), fontSize: 16),
                      contentPadding: EdgeInsets.only(left: 15, right: 15),
                      border: InputBorder.none,
                    ),
                  ),
                )),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    "4-30个字符,支持中英文、数字",
                    style: TextStyle(
                      fontSize: 14.0, color: Color(0xff999999)),
                  ),
                )),
              Container(
                margin: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Color(0xffFF8200),
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    disabledColor: Color(0xffFFD8AF),
                    elevation: 0,
                    disabledElevation: 0,
                    highlightElevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25.0),
                        topLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                    ),
                    onPressed: () {
                      if (_mEtController.text.isEmpty) {
                        ToastUtil.show('昵称不能为空!');
                        return;
                      }
                      var params = {
                        'userId': UserUtil.getUserInfo().id,
                        'nick': _mEtController.text
                      };
                      DioManager()
                        .post(ServiceUrl.updateNick, params).then((data) {
                        ToastUtil.show('修改昵称成功!');
                        UserUtil.saveUserNick(_mEtController.text);
                        Constant.eventBus.fire(ChangeInfoEvent());
                        Navigator.pop(context);
                      }, onError: (error) {
                        ToastUtil.show(error);
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                      child: Text(
                        "修改",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
      ));
  }
}
