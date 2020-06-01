import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hrlweibo/model/MessageNormal.dart';
import 'package:flutter_hrlweibo/public.dart';
import 'package:flutter_hrlweibo/widget/messgae/bubble.dart';
import 'voice_animation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageItem extends StatefulWidget {
  HrlMessage message;
  ValueSetter<String> onAudioTap;

  ChatMessageItem({Key key, this.message, this.onAudioTap}) : super(key: key);

  @override
  ChatMessageItemState createState() => ChatMessageItemState();
}
class SpanInfo {
  int start;
  int end;
  int type;
  SpanInfo(this.start, this.end, {this.type});
}
class ChatMessageItemState extends State<ChatMessageItem> {
  List<String> mAudioAssetRightList = List();
  List<String> mAudioAssetLeftList = List();

  bool mIsPlayint = false;
  String mUUid = "";

  methodInChild(bool isPlay, String uid) {
    mIsPlayint = isPlay;
    mUUid = uid;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    mAudioAssetRightList.add(Constant.ASSETS_IMG + "audio_animation_list_right_1.png");
    mAudioAssetRightList.add(Constant.ASSETS_IMG + "audio_animation_list_right_2.png");
    mAudioAssetRightList.add(Constant.ASSETS_IMG + "audio_animation_list_right_3.png");

    mAudioAssetLeftList.add(Constant.ASSETS_IMG + "audio_animation_list_left_1.png");
    mAudioAssetLeftList.add(Constant.ASSETS_IMG + "audio_animation_list_left_2.png");
    mAudioAssetLeftList.add(Constant.ASSETS_IMG + "audio_animation_list_right_3.png");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: widget.message.isSend
        ? getSentMessageLayout()
        : getReceivedMessageLayout(),
    );
  }

  Widget getImageLayout(HrlImageMessage msg) {
    Widget child;
    if (msg.thumbPath != null && (msg.thumbPath.isNotEmpty)) {
      child = Image.file(File('${msg.thumbPath}'));
    } else {
      child = Image.network('${msg.thumbUrl}', fit: BoxFit.fill);
    }
    return child;
  }

  TextSpan buildText(String txt, TextStyle defaultStyle) {
    List<SpanInfo> spans = List();
    RegExp uri = new RegExp(r"[a-zA-z]+://[^\s]*");
    Iterable<Match> uris = uri.allMatches(txt);
    int last = 0;
    for (Match m in uris) {
      if (last < m.start ) spans.add(SpanInfo(last, m.start, type: -1));
      spans.add(SpanInfo(m.start, m.end, type: 0));
      last = m.end;
    }
    spans.add(SpanInfo(last, txt.length, type: -1));

    RegExp email = new RegExp(r"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*");
    Iterable<Match> emails = email.allMatches(txt);
    for (Match m in emails) {
      int idx = spans.indexWhere((e) => e.start <= m.start && m.end <= e.end );
      if (idx < 0) continue;
      SpanInfo info = spans.removeAt(idx);
      if (info.start < m.start ) spans.add(SpanInfo(info.start, m.start, type: -1));
      spans.add(SpanInfo(m.start, m.end, type: 1));
      if (m.end < info.end ) spans.add(SpanInfo(m.end, info.end, type: -1));
    }

    RegExp mobile = new RegExp(r"(0|86|17951)?(1\d{10})");
    Iterable<Match> mobiles = mobile.allMatches(txt);
    for (Match m in mobiles) {
      int idx = spans.indexWhere((e) => e.start <= m.start && m.end <= e.end );
      if (idx < 0) continue;
      SpanInfo info = spans.removeAt(idx);
      if (info.start < m.start ) spans.add(SpanInfo(info.start, m.start, type: -1));
      spans.add(SpanInfo(m.start, m.end, type: 2));
      if (m.end < info.end ) spans.add(SpanInfo(m.end, info.end, type: -1));
    }
    
    spans.sort((a, b){
      return a.start.compareTo(b.start);
    });
    
    List<TextSpan> txtSpans = List();
    for (SpanInfo si in spans) {
      TextSpan span ;
      var text = txt.substring(si.start, si.end);
      switch (si.type) {
        case 0:
          span = TextSpan(
            text: text,
            recognizer: TapGestureRecognizer()..onTap = () {
              launch(text);
            },
            style: defaultStyle.copyWith(decoration: TextDecoration.underline,color: Colors.blue));
            break;
        case 1:
          span = TextSpan(
            text: text,
            style: defaultStyle.copyWith(decoration: TextDecoration.underline,color: Colors.blue));
          break;
        case 2:
          span = TextSpan(text: text, style: defaultStyle.copyWith(color: Colors.red));
          break;
        default:
          span = TextSpan(text: text, style: defaultStyle);
          break;
      }
      txtSpans.add(span);
    }
    return TextSpan(children: txtSpans);
  }

  Widget getItemContent(HrlMessage msg) {
    switch (msg.msgType) {
      case HrlMessageType.image:
        return Container(
          /* width:mImgWidth,
          height: mImgHeight,*/
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: 150,
          ),
          child: getImageLayout(widget.message as HrlImageMessage),
        );
      case HrlMessageType.text:
        return SelectableText.rich(
          buildText('${(widget.message as HrlTextMessage).text}', TextStyle(fontSize: 16.0, color: Colors.black)),
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        );
      case HrlMessageType.voice:
        bool isStop = true;
        if (mUUid == widget.message.uuid) {
          if (!mIsPlayint) {
            isStop = true;
          } else {
            isStop = false;
          }
        } else {
          isStop = true;
        }

        //    print("是否停止:"+isStop.toString()+"widget.mUUid=:"+widget.mUUid );
        return GestureDetector(
          onTap: () {
            //  int result = await mAudioPlayer.play((widget.mMessage as HrlVoiceMessage).path, isLocal: true);
            widget.onAudioTap((widget.message as HrlVoiceMessage).path);
          },
          child: VoiceAnimationImage(
            msg.isSend ? mAudioAssetRightList : mAudioAssetLeftList,
            width: 100,
            height: 30,
            isStop: isStop,
            //&&(widget.mUUid==widget.mMessage.uuid)
          ),
        );
    }
  }

  /*playLocal() async {
    int result = await mAudioPlayer.play((widget.mMessage as HrlVoiceMessage).path, isLocal: true);
    //  int result = await mAudioPlayer.play("https://github.com/luanpotter/audioplayers");
    print("播放的路径："+"${(widget.mMessage as HrlVoiceMessage).path}"+"播放的结果:"+"${result}");
    mAudioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
         isPalying = false;
       });
    });
    setState(() {
      isPalying = true;
    });


  }*/

  BubbleStyle getItemBundleStyle(HrlMessage mMessage) {
    BubbleStyle styleSendText = BubbleStyle(
      nip: BubbleNip.rightText,
      color: Color(0xffCCEAFF),
      nipOffset: 5,
      nipWidth: 10,
      nipHeight: 10,
      margin: BubbleEdges.only(left: 50.0),
      padding: BubbleEdges.only(top: 8, bottom: 10, left: 15, right: 10),
    );
    BubbleStyle styleSendImg = BubbleStyle(
      nip: BubbleNip.noRight,
      color: Colors.transparent,
      nipOffset: 5,
      nipWidth: 10,
      nipHeight: 10,
      margin: BubbleEdges.only(left: 50.0),
    );

    BubbleStyle styleReceiveText = BubbleStyle(
      nip: BubbleNip.leftText,
      color: Colors.white,
      nipOffset: 5,
      nipWidth: 10,
      nipHeight: 10,
      margin: BubbleEdges.only(right: 50.0),
      padding: BubbleEdges.only(top: 8, bottom: 10, left: 10, right: 15),
    );

    BubbleStyle styleReceiveImg = BubbleStyle(
      nip: BubbleNip.noLeft,
      color: Colors.transparent,
      nipOffset: 5,
      nipWidth: 10,
      nipHeight: 10,
      margin: BubbleEdges.only(left: 50.0),
    );

    switch (mMessage.msgType) {
      case HrlMessageType.image:
        return widget.message.isSend ? styleSendImg : styleReceiveImg;
      case HrlMessageType.text:
        return widget.message.isSend ? styleSendText : styleReceiveText;
      case HrlMessageType.voice:
        return widget.message.isSend ? styleSendText : styleReceiveText;
    }
  }

  Widget getSentMessageLayout() {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: widget.message.msgType == HrlMessageType.voice,
            child: Container(
              child: widget.message.msgType == HrlMessageType.voice ? Text(
                (widget.message as HrlVoiceMessage).duration.toString() + "'",
                style: TextStyle(fontSize: 14, color: Colors.black),) : Container(),
            ),
          ),

          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            ),
            child: Bubble(
              style: getItemBundleStyle(widget.message),
              // child:    Text(  '${(widget.mMessage as HrlTextMessage).text  }',  softWrap: true,style: TextStyle(fontSize: 14.0,color: Colors.black),),
              child: getItemContent(widget.message),
            ),
            margin: EdgeInsets.only(
              bottom: 5.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 5),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://c-ssl.duitang.com/uploads/item/201208/30/20120830173930_PBfJE.thumb.700_0.jpeg"),
              radius: 16.0,
            ),
          ),
        ],
      ));
  }

  Widget getReceivedMessageLayout() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        //  mainAxisAlignment:MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5.0, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://c-ssl.duitang.com/uploads/item/201208/30/20120830173930_PBfJE.thumb.700_0.jpeg"),
              radius: 16.0,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            ),
            child: Bubble(
              style: getItemBundleStyle(widget.message),
              child: getItemContent(widget.message),
            ),

            margin: EdgeInsets.only(
              bottom: 5.0,
            ),
          ),
        ],
      ));
  }
}


