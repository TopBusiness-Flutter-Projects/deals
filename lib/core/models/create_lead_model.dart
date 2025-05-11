// To parse this JSON data, do
//
//     final createLeadModel = createLeadModelFromJson(jsonString);

import 'dart:convert';

CreateLeadModel createLeadModelFromJson(String str) => CreateLeadModel.fromJson(json.decode(str));

String createLeadModelToJson(CreateLeadModel data) => json.encode(data.toJson());

class CreateLeadModel {
  
    Result? result;

    CreateLeadModel({
    
        this.result,
    });

    factory CreateLeadModel.fromJson(Map<String, dynamic> json) => CreateLeadModel(
      
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
      
        "result": result?.toJson(),
    };
}

class Result {
    int? leadId;
    String? message;

    Result({
        this.leadId,
        this.message,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        leadId: json["lead_id"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "lead_id": leadId,
        "message": message,
    };
}
