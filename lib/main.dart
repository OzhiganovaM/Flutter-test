import 'dart:async';
import 'dart:core';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

Future<List<Photos>> fetchPhotos(http.Client client) async {
  final response =
  await client.get
    ('https://api.unsplash.com/photos/random/?client_id=ab3411e4ac868c2646c0ed488dfd919ef612b04c264f3374c97fff98ed253dc9&count=5');

  return compute(parsePhotos, response.body);
}

List<Photos> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photos>((json) => Photos.fromJson(json)).toList();
}

class Photos {
  String altDescription;
  Urls urls;
  User user;

  Photos(
      {
        this.altDescription,
        this.urls,
        this.user,
      });

  Photos.fromJson(Map<String, dynamic> json) {
    altDescription = json['alt_description'];
    urls = json['urls'] != null ? new Urls.fromJson(json['urls']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alt_description'] = this.altDescription;

    if (this.urls != null) {
      data['urls'] = this.urls.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class Urls {
  String full;
  String thumb;
  String small;

  Urls({this.full, this.thumb, this.small});

  Urls.fromJson(Map<String, dynamic> json) {
    full = json['full'];
    thumb = json['thumb'];
    small = json['small'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full'] = this.full;
    data['thumb'] = this.thumb;
    data['small'] = this.small;
    return data;
  }
}

class User {
  String name;
  User({this.name});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final String altDescription;
  final Urls urls;
  final User user;

  MyApp({Key key, this.altDescription, this.urls, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter test',
      theme: ThemeData(
          primaryColor: Colors.black
      ),
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter test',
            style: TextStyle(color: Colors.white70)),
          centerTitle: true,
        ),
         body:
         Center(
            child: FutureBuilder<List<Photos>>(
              future: fetchPhotos(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? PhotosList(photos: snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            ),
          )
      )
    );
  }
}


class PhotosList extends StatelessWidget {
  final List<Photos> photos;

  PhotosList({Key key, this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Card(
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                color: Colors.black,
                child: Column(
                    children: [
                     Expanded(
                        child: PhotoView(
                          imageProvider: NetworkImage(photos[index].urls.small),
                        )
                     ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10),
                          child: (photos[index].altDescription == null) ? Text(
                              ('No description'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70))
                              : Text((photos[index].altDescription),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70))
                      ),
                    ]
                )
            )
        );
      }
    );
  }
}