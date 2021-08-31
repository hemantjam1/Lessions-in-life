import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../Services/SqlServices.dart';
import 'dart:math';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SqlServices>(
      builder: (context, sqlServices, model) => Scaffold(
        appBar: AppBar(title: Text('Favorites')),
        body: FutureBuilder(
          future: sqlServices.queryFavorite('true'),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0) {
              return Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Your favorite will be listed here'),
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  separatorBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(left: 85),
                    child: Divider(
                      color: Colors.purple,
                      thickness: 1,
                    ),
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          snapshot.data[index]['quote'].toString(),
                          maxLines: 2,
                        ),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                          child: Center(
                            child: Text((index + 1).toString()),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FavDetails(pageNumber: index, isFav: 'true'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: Center(
                        child: Text('Your favorites will be listed here')),
                  ),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: sqlServices.showBannerAd(),
      ),
    );
  }
}

class FavDetails extends StatefulWidget {
  final int pageNumber;
  final String isFav;

  const FavDetails({Key key, @required this.pageNumber, @required this.isFav})
      : super(key: key);
  @override
  _FavDetailsState createState() => _FavDetailsState();
}

class _FavDetailsState extends State<FavDetails> {
  PageController pageController;
  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isF = widget.isFav == 'true';
    int _index = widget.pageNumber;
    return Consumer<SqlServices>(
      builder: (context, sqlServices, child) => Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: FutureBuilder(
          future: sqlServices.queryFavorite('true'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              int number = snapshot.data.length;
              return Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      itemCount: snapshot.data.length,
                      controller: pageController,
                      itemBuilder: (context, index) {
                        _index = index;
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('#${index + 1}'.toString(),
                                                textScaleFactor: 1.5),
                                            IconButton(
                                              icon: Icon(
                                                Icons.favorite,
                                                size: 35,
                                                color: snapshot.data[index]
                                                            ['isFav'] ==
                                                        'true'
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () async {
                                                isF = !isF;
                                                sqlServices
                                                    .addToFavorite(
                                                        catId:
                                                            snapshot.data[index]
                                                                ['categoryId'],
                                                        isFav: isF.toString(),
                                                        quoteId:
                                                            snapshot.data[index]
                                                                ['quoteId'])
                                                    .then((value) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Removed from favorite');
                                                  Navigator.pop(context);
                                                });
                                              },
                                            ),
                                          ]),
                                      SizedBox(height: 20),
                                      Text(snapshot.data[index]['quote']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: Icon(Icons.shuffle),
                          onPressed: () {
                            print(Random().nextInt(number));
                            pageController.animateToPage(
                                Random().nextInt(number),
                                duration: Duration(milliseconds: 1),
                                curve: Curves.ease);
                          }),
                      Consumer<SqlServices>(
                        builder: (context, sqlServices, child) => IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              sqlServices
                                  .favQueryQuote(
                                      quoteId: snapshot.data[_index]['quoteId'],
                                      catId: snapshot.data[_index]
                                          ['categoryId'],
                                      checkFav: 'true')
                                  .then((value) {
                                Clipboard.setData(ClipboardData(text: value));
                                Fluttertoast.showToast(
                                    msg: 'copied to clipboard');
                              });
                            }),
                      ),
                      Consumer<SqlServices>(
                        builder: (context, sqlServices, child) => IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () async {
                            sqlServices
                                .favQueryQuote(
                                    quoteId: snapshot.data[_index]['quoteId'],
                                    catId: snapshot.data[_index]['categoryId'],
                                    checkFav: 'true')
                                .then(
                              (value) {
                                Share.share(value);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        bottomNavigationBar: sqlServices.showBannerAd(),
      ),
    );
  }
}
