import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/assets_manager.dart';
import 'package:top_sale/core/utils/dialogs.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/basket_screen/cubit/cubit.dart';
import 'package:top_sale/features/home_screen/cubit/cubit.dart';
import 'package:top_sale/features/login/widget/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/all_partners_for_reports_model.dart';
import '../../../core/models/all_products_model.dart';
import '../../direct_sell/cubit/direct_sell_cubit.dart';
import '../../direct_sell/cubit/direct_sell_state.dart';
import '../cubit/state.dart';
import 'custom_basket_item.dart';

class DispensingBasketScreen extends StatefulWidget {
  const DispensingBasketScreen({
    // required this.partner,
    // required this.currency,
    super.key,
  });
  // final AllPartnerResults? partner;
  // final String currency;
  @override
  State<DispensingBasketScreen> createState() => _DispensingBasketScreenState();
}

class _DispensingBasketScreenState extends State<DispensingBasketScreen> {
  @override
  void initState() {
    context.read<BasketCubit>().getWareHouses();
    context.read<BasketCubit>().getMyWareHouse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectSellCubit, DirectSellState>(
      builder: (context, state) {
        var cubit = context.read<BasketCubit>();
        var cubit2 = context.read<DirectSellCubit>();
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.productsRoute,
                        arguments: ["انشاء اذن الصرف", '0']);
                  },
                  child: Container(
                    height: 30.sp,
                    width: 30.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadiusDirectional.circular(90),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 20.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            title: Text(
              'basket'.tr(),
              style: TextStyle(
                color: AppColors.black,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: BlocBuilder<BasketCubit, BasketState>(
                builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      child: Text(
                        "من",
                        style: getMediumStyle(),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (cubit.getWareHousesModel != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: cubit
                                .selectedWareHouseId, // This will store the ID (not the name)
                            hint: Text(
                              'Select Warehouse',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            isExpanded: true,
                            onChanged: (int? newValue) {
                              setState(() {
                                cubit.selectedWareHouseId =
                                    newValue; // Store the ID in cubit
                              });
                            },
                            items: cubit.getWareHousesModel?.result
                                    ?.map<DropdownMenuItem<int>>((resultItem) {
                                  return DropdownMenuItem<int>(
                                    value: resultItem.id,
                                    child: Text(resultItem.name ??
                                        ''), // Display the name
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      child: Text(
                        "الي",
                        style: getMediumStyle(),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (cubit.myWareHouse != null)
                      Text(
                        cubit.myWareHouse?.name ?? "",
                        style: getBoldStyle(),
                      ),
                    SizedBox(
                      height: 20.h,
                    ),
                    cubit2.basket.isEmpty
                        ? Center(child: Text("لا يوجد منتجات في السلة"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: cubit2.basket.length,
                            itemBuilder: (context, index) {
                              var item = cubit2.basket[index];
                              return CustomBasketItem(
                                item: item,
                                isEditable: false,
                              );
                            },
                          ),
                    SizedBox(height: 32.h),
                    (state is LoadingCreateQuotation)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : cubit2.basket.isEmpty
                            ? Container()
                            : CustomButton(
                                title: 'تأكيد اذن الصرف',
                                onTap: () {
                                  if (cubit.selectedWareHouseId == null ||
                                      cubit.myWareHouse == null) {
                                    errorGetBar(
                                        'يرجى تحديد المستودع و المستودع الخاص بك');
                                  } else if (cubit.selectedWareHouseId ==
                                      cubit.myWareHouse?.id) {
                                    errorGetBar(
                                        'لا يمكنك اذن صرف من المستودع الخاص بك');
                                  } else {
                                    cubit2.createPicking(
                                      context: context,
                                      pickingId:
                                          cubit.selectedWareHouseId ?? -1,
                                    );
                                  }
                                  // cubit2.createQuotation(
                                  //     warehouseId: '1',
                                  //     context: context,
                                  //     partnerId: widget.partner?.id ?? -1);
                                  //!
                                })
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw 'Could not launch phone dialer for $phoneNumber';
    }
  }

  String calculateTotalDiscountedPrice(List<ProductModelData> items) {
    double total = items.fold(0.0, (sum, item) {
      dynamic priceUnit = item.listPrice;
      dynamic quantity = item.userOrderedQuantity;
      dynamic discount = item.discount;

      // Calculate the total price with the discount applied for the current item
      double totalPrice = (priceUnit * quantity) * (1 - discount / 100);

      // Add to the running total
      return sum + totalPrice;
    });

    // Return the total formatted to 2 decimal places
    return total.toStringAsFixed(2);
  }
}
