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
  TextEditingController descriptionController = TextEditingController();
  GetMyLeadsModel? getPickingsModel;
  void getMyLeads() async {
    emit(GetExchangePermissionLoadingState());
    final result = await api.getMyLeads();
    result.fold(
      (failure) => emit(GetExchangePermissionErrorState()),
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
    String? partnerId,
  }) async {
    // getIp();
    AppWidget.createProgressDialog(context);
    emit(CheckInOutLoading());
    final result = await api.createLead(
      name: chanceController.text,
      description: descriptionController.text,
      price: priceController.text,
      address: address,
      partnerId: partnerId,
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
        if (r.result != null) {
          if (r.result!.message != null) {
            Navigator.pop(context);
            successGetBar(r.result!.message!);
            chanceController.clear();
            descriptionController.clear();
            priceController.clear();
            getMyLeads();
          }
        } else {
          errorGetBar("error".tr());
        }

        emit(CheckInOutLoaded());
      },
    );
  }

  updateLead(
    BuildContext context, {
    required double lat,
    required double long,
    required String address,
    required bool isStart,
    required String leadId,
  }) async {
    // getIp();
    AppWidget.createProgressDialog(context);
    emit(CheckInOutLoading());
    final result = await api.updateLead(
      description: noteController.text,
      price: priceController.text,
      address: address,
      isStart: isStart,
      leadId: leadId,
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
        if (r.result != null) {
          if (r.result!.message != null) {
            if (!isStart) {
              Navigator.pop(context);
            }
            successGetBar(r.result!.message!);
            getMyLeads();
          }
        } else {
          errorGetBar("error".tr());
        }

        emit(CheckInOutLoaded());
      },
    );
  }
}
