import "package:dio/dio.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hrlweibo/model/VideoModel.dart';
import 'package:flutter_hrlweibo/public.dart';
import 'package:flutter_hrlweibo/util/date_util.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class VideoHotPage extends StatefulWidget {
  @override
  _VideoHotPageState createState() => _VideoHotPageState();
}

class _VideoHotPageState extends State<VideoHotPage> with AutomaticKeepAliveClientMixin {
  bool isLoadingMore = false; //是否显示加载中
  bool hasMore = true; //是否还有更多
  num curPage = 1;
  ScrollController scrollController = ScrollController();
  List<VideoModel> videoList = [];
  List<String> bannerAdList = [];

  _VideoHotPageState() {}

  @override
  bool get wantKeepAlive => true;

  Future getVideoList(bool isRefresh) async {
    if (isRefresh) {
      isLoadingMore = false;
      hasMore = true;
      curPage = 1;
      Map<String, dynamic> params = {'pageNum': "$curPage", 'pageSize': "10"};

      Future<Map<String, dynamic>> a = DioManager().post(ServiceUrl.getVideoHotList, params);

      Future<Map<String, dynamic>> b = DioManager().post(ServiceUrl.getVideoHotBannerAdList, params);

      try {
        List<Map<String, dynamic>> results = await Future.wait(<Future<Map<String, dynamic>>>[a, b]);
        List<VideoModel> list = List();
        results[0]['data']['list'].forEach((data) {
          list.add(VideoModel.fromJson(data));
        });
        videoList = list;

        List<String> list2 = List();
        results[1]['data'].forEach((data) {
          list2.add(data.toString());
        });
        bannerAdList = list2;

        setState(() {});
      } on Exception catch (error) {

      }
    } else {
      var params = {'pageNum': "$curPage", 'pageSize': "10"};
      DioManager().post(ServiceUrl.getVideoHotList, params).then((data) {
        List<VideoModel> list = List();
        data['data']['list'].forEach((data) {
          list.add(VideoModel.fromJson(data));
        });
        videoList.addAll(list);
        isLoadingMore = false;
        hasMore = list.length >= Constant.PAGE_SIZE;
        setState(() {});
      }, onError: (error) {
        setState(() {
          isLoadingMore = false;
          hasMore = false;
        });
      });
    }
  }

  Widget _buildLoadMore() {
    return isLoadingMore
      ? Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                  height: 12.0,
                  width: 12.0,
                ),
              ),
              Text("加载中..."),
            ],
          )),
      ))
      : Container(
      child: hasMore
        ? Container()
        : Center(
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            "没有更多数据",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ))),
    );
  }

  Widget getContentItem(BuildContext context, VideoModel mModel) {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            height: 100,
            width: MediaQuery
              .of(context)
              .size
              .width * 3 / 8,
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery
                    .of(context)
                    .size
                    .width * 3 / 8,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder:
                      AssetImage(Constant.ASSETS_IMG + 'img_default.png'),
                      image: NetworkImage(
                        mModel.coverimg,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,

                        children: <Widget>[
                          Spacer(),
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Text(
                              DateUtil.getFormatTime4(mModel.videotime)
                                .toString(),
                              style: TextStyle(
                                fontSize: 14.0, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ))
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 40,
                  child: Text(mModel.introduce,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.0, color: Colors.black)),
                  //  margin: EdgeInsets.only(left: 60),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.all(2),
                  child: Text(
                    mModel.recommengstr,
                    style: TextStyle(fontSize: 11, color: Color(0xffFB9213)),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      //圆角
                      Radius.circular(5.0),
                    ),
                    color: Color(0xffFEF5E2),
                  ),
                ),
                Container(
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    child: Text(
                      "@" + mModel.username,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text(
                          mModel.playnum.toString(),
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        )),
                      Container(
                        child: Text(
                          "次观看 · ",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Center(
                          child: Text(
                            DateUtil.getFormatTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                mModel.createtime))
                              .toString(),
                            style:
                            TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      var maxScroll = scrollController.position.maxScrollExtent;
      var pixels = scrollController.position.pixels;
      if (maxScroll == pixels) {
        if (!isLoadingMore) {
          if (hasMore) {
            setState(() {
              isLoadingMore = true;
              curPage += 1;
            });
            Future.delayed(Duration(seconds: 3), () {
              getVideoList(false);
            });
          } else {
            setState(() {
              hasMore = false;
            });
          }
        }
      }
    });
    getVideoList(true);
  }

  Future pullToRefresh() async {
    getVideoList(true);
  }

  Widget mCenterBannerItemWidegt(String mUrl) {
    return Container(
      child: ClipRRect(
        child: FadeInImage.assetNetwork(
          fit: BoxFit.cover,
          placeholder: Constant.ASSETS_IMG + 'img_default2.png',
          image: mUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: RefreshIndicator(
        onRefresh: pullToRefresh,
        child: CustomScrollView(controller: scrollController, slivers: <
          Widget>[
          SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          Constant.ASSETS_IMG + 'video_hot_top1.png',
                          width: 45.0,
                          height: 45.0,
                        ),
                        Text(
                          "排行榜",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          Constant.ASSETS_IMG + 'video_hot_type2.png',
                          width: 45.0,
                          height: 45.0,
                        ),
                        Text(
                          "每周必看",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          Constant.ASSETS_IMG + 'video_hot_type3.png',
                          width: 45.0,
                          height: 45.0,
                        ),
                        Text(
                          "宝藏博主",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          Constant.ASSETS_IMG + 'video_hot_type4.png',
                          width: 45.0,
                          height: 45.0,
                        ),
                        Text(
                          "更多频道",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                if (index == videoList.length + 1) {
                  return _buildLoadMore();
                } else if (index == 0 || index == 1 || index == 2) {
                  if (videoList.length != 0) {
                    return getContentItem(context, videoList[index]);
                  } else {
                    return Container();
                  }
                } else if (index == 3) {
                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Container(
                      height: 120,
                      child: Swiper(
                        outer: false,
                        pagination: SwiperPagination(
                          builder: DotSwiperPaginationBuilder(
                            size: 7,
                            space: 5,
                            activeSize: 7,
                            /*   color: Color(0xF0F0F0),
                            activeColor:  Color(0xD8D8D8),*/
                            color: Color(0xffF0F0F0),
                            activeColor: Color(0xffD8D8D8),
                          ),
                          margin: EdgeInsets.all(0)),
                        itemBuilder: (c, i) {
                          return mCenterBannerItemWidegt(bannerAdList[i]);
                        },
                        itemCount: bannerAdList.length,
                      ),
                    ),
                  );
                } else {
                  return getContentItem(context, videoList[index - 1]);
                }
              },
              childCount: videoList.length + 2,
            ),
          ),
        ]),
      ),
    );
  }
}
