import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;

class Swiperdiy extends StatelessWidget {

  final List dateList;
  Swiperdiy({
    this.dateList
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: 250,
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          Post post = dateList[index];
          return Image.network(post.imageUrl,fit: BoxFit.fill,);
        },
        itemCount: dateList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

class GradeSecond extends StatelessWidget {

  final List posts;
  GradeSecond({
    this.posts
  });

  Widget _childModule(BuildContext context, Post item) {
    return InkWell(
      onTap: (){print('点击跳转');},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(60),
            height: ScreenUtil().setWidth(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
              image: DecorationImage(image:  NetworkImage(item.imageUrl),fit: BoxFit.cover)
            ),
          ),
          SizedBox(height: 6,),
          Text(item.author,overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(260),
      padding: EdgeInsets.all(5),
      child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),//禁止滑动
              crossAxisCount: 5,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              children: posts.map<Widget>((item){
                return _childModule(context, item);
              }).toList(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

@override
  void initState() {
    print("homePage初始化了");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getHttp();
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('首页'),
        ),
        body: FutureBuilder(
          builder: (BuildContext context,AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("暂时没有数据")
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Swiperdiy(dateList: snapshot.data,),
                  GradeSecond(posts: snapshot.data,)
                ],
              );
            }
          },
          future: fetchPosts(),
        )
      ),
    );
  }



   Future<List<Post>> fetchPosts() async {
    final response = await http.get('https://resources.ninghao.net/demo/posts.json');
    
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<Post> posts = responseBody['posts'].map<Post>((item) => Post.fromJson(item)).toList();
      if (posts.length > 10) {
        posts.removeRange(10, posts.length);
      }
      return posts;
    } else {
      throw Exception('some thing is wrong');
    }
  }


  //easy-mock本地服务器数据联调
  Future getHttp() async {
    try {
      final urlStr = 'http://localhost:7300/mock/5e8ae77d28b9cf10b1896e89/flutter_test/home_dabaojian';
      final response = await Dio().post(urlStr,queryParameters: {'name':'qiujr'});
      print(response);
      
    } catch(error) {
      debugPrint('error');
    }
  }

}


  
class Post {

  final String title;
  final String description;
  final String id;
  final String author;
  final String imageUrl;

  Post(
    this.title,
    this.description,
    this.id,
    this.author,
    this.imageUrl
  );

  Post.fromJson(Map json)
   : title = json['title'],
     description = json['description'],
     id = json['id'].toString(),
     author = json['author'],
     imageUrl = json['imageUrl'];

  Map toJson() {
    return {
      'title':title,
      'description':description,
      'author':author,
      'imageUrl':imageUrl,
      'id':id
    };
  }
}