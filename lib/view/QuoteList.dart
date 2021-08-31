import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote/Services/SqlServices.dart';
import 'package:quote/view/QuoteDetails.dart';

class QuoteList extends StatefulWidget {
  final String title;
  final categoryId;

  const QuoteList({Key key, @required this.title, @required this.categoryId})
      : super(key: key);
  @override
  _QuoteListState createState() => _QuoteListState();
}

class _QuoteListState extends State<QuoteList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<SqlServices>(
        builder: (context, sqlServices, child) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: FutureBuilder(
            future: sqlServices.queryCategory(catId: widget.categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: ListView.builder(
                    addAutomaticKeepAlives: true,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) => ListTile(
                      subtitle: Divider(
                        color: Colors.purple,
                      ),
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.purple,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: Center(
                          child: Text((index + 1).toString()),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        child: Text(snapshot.data[index]['quote'].toString(),
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuoteDetail(
                            title: widget.title,
                            id: widget.categoryId,
                            pageNumber: index,
                            isFav: snapshot.data[index]['isFav'],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          bottomNavigationBar: sqlServices.showBannerAd(),
        ),
      ),
    );
  }
}
