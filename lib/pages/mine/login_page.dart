import "package:dio/dio.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hrlweibo/constant/constant.dart';
import 'package:flutter_hrlweibo/http/service_method.dart';
import 'package:flutter_hrlweibo/public.dart';
import 'package:flutter_hrlweibo/util/sp_util.dart';
import 'package:flutter_hrlweibo/util/toast_util.dart';

import '../../widget/textfield/TextFieldAccount.dart';
import '../../widget/textfield/TextFieldPwd.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

String _inputAccount = "";
String _inputPwd = "";

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    //登录时保存软键盘高度,在聊天界面第一次弹出底部布局时使用
    final keyHeight = MediaQuery
      .of(context)
      .viewInsets
      .bottom;
    if (keyHeight != 0) {
      print("键盘高度是:" + keyHeight.toString());
      SpUtil.putDouble(Constant.SP_KEYBOARD_HEGIHT, keyHeight);
    }

    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DropdownButtonHideUnderline(
          child: ListView(
            children: <Widget>[
              // CupertinoActivityIndicator(),
              buildTile(),
              Container(
                margin:
                const EdgeInsets.only(left: 20.0, top: 30.0, bottom: 20),
                child: Text(
                  "请输入账号密码",
                  style: TextStyle(fontSize: 24.0, color: Colors.black),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: AccountEditText(
                  contentStrCallBack: (content) {
                    _inputAccount = content;
                    setState(() {});
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: PwdEditText(
                  contentStrCallBack: (content) {
                    _inputPwd = content;
                    setState(() {});
                  },
                ),
              ),
              buildLoginBtn(),
              buildRegistForget(),
              buildOtherLoginWay(),
            ],
          ),
        )),
    );
  }

  Widget buildTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, //子组件的排列方式为主轴两端对齐
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              Constant.ASSETS_IMG + 'icon_close.png',
              width: 20.0,
              height: 20.0,
            )),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "帮助",
              style: TextStyle(fontSize: 16.0, color: Color(0xff6B91BB)),
            )),
          onTap: () {},
        ),
      ],
    );
  }

  Widget buildLoginBtn() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
      child: RaisedButton(
        color: Color(0xffFF8200),
        textColor: Colors.white,
        disabledTextColor: Colors.white,
        disabledColor: Color(0xffFFD8AF),
        elevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        onPressed: (_inputAccount.isEmpty || _inputPwd.isEmpty) ? null : () {
          var params = {'username': _inputAccount, 'password': _inputPwd};
          DioManager().post(ServiceUrl.login, params).then((data) {
            UserUtil.saveUserInfo(data['data']);
            ToastUtil.show('登录成功!');
            Navigator.pop(context);
            Routes.navigateTo(context, Routes.indexPage);
          }, onError: (error) {
            ToastUtil.show(error);
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: Text(
            "登  录",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  //注册,忘记密码
  Widget buildRegistForget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, //子组件的排列方式为主轴两端对齐
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 3),
            child: Text(
              "注册",
              style: TextStyle(fontSize: 13.0, color: Color(0xff6B91BB)),
            )),
          onTap: () {},
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 3),
            child: Text(
              "忘记密码",
              style: TextStyle(fontSize: 13.0, color: Color(0xff6B91BB)),
            )),
          onTap: () {
            Routes.navigateTo(context, Routes.chatPage,
              transition: TransitionType.fadeIn);
          },
        ),
      ],
    );
  }

  //其他登陆方式
  Widget buildOtherLoginWay() {
    return Container(
      margin: EdgeInsets.only(top: 150),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  color: Color(0xffEAEAEA),
                  height: 1,
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  child: Center(
                    child: Text(
                      '其他登陆方式',
                      style:
                      TextStyle(fontSize: 12, color: Color(0xff999999)),
                    ),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                  color: Color(0xffEAEAEA),
                  height: 1,
                ),
                flex: 1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20, top: 10),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      Constant.ASSETS_IMG + 'login_weixin.png',
                      width: 40.0,
                      height: 40.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        '微信',
                        style:
                        TextStyle(fontSize: 12, color: Color(0xff999999)),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 10),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      Constant.ASSETS_IMG + 'login_qq.png',
                      width: 40.0,
                      height: 40.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        'QQ',
                        style:
                        TextStyle(fontSize: 12, color: Color(0xff999999)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ));
  }
}
