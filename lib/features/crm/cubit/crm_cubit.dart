

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/remote/service.dart';
import '../../../core/models/get_pickings_model.dart';
import 'crm_state.dart';

class CRMCubit extends Cubit<CRMState> {
  CRMCubit(this.api) : super(CRmInitial());
  ServiceApi api;
  TextEditingController chanceController = TextEditingController();
   TextEditingController noteController = TextEditingController();
  GetPickingsModel? getPickingsModel;
  void getExchangePermission() async {
    emit(GetExchangePermissionLoadingState());
    final result = await api.getPicking();
    result.fold(
          (failure) =>
          emit(GetExchangePermissionErrorState()),
          (r) {
            getPickingsModel = r;
        emit(GetExchangePermissionLoadedState());
      },
    );
  }
}
