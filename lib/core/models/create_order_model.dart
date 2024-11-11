// To parse this JSON data, do
//
//     final createOrderModel = createOrderModelFromJson(jsonString);

import 'dart:convert';

CreateOrderModel createOrderModelFromJson(String str) =>
    CreateOrderModel.fromJson(json.decode(str));

String createOrderModelToJson(CreateOrderModel data) =>
    json.encode(data.toJson());

class CreateOrderModel {
  Result? result;

  CreateOrderModel({
    this.result,
  });

  factory CreateOrderModel.fromJson(Map<String, dynamic> json) =>
      CreateOrderModel(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result?.toJson(),
      };
}

class Result {
  dynamic message;
  
  dynamic paymentId;
  dynamic orderId;
 

  Result({
    this.message,
    this.paymentId,
    this.orderId,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        message: json["message"],
        paymentId: json["payment_id"],
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "payment_id": paymentId,
        "order_id": orderId,
      };
}

class Error {
  String? message;

  Error({
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
