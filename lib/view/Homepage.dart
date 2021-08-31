import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quote/view/FavPage.dart';
import 'package:quote/view/Category.dart';
import 'package:quote/view/QuoteImages.dart';
import 'package:share/share.dart';
import '../Services/SqlServices.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SqlServices sqlServices = SqlServices();

  bool isConnection = true;
  //connectivity checking for firebase
  checkConnectivity() async {
    try {
      final res = await InternetAddress.lookup('google.com');
      if (res.isNotEmpty && res.first.rawAddress.isNotEmpty)
        isConnection = true;
    } on SocketException catch (e) {
      Fluttertoast.showToast(
          msg: 'No internet connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      print(e.message);
      isConnection = false;
    }
  }

  share() async {
    try {
      await launch('https://www.google.com/');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkConnectivity();
    sqlServices.checkDb().then((value) => sqlServices.fetchDb());
    super.initState();
    // full screen ad show
    Future.delayed(Duration(seconds: 30), () {
      SqlServices.interstitialAd.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/title.jpg"),
            ),
          ),
          title: Text('Lesions In Life'),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FavPage()))),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/title.jpg"),
                        ),
                        Text('   Quote')
                      ],
                    ),
                    content: Text(
                        'Check out the best collection\nof lesions in list Quotes,Life\nMotivation Quotes!\n-Supported by Manek Tech\n-Version 1.0'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Share.share('https://www.manektech.com/');
                            Navigator.pop(context);
                          },
                          child: Text('SHARE APP')),
                      TextButton(
                          onPressed: () {
                            share();
                            Navigator.pop(context);
                          },
                          child: Text('MORE APPS')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isConnection ? QuoteImages() : SizedBox(),
              Flexible(child: Category()),
            ],
          ),
        ),
      ),
    );
  }
}
