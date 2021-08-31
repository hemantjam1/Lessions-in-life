import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mopub_flutter/mopub.dart';
import 'package:mopub_flutter/mopub_banner.dart';
import 'package:mopub_flutter/mopub_interstitial.dart';
import 'DatabaseHelper.dart';
import '../Model/ModelClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'show Platform;

class SqlServices extends ChangeNotifier {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  static bool isDbAvailable = false;
  static final bannerId = "b485d3e696ec4611b052d36746a5e051";
  //'b195f8dd8ded45fe847ad89ed1d016da'; //android banner test iD
  static final interstitialId = "b323a43b84264fb683a8a23e3e2da6bd";
  // '24534e1901884e398f1253216226017e //android interstitial test Id
  // Banner Ad Unit ID : b485d3e696ec4611b052d36746a5e051
// FullScreen id : b323a43b84264fb683a8a23e3e2da6bd
  static MoPubInterstitialAd interstitialAd;

  mopubInit() {
    try {
      MoPub.init(interstitialId).then((value) => _loadInterstitialAd());
    } on PlatformException catch (e) {
      print('something wrong in mopub$e');
    }
    try {
      MoPub.init(bannerId);
    } on PlatformException catch (e) {
      print('something wrong in mopub banner ad$e');
    }
  }

  _loadInterstitialAd() {
    interstitialAd = MoPubInterstitialAd(
      interstitialId,
      (result, args) {},
      reloadOnClosed: true,
    );
    interstitialAd.load();
  }

  Widget showBannerAd() {
    return Platform.isAndroid ?MoPubBannerAd(
        adUnitId: bannerId,
        bannerSize: BannerSize.STANDARD,
        keepAlive: true,
        listener: (result, dynamic) {}):Container(height:20);
  }

  Future favQueryQuote({String checkFav, int quoteId, int catId}) async {
    List favList = [];
    String favCopy;
    var res = await databaseHelper.favQueryDetail(
        checkFav: checkFav, catId: catId, quoteId: quoteId);
    favList = res;
    favCopy = favList.first['quote'];
    return favCopy;
  }

  Future queryQuote({int quoteId, int catId}) async {
    String quote;
    List quoteList = [];
    var res = await databaseHelper.queryQuote(quoteId: quoteId, catId: catId);
    quoteList = res;
    quote = quoteList.first['quote'];
    return quote;
  }

  Future addToFavorite({int quoteId, String isFav, int catId}) async {
    await databaseHelper.update(quoteId: quoteId, isFav: isFav, catId: catId);
    notifyListeners();
  }

  queryCategory({int catId}) async {
    var res = await databaseHelper.queryCat(catId: catId);
    notifyListeners();
    return res;
  }

  queryFavorite(String checkFav) async {
    var res = await databaseHelper.favQuery(checkFav);
    notifyListeners();
    return res;
  }

  insertData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var res = await rootBundle.loadString('assets/file.json');
    final quoteModel = quoteModelFromJson(res);
    for (int i = 0; i < quoteModel.category.length; i++) {
      Map<String, dynamic> categoryRow = {
        DatabaseHelper.categoryId: i,
        DatabaseHelper.categoryColumnName: quoteModel.category[i].name,
        DatabaseHelper.categoryImageUrl: quoteModel.category[i].imageUrl,
        DatabaseHelper.categoryLength: quoteModel.category[i].length,
        DatabaseHelper.categoryInitialQuote: quoteModel.category[i].initialQuote
      };
      await databaseHelper.insertIntoCat(categoryTableRow: categoryRow);
      for (int j = 0; j < quoteModel.category[i].quotes.length; j++) {
        Map<String, dynamic> categoryDetailRow = {
          DatabaseHelper.categoryId: i,
          DatabaseHelper.quoteColumnId: j,
          DatabaseHelper.quoteColumn: quoteModel.category[i].quotes[j].quote,
          DatabaseHelper.isFav: "false"
        };
        await databaseHelper.insertIntoDetail(
            categoryDetailTableRow: categoryDetailRow);
      }
    }
    getData();
    pref.setBool('isDB', true);
    notifyListeners();
  }

  Future getData() async {
    var res = await databaseHelper.queryAllCategoryTable();
    notifyListeners();
    return res;
  }

  Future<bool> checkDb() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var res = pref.getBool('isDB') ?? false;
    isDbAvailable = res;
    notifyListeners();
    return res;
  }

  fetchDb() {
    if (!isDbAvailable) {
      insertData();
    } else {
      getData();
    }
    notifyListeners();
  }
}
