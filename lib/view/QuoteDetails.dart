import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../Services/SqlServices.dart';
import 'dart:math';

class QuoteDetail extends StatefulWidget {
  final String title;
  final int id;
  final int pageNumber;
  final String isFav;

  const QuoteDetail(
      {Key key,
      @required this.title,
      @required this.id,
      @required this.pageNumber,
      @required this.isFav})
      : super(key: key);

  @override
  _QuoteDetailState createState() => _QuoteDetailState();
}

class _QuoteDetailState extends State<QuoteDetail> {
  PageController pageController;

  int number;
  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
    //  Future.delayed(Duration(seconds: 20), () {
    //    SqlServices.interstitialAd.show();
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Consumer<SqlServices>(
          builder: (context, sqlServices, child) => FutureBuilder(
            future: sqlServices.queryCategory(catId: widget.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return PageView.builder(
                  controller: pageController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    number = snapshot.data.length;
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            margin: EdgeInsets.all(10),
                            elevation: 05,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('#${index + 1}'.toString(),
                                          textScaleFactor: 1.5),
                                      IconButton(
                                        icon: Icon(Icons.favorite,
                                            size: 35,
                                            color: snapshot.data[index]
                                                        ['isFav'] ==
                                                    'true'
                                                ? Colors.red
                                                : Colors.grey),
                                        onPressed: () async {
                                          // String isFavorite;
                                          if (snapshot.data[index]['isFav'] ==
                                              'true') {
                                            sqlServices.addToFavorite(
                                                catId: snapshot.data[index]
                                                    ['categoryId'],
                                                isFav: 'false',
                                                quoteId: snapshot.data[index]
                                                    ['quoteId']);
                                          } else {
                                            sqlServices.addToFavorite(
                                                catId: snapshot.data[index]
                                                    ['categoryId'],
                                                isFav: 'true',
                                                quoteId: snapshot.data[index]
                                                    ['quoteId']);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(snapshot.data[index]['quote'].toString())
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: Consumer<SqlServices>(
        builder: (context, sqlServices, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              child: sqlServices.showBannerAd(),
            ),
            Row(
              //  mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: Icon(Icons.shuffle),
                    onPressed: () {
                      pageController.animateToPage(Random().nextInt(number),
                          duration: Duration(milliseconds: 1),
                          curve: Curves.ease);
                    }),
                IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      sqlServices
                          .queryQuote(
                              quoteId: pageController.page.ceil(),
                              catId: widget.id)
                          .then((value) {
                        Clipboard.setData(ClipboardData(text: value));
                        Fluttertoast.showToast(msg: 'copied to clipboard');
                      });
                    }),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    sqlServices
                        .queryQuote(
                            quoteId: pageController.page.ceil(),
                            catId: widget.id)
                        .then(
                      (value) {
                        Share.share(value);
                      },
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
