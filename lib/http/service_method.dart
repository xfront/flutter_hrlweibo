import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_hrlweibo/public.dart';

class DioManager {
  Dio dio = Dio();

  DioManager._internal() {
    dio.options.baseUrl = Constant.baseUrl;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    dio.interceptors.add(LogInterceptor(responseBody: true)); //是否开启请求日志
    //  dio.interceptors.add(CookieManager(CookieJar()));//缓存相关类，具体设置见https://github.com/flutterchina/cookie_jar
  }

  static final DioManager _instance = DioManager._internal();

  factory DioManager() {
    return _instance;
  }

//get请求
  Future<Map<String, dynamic>> get(String url, Map params) {
    return _requestHttp(url, 'get', FormData.fromMap(params));
  }

  //post请求
  Future<Map<String, dynamic>> post(String url, Map params) {
    return _requestHttp(url, "post", FormData.fromMap(params));
  }

  //post请求
  Future<Map<String, dynamic>> postNoParams(String url) {
    return _requestHttp(url, "post", null);
  }

  Future<Map<String, dynamic>> _requestHttp(String url, [String method, params]) {
    Future<Response> futureRsp;
    if (method == 'get') {
      if (params != null) {
        futureRsp = dio.get(url, queryParameters: params);
      } else {
        futureRsp = dio.get(url);
      }
    } else if (method == 'post') {
      if (params != null) {
        futureRsp = dio.post(url, data: params);
      } else {
        futureRsp = dio.post(url);
      }
    }

    return futureRsp.then((response) {
      if (Constant.ISDEBUG) {
        print('请求url: ' + url);
        print('请求头: ' + dio.options.headers.toString());
        if (params != null) {
          print('请求参数: ' + params.toString());
        }
        if (response != null) {
          print('返回参数: ' + response.toString());
        }
      }

      String dataStr = json.encode(response.data);
      Map<String, dynamic> dataMap = json.decode(dataStr);
      if (dataMap == null || dataMap['status'] != 200) {
        return Future.error(Exception(dataMap['msg'].toString()));
      }
      return Future.value(dataMap);
    }, onError: (e) => throw e);
  }
}

Future request(url, {formData}) async {
  Response response;
  Dio dio = Dio();
  dio.options.contentType = ("application/json;charset=UTF-8");
  if (formData == null) {
    response = await dio.post(url);
  } else {
    response = await dio.post(url, data: formData);
  }

  /// 打印请求相关信息：请求地址、请求方式、请求参数
  print('请求地址：【' + '  ' + url + '】');
  print('请求参数：' + formData.toString());
  dio.interceptors.add(LogInterceptor(responseBody: true)); //是否开启请求日志

  // print('登录接口的返回值:'+response.data);

  if (response.statusCode == 200) {
    print('响应数据：' + response.toString());
    /*  var  obj=Map<String, dynamic>.from(response.data);
        int code=obj['status'];
        String msg=obj['msg'];
        if (code== 200) {
           Object data=obj['data'];
           return data;
        }else{
          ToastUtil.show(msg);
        }*/
    return response.data;
  } else {
    print('后端接口出现异常：');

    throw Exception('后端接口出现异常');
  }
}
