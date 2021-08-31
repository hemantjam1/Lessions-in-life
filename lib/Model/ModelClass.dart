// To parse this JSON data, do
//
//     final quoteModel = quoteModelFromJson(jsonString);

import 'dart:convert';

QuoteModel quoteModelFromJson(String str) =>
    QuoteModel.fromJson(json.decode(str));

String quoteModelToJson(QuoteModel data) => json.encode(data.toJson());

class QuoteModel {
  QuoteModel({this.category});

  List<Category> category;

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        category: List<Category>.from(
            json["category"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() =>
      {"category": List<dynamic>.from(category.map((x) => x.toJson()))};
}

class Category {
  Category(
      {this.name, this.imageUrl, this.length, this.initialQuote, this.quotes});

  String name;
  String imageUrl;
  String length;
  String initialQuote;
  List<Quote> quotes;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
      name: json["name"],
      imageUrl: json["imageUrl"],
      length: json["length"],
      initialQuote: json["initialQuote"],
      quotes: List<Quote>.from(json["quotes"].map((x) => Quote.fromJson(x))));

  Map<String, dynamic> toJson() => {
        "name": name,
        "imageUrl": imageUrl,
        "length": length,
        "initialQuote": initialQuote,
        "quotes": List<dynamic>.from(quotes.map((x) => x.toJson()))
      };
}

class Quote {
  Quote({this.quote});

  String quote;

  factory Quote.fromJson(Map<String, dynamic> json) =>
      Quote(quote: json["quote"]);

  Map<String, dynamic> toJson() => {"quote": quote};
}
