import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sauce_app/api/Api.dart';
import 'package:sauce_app/gson/user_view_detail_entity.dart';
import 'package:sauce_app/message/single_conversation.dart';
import 'package:sauce_app/util/Base64.dart';
import 'package:sauce_app/util/HttpUtil.dart';
import 'package:sauce_app/util/ScreenUtils.dart';
import 'package:sauce_app/util/SharePreferenceUtil.dart';
import 'package:sauce_app/util/ToastUtil.dart';
import 'package:sauce_app/widget/list_title_right.dart';

import 'picture_preview_dialog.dart';

const APPBAE_SCROLL_OFFSET = 100;

class UserDetailPage extends StatefulWidget {
  UserDetailPage({Key key, this.userId}) : super(key: key);
String userId;
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    queryUserDetailByUserId();
  }
  Future queryUserDetailByUserId() async {
    print("------------------------------");
    print(widget.userId);
    print("------------------------------");
    var spUtil = await SpUtil.getInstance();
    var response = await HttpUtil().get(Api.QUERY_VIEW_USER_DETAIL_BY_ID,
        data: {"userId": widget.userId, "Id": spUtil.getInt("id").toString()});
    print(response);
    if (response != null) {
      var decode = json.decode(response);
      var userViewDetailEntity = UserViewDetailEntity.fromJson(decode);
      if (userViewDetailEntity.code == 200) {
        setState(() {
          _userViewDetailData = userViewDetailEntity.data;
        });
      } else {
        ToastUtil.showErrorToast("获取用户数据失败！");
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  ScreenUtils _screenUtils = new ScreenUtils();

  double alphaAppBar = 0;

  _onScroll(offset) {
    double alpha = offset / APPBAE_SCROLL_OFFSET;
    if (alpha <= 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      alphaAppBar = alpha;
    });
    print(alphaAppBar);
  }

  @override
  Widget build(BuildContext context) {
    _screenUtils.initUtil(context);
    var d = (MediaQuery.of(context).size.width - 12) / 3;
    return _userViewDetailData == null
        ? new Center(
            child: new CupertinoActivityIndicator(
              radius: _screenUtils.setWidgetWidth(15),
            ),
          )
        : Scaffold(
            primary: false,
            body: new Container(
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: NotificationListener(
                            onNotification: (scrollNotification) {
                              if (scrollNotification
                                  is ScrollUpdateNotification) {
                                _onScroll(scrollNotification.metrics.pixels);
                              }
                              return false;
                            },
                            child: new ListView(
                              scrollDirection: Axis.vertical,
                              children: <Widget>[
                                new Stack(
                                  children: <Widget>[
                                    new Column(
                                      children: <Widget>[
                                        new Container(
                                            height: _screenUtils
                                                .setWidgetHeight(160),
                                            color: Colors.black54,
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  _userViewDetailData.avatar,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  fit: BoxFit.cover,
                                                  height: _screenUtils
                                                      .setWidgetHeight(160),
                                                ),
                                                BackdropFilter(
                                                  filter: new ImageFilter.blur(
                                                      sigmaX: 8, sigmaY: 8),
                                                  child: new Container(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: _screenUtils
                                                        .setWidgetHeight(160),
                                                  ),
                                                ),
                                                new Container(
                                                  padding: EdgeInsets.only(
                                                      top: ScreenUtil
                                                          .statusBarHeight),
                                                  child: new AppBar(
                                                    leading: new IconButton(
                                                        icon: new Icon(Icons
                                                            .arrow_back_ios),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                    elevation: 0.5,
                                                    iconTheme:
                                                        new IconThemeData(
                                                            color:
                                                                Colors.white),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                ),
                                                new Positioned(
                                                    left: _screenUtils
                                                        .setWidgetWidth(110),
                                                    bottom: 10,
                                                    child: new Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        new Text(
                                                          _userViewDetailData
                                                              .nickname,
                                                          style: new TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  _screenUtils
                                                                      .setFontSize(
                                                                          21)),
                                                        ),
                                                        new Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: _screenUtils
                                                                .setWidgetWidth(
                                                                    4),
                                                          ),
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: new Text(
                                                            " ${_userViewDetailData.age}",
                                                            style: new TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    _screenUtils
                                                                        .setFontSize(
                                                                            13)),
                                                          ),
                                                        ),
                                                        new Container(
                                                          margin: EdgeInsets.only(
                                                              left: _screenUtils
                                                                  .setWidgetWidth(
                                                                      6)),
                                                          child:
                                                              new Image.asset(
                                                            _userViewDetailData
                                                                        .sex ==
                                                                    "1"
                                                                ? "assert/imgs/ic_user_boy.png"
                                                                : "assert/imgs/ic_user_girl.png",
                                                            width: _screenUtils
                                                                .setWidgetWidth(
                                                                    18),
                                                            height: _screenUtils
                                                                .setWidgetHeight(
                                                                    18),
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                              ],
                                            )),
                                        new Container(
                                          padding: EdgeInsets.only(
                                              left: _screenUtils
                                                  .setWidgetWidth(110),
                                              top: _screenUtils
                                                  .setWidgetHeight(15)),
                                          height:
                                              _screenUtils.setWidgetHeight(80),
                                          color: Colors.white,
                                          child: new Row(
                                            children: <Widget>[
                                              new Column(
                                                children: <Widget>[
                                                  new Text(
                                                    _userViewDetailData.fans,
                                                    style: new TextStyle(
                                                        fontSize: _screenUtils
                                                            .setFontSize(18),
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  new Text(
                                                    "粉丝",
                                                    style: new TextStyle(
                                                        fontSize: _screenUtils
                                                            .setFontSize(13),
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  )
                                                ],
                                              ),
                                              new Container(
                                                width: _screenUtils
                                                    .setWidgetWidth(15),
                                              ),
                                              new Column(
                                                children: <Widget>[
                                                  new Text(
                                                    _userViewDetailData.observe,
                                                    style: new TextStyle(
                                                        fontSize: _screenUtils
                                                            .setFontSize(18),
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  new Text(
                                                    "关注",
                                                    style: new TextStyle(
                                                        fontSize: _screenUtils
                                                            .setFontSize(13),
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    new Positioned(
                                      child: new ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            _screenUtils.setWidgetHeight(55)),
                                        child: new Image.network(
                                          _userViewDetailData.avatar,
                                          width:
                                              _screenUtils.setWidgetHeight(76),
                                          height:
                                              _screenUtils.setWidgetHeight(76),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      bottom: _screenUtils.setWidgetHeight(52),
                                      left: _screenUtils.setWidgetWidth(20),
                                    ),
                                    new Positioned(
                                      child: new Container(
                                        padding: EdgeInsets.only(
                                            top:
                                                _screenUtils.setWidgetHeight(3),
                                            bottom:
                                                _screenUtils.setWidgetHeight(3),
                                            left:
                                                _screenUtils.setWidgetWidth(10),
                                            right: _screenUtils
                                                .setWidgetWidth(10)),
                                        child: new Text(
                                          "ID ${_userViewDetailData.createTime.replaceAll("-","").replaceAll(":", "").replaceAll(" ", "").substring(5)}",
                                          style: new TextStyle(
                                              color: Colors.grey,
                                              fontSize:
                                                  _screenUtils.setFontSize(12)),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xfff1f3f3),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(0),
                                          ),
                                        ),
                                      ),
                                      bottom: _screenUtils.setWidgetHeight(10),
                                      left: 0,
                                    ),
                                  ],
                                ),
                                new Container(
                                  color: Color(0xfffafafa),
                                  height: _screenUtils.setWidgetHeight(8),
                                ),
                                new Container(
                                  padding: EdgeInsets.only(
                                      top: _screenUtils.setWidgetHeight(9),
                                      bottom: _screenUtils.setWidgetHeight(14),
                                      left: _screenUtils.setWidgetWidth(14)),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        padding: EdgeInsets.only(
                                            top: _screenUtils
                                                .setWidgetHeight(12),
                                            bottom: _screenUtils
                                                .setWidgetHeight(9)),
                                        child: new Text(
                                          "个人简介",
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  _screenUtils.setFontSize(19),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.only(
                                            top:
                                                _screenUtils.setWidgetHeight(4),
                                            bottom: _screenUtils
                                                .setWidgetHeight(5)),
                                        child: new Text(
                                          _userViewDetailData.signature,
                                          style: new TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                new Container(
                                  color: Color(0xfffafafa),
                                  height: _screenUtils.setWidgetHeight(8),
                                ),
                                new Container(
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        alignment: Alignment.centerLeft,
                                        height:
                                            _screenUtils.setWidgetHeight(65),
                                        color: Colors.white,
                                        child: new RightListTitle(
                                          title:
                                              "TA的动态 ${_userViewDetailData.postCount}",
                                          value: "",
                                          onTap: () {},
                                        ),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.only(
                                            left:
                                                _screenUtils.setWidgetWidth(15),
                                            bottom: _screenUtils
                                                .setWidgetHeight(15)),
                                        child: new Row(
                                          children: <Widget>[
                                            new Image.network(
                                              _userViewDetailData.postList.picture,
                                              width: _screenUtils
                                                  .setWidgetHeight(100),
                                              fit: BoxFit.cover,
                                              height: _screenUtils
                                                  .setWidgetHeight(100),
                                            ),
                                            new Expanded(
                                                child: new Container(
                                              height: _screenUtils
                                                  .setWidgetHeight(100),
                                              padding: EdgeInsets.only(
                                                  left: _screenUtils
                                                      .setWidgetWidth(8)),
                                              alignment: Alignment.topLeft,
                                              child: new Text(
                                                Base642Text.decodeBase64(_userViewDetailData.postList.postContent),
                                                style: new TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _screenUtils
                                                        .setFontSize(16)),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                              ),
                                            ))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                new Container(
                                  color: Color(0xfffafafa),
                                  height: _screenUtils.setWidgetHeight(8),
                                ),
                                new Container(
                                  child: new Column(
                                    children: <Widget>[
                                      new RightListTitle(
                                        value: _userViewDetailData.school,
                                        title: "所在学校",
                                        onTap: () {},
                                      ),
                                      new RightListTitle(
                                        value: _userViewDetailData.major,
                                        title: "专业",
                                        onTap: () {},
                                      ),
                                      new RightListTitle(
                                        value: _userViewDetailData.username,
                                        title: "联系方式",
                                        onTap: () {},
                                      ),
                                      new RightListTitle(
                                        value: _userViewDetailData.currentCity,
                                        title: "所在城市",
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                                new Container(
                                  color: Color(0xfffafafa),
                                  height: _screenUtils.setWidgetHeight(10),
                                ),
                                new Container(
                                  padding: EdgeInsets.only(
                                      top: _screenUtils.setWidgetHeight(9),
                                      bottom: _screenUtils.setWidgetHeight(14),
                                      left: _screenUtils.setWidgetWidth(14)),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        padding: EdgeInsets.only(
                                            bottom: _screenUtils
                                                .setWidgetHeight(10)),
                                        child: new Text(
                                          "照片墙",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                      new GridView.builder(
                                        shrinkWrap: true,
                                        //增加
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 1,
                                          mainAxisSpacing: 1,
                                        ),
                                        itemBuilder: (BuildContext context,
                                            int position) {
                                          return new GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  new MaterialPageRoute(
                                                      builder: (_) {
                                                return new PhotoGalleryPage(
                                                  index: position,
                                                  photoList: _userViewDetailData
                                                      .pictureWal,
                                                );
                                              }));
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(2),
                                              child: new ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        _screenUtils
                                                            .setWidgetWidth(4)),
                                                child: new Image.network(
                                                  _userViewDetailData
                                                      .pictureWal[position],
                                                  fit: BoxFit.cover,
                                                  height: _screenUtils
                                                      .setWidgetHeight(
                                                          d.toInt()),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: _userViewDetailData
                                            .pictureWal.length,
                                        physics:
                                            new NeverScrollableScrollPhysics(),
                                      )
                                    ],
                                  ),
                                  color: Colors.white,
                                )
                              ],
                            ))),
                    Opacity(
                      opacity: alphaAppBar,
                      child: Container(
                        height: _screenUtils.setWidgetHeight(90),
                        decoration: BoxDecoration(color: Colors.white),
                        child: new AppBar(
                          leading: new IconButton(
                              icon: new Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          elevation: 0.5,
                          iconTheme: new IconThemeData(color: Colors.black),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                )),
            bottomNavigationBar: new Container(
              height: _screenUtils.setWidgetHeight(50),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new GestureDetector(
                        child: new Container(
                          alignment: Alignment.center,
                          color: Color(0xff1fb5c6),
                          child: new Text("私聊",
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _screenUtils.setFontSize(15))),
                        ),
                        onTap: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (_){
                            return SingleConversationPage(
                              username: _userViewDetailData.nickname,
                              avatar: _userViewDetailData.avatar,
                              userId: _userViewDetailData.username,
                            );
                          }));
                        },
                      )),
                  new Expanded(
                      child: new Container(
                    alignment: Alignment.center,
                    color: Color(0xff00caa4),
                    child: new Text("关注",
                        style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _screenUtils.setFontSize(15))),
                  )),
                ],
              ),
            ),
          );
  }

  UserViewDetailData _userViewDetailData;


}
