// To parse this JSON data, do
//
//     final allWareHouseModel = allWareHouseModelFromJson(jsonString);

import 'dart:convert';

AllWareHouseModel allWareHouseModelFromJson(String str) => AllWareHouseModel.fromJson(json.decode(str));

String allWareHouseModelToJson(AllWareHouseModel data) => json.encode(data.toJson());

class AllWareHouseModel {
    List<Result>? result;

    AllWareHouseModel({
        this.result,
    });

    factory AllWareHouseModel.fromJson(Map<String, dynamic> json) => AllWareHouseModel(
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    dynamic name;

    Result({
        this.id,
        this.name,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
