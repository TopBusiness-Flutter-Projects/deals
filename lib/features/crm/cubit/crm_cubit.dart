

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/models/get_all_leads.dart';
import 'package:top_sale/core/remote/service.dart';
import 'package:top_sale/core/utils/appwidget.dart';
import 'package:top_sale/core/utils/dialogs.dart';
import '../../../core/models/get_pickings_model.dart';
import 'crm_state.dart';

class CRMCubit extends Cubit<CRMState> {
  CRMCubit(this.api) : super(CRmInitial());
  ServiceApi api;
  TextEditingController chanceController = TextEditingController();
   TextEditingController noteController = TextEditingController();
   TextEditingController priceController = TextEditingController();
  GetMyLeadsModel? getPickingsModel;
  void getMyLeads() async {
    emit(GetExchangePermissionLoadingState());
    final result = await api.getMyLeads();
    result.fold(
          (failure) =>
          emit(GetExchangePermissionErrorState()),
          (r) {
            getPickingsModel = r;
        emit(GetExchangePermissionLoadedState());
      },
    );
  }
  
  createLead(
    BuildContext context, {
    required double lat,
    required double long,   
    required String address,
     String? partnerName,
     String? partnerPhone,
  }) async {
    // getIp();
    AppWidget.createProgressDialog(context);
    emit(CheckInOutLoading());
   
    final result = await api.createLead(
      name: chanceController.text,
      address: address,
      partnerName: partnerName,
      phone: partnerPhone,


      
      latitude: lat,
      longitude: long,
     
    );
    result.fold(
      (failure) {
        Navigator.pop(context);
        errorGetBar("error".tr());
        emit(CheckInOutError());
      },
      (r) {
        Navigator.pop(context);
        // if (r.result != null) {
        //   if (r.result!.message != null) {
        //     if (getLastAttendanceModel!.lastAttendance != null){
        //       getLastAttendanceModel!.lastAttendance!.status =
        //         isChechIn ? "check-in" : "check-out";}
            
        //     successGetBar(r.result!.message!);
        //     getMyLeads();
        //   } else {
        //     // if (r.result!.error != null) {
        //     //   errorGetBar(r.result!.error!.message ?? "error".tr());
        //     // } else {
        //       errorGetBar("error".tr());
        //     //}
        //   }
        // } else {
        //   errorGetBar("error".tr());
        // }

        emit(CheckInOutLoaded());
      },
    );
  }

}
