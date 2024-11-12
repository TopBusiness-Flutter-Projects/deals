

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/models/returned_order_model.dart';
import 'package:top_sale/core/remote/service.dart';

import 'exchange_permission_state.dart';

class ExchangePermissionCubit extends Cubit<ExchangePermissionState> {
  ExchangePermissionCubit(this.api) : super(ExchangePermissionInitial());
  ServiceApi api;
  TextEditingController searchController = TextEditingController();
  ReturnedOrderModel? returnOrderModel;
  void getExchangePermission() async {
    emit(GetExchangePermissionLoadingState());
    final result = await api.returnedOrder();
    result.fold(
          (failure) =>
          emit(GetExchangePermissionErrorState()),
          (r) {
            returnOrderModel = r;
        emit(GetExchangePermissionLoadedState());
      },
    );
  }
}
