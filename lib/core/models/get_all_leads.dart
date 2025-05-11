// To parse this JSON data, do
//
//     final getMyLeadsModel = getMyLeadsModelFromJson(jsonString);

import 'dart:convert';

GetMyLeadsModel getMyLeadsModelFromJson(String str) => GetMyLeadsModel.fromJson(json.decode(str));

String getMyLeadsModelToJson(GetMyLeadsModel data) => json.encode(data.toJson());

class GetMyLeadsModel {
    List<LeadModel>? leads;

    GetMyLeadsModel({
        this.leads,
    });

    factory GetMyLeadsModel.fromJson(Map<String, dynamic> json) => GetMyLeadsModel(
        leads: json["leads"] == null ? [] : List<LeadModel>.from(json["leads"]!.map((x) => LeadModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "leads": leads == null ? [] : List<dynamic>.from(leads!.map((x) => x.toJson())),
    };
}

class LeadModel {
    int? id;
    dynamic? name;
    dynamic? partnerName;
    dynamic? emailFrom;
    dynamic? phone;
    int? userId;
    dynamic? userName;
    int? employeeId;
    dynamic? employeeName;
    dynamic? stage;
    dynamic? createDate;

    LeadModel({
        this.id,
        this.name,
        this.partnerName,
        this.emailFrom,
        this.phone,
        this.userId,
        this.userName,
        this.employeeId,
        this.employeeName,
        this.stage,
        this.createDate,
    });

    factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        id: json["id"],
        name: json["name"],
        partnerName: json["partner_name"],
        emailFrom: json["email_from"],
        phone: json["phone"],
        userId: json["user_id"],
        userName: json["user_name"],
        employeeId: json["employee_id"],
        employeeName: json["employee_name"],
        stage: json["stage"],
        createDate: json["create_date"] ,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "partner_name": partnerName,
        "email_from": emailFrom,
        "phone": phone,
        "user_id": userId,
        "user_name": userName,
        "employee_id": employeeId,
        "employee_name": employeeName,
        "stage": stage,
        "create_date": createDate,
    };
}
