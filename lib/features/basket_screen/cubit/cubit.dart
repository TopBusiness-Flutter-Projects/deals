import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/models/all_ware_house_model.dart';
import 'package:top_sale/core/remote/service.dart';

import 'state.dart';

class BasketCubit extends Cubit<BasketState> {
  BasketCubit(this.api) : super(InitBasketState());
  ServiceApi api;
  int? selectedWareHouseId;
  AllWareHouseModel? getWareHousesModel;
  Future<void> getWareHouses() async {
    emit(LoadingGetWareHouses());
    final response = await api.getWareHouses();
    response.fold((l) {
      emit(ErrorGetWareHouses());
    }, (right) async {
      getWareHousesModel = right;
      emit(SuccessGetWareHouses());
    });
  }
  WareHouse? myWareHouse;
  Future<void> getMyWareHouse() async {
    emit(LoadingGetWareHouses());
    final response = await api.getWareHouseById();
    response.fold((l) {
      emit(ErrorGetWareHouses());
    }, (right) async {
      myWareHouse = right;
      emit(SuccessGetWareHouses());
    });
  }
}
