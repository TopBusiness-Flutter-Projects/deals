// To parse this JSON data, do
//
//     final getPromotionsModel = getPromotionsModelFromJson(jsonString);

import 'dart:convert';

GetPromotionsModel getPromotionsModelFromJson(String str) => GetPromotionsModel.fromJson(json.decode(str));

String getPromotionsModelToJson(GetPromotionsModel data) => json.encode(data.toJson());

class GetPromotionsModel {
    int? count;
    List<Result>? result;

    GetPromotionsModel({
        this.count,
        this.result,
    });

    factory GetPromotionsModel.fromJson(Map<String, dynamic> json) => GetPromotionsModel(
        count: json["count"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    dynamic name;
    dynamic programType;

    Result({
        this.id,
        this.name,
        this.programType,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        programType: json["program_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "program_type": programType,
    };
}
