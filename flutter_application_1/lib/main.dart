import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> createAlbum() async {
  final response = await http.post(
      Uri.parse(
          'https://services-test.theraise.app/pubservices/s/content/getTrial'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes)) as List;

    return jsonResponse.map((data) => new Album.fromJson(data)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load ');
  }
}

class Album {
  final String nameVi;
  final String nameEn;
  final String description;
  final int view;
  final String banner;
  final List<dynamic> content;
  final List<dynamic> target;
  final String suggestions;
  final String thumnail;

  const Album({
    required this.nameVi,
    required this.nameEn,
    required this.description,
    required this.view,
    required this.banner,
    required this.content,
    required this.target,
    required this.suggestions,
    required this.thumnail,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      nameVi: json['nameVi'],
      nameEn: json['nameEn'],
      description: json['description'],
      view: json['view'],
      banner: json['banner'],
      content: json['content'],
      target: json['target']['ops'],
      suggestions: json['suggestions'],
      thumnail: json['thumnail'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;
  final x = BoxDecoration(
    // borderRadius: BorderRadius.circular(10),
    // border: Border(
    //   top: BorderSide(
    //       color: Color(0xFFDFDFDF), width: 1, style: BorderStyle.solid),
    //   left: BorderSide(
    //       color: Color(0xFFDFDFDF), width: 1, style: BorderStyle.solid),
    //   right: BorderSide(
    //       color: Color(0xFF7F7F7F), width: 1, style: BorderStyle.solid),
    //   bottom: BorderSide(
    //       color: Color(0xFF7F7F7F), width: 1, style: BorderStyle.solid),
    // ),
    // borderRadius: BorderRadius.circular(10),
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    // boxShadow: [BoxShadow(color: Colors.black54, spreadRadius: 0.5)],
  );

  @override
  void initState() {
    super.initState();
    futureAlbum = createAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raise - Fetch Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Raise - Fetch Data'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Album> data = snapshot.data!;
                return Container(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black54, spreadRadius: 1)
                              ]),
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          margin: EdgeInsets.only(left: 5, top: 20, right: 5),
                          height: 190,
                          child: Row(children: [
                            Flexible(
                                flex: 1,
                                child: Expanded(
                                    child: (Image.network(
                                  data[i].thumnail,
                                )))),
                            Flexible(
                                flex: 1,
                                child: Expanded(
                                    child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        'Tên tiếng việt: ${data[i].nameVi}',
                                      ),
                                      decoration: x,
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        'Số lượt xem: ${data[i].view}',
                                      ),
                                      decoration: x,
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    Container(
                                      
                                      padding: EdgeInsets.only(top: 15),
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        // do something
                                                        DetailPage(
                                                          dataKey: data[i],
                                                        )));
                                          },
                                          child: Text('Xem them'),
                                          style: ButtonStyle()),
                                    )
                                  ],
                                ))),
                          ]),
                        );
                      }),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Album dataKey;
  const DetailPage({Key? key, required this.dataKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Tên bài: ${dataKey.nameVi}"),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: createAlbum(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Album> data = snapshot.data!;
                print(dataKey.content);
                return Container(
                  child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                  children: [
                                    Text('Tên tiếng anh: ', style: TextStyle(fontWeight: FontWeight.w800),),
                                    Text('${dataKey.nameEn}')
                                  ],
                                )),
                                Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Column(     
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mô tả bài học: ', style: TextStyle(fontWeight: FontWeight.w800,),),
                                    Text('${dataKey.description}')
                                  ],
                                ),),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Image.network(dataKey.banner)
                                  ),
                                Text(
                                  '1, Hướng dẫn phụ huynh',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                for (var x = 0; x < dataKey.content.length; x++)
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, left: 10),
                                      child: Text(
                                          'Bước ${x + 1}: ${dataKey.content[x]['content']['ops'][0]['insert']}')),
                                Text(
                                  '1, Mục đích bài học',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                for (int y = 0;
                                    y < dataKey.target.length;
                                    y = y + 2)
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, left: 10),
                                      child: Text(
                                          'Mục tiêu ${(y / 2 + 1).toInt()}: ${dataKey.target[y]['insert']}')),
                                Text(
                                  '3, Gợi ý cho cha mẹ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text('${dataKey.suggestions}'),
                              ],
                            ));
                      }),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
