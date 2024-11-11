import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/utils/app_colors.dart';
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

class BasketScreen extends StatefulWidget {
  const BasketScreen({
    required this.partner,
    required this.currency,
    super.key,
  });
  final AllPartnerResults? partner;

  final String currency;
  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
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
                        arguments: ["products".tr(), '-1']);
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
              return Column(
                children: [
                  //! Cusomer name
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 14),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.grey2Color,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          ImageAssets.profileIconPng,
                          width: getSize(context) / 8,
                          height: getSize(context) / 8,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    widget.partner?.name ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                                widget.partner?.phone.toString() == 'false'
                                    ? Container()
                                    : InkWell(
                                        onTap: () async {
                                          await launchPhoneDialer(
                                              widget.partner?.phone ?? '');
                                        },
                                        child: Text(
                                          widget.partner?.phone.toString() ??
                                              '_',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        // InkWell(
                        //   onTap: () {
                        //     //!total discount add discount
                        //     // customShowBottomSheet(context, cubit);
                        //   },
                        //   child: Image.asset(
                        //     ImageAssets.discount,
                        //     width: getSize(context) / 12,
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 5.0),
                          child: Column(
                            children: [
                              Text(
                                'total'.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                '${calculateTotalDiscountedPrice(cubit2.basket)} ${cubit2.basket.isEmpty ? '' : context.read<HomeCubit>().currencyName}',
                                // '${calculateTotalDiscountedPrice(cubit2.basket)} ${cubit2.basket.isEmpty ? '' : cubit2.basket.first.currencyId?.name ?? ''}',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                              cubit2.basket.isEmpty
                                  ? Container()
                                  : InkWell(
                                      onTap: () {
                                        cubit2.newAllDiscountController.text =
                                            '0.0'.toString();
                                        customShowBottomSheet(context,
                                            cubit2.newAllDiscountController,
                                            onPressed: () {
                                          if (double.parse(cubit2
                                                  .newAllDiscountController.text
                                                  .toString()) <
                                              100) {
                                            cubit2.onChnageAllDiscountOfUnit(
                                                context);
                                          } else {
                                            errorGetBar(
                                                'discount_validation'.tr());
                                          }
                                        });

                                        //! add discount

                                        // customShowBottomSheet(
                                        //   context,
                                        //   cubit.controllerPercent,
                                        //   onPressed: () {
                                        //     //! set dis count to model
                                        //     //! cal the new value of price
                                        //     //! case all discout remove discount of itms first then make all and loop on them
                                        //     //! clear controller
                                        //   },
                                        // );
                                      },
                                      child: Image.asset(
                                        ImageAssets.discount,
                                        width: getSize(context) / 14,
                                      ),
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )

                  //! Cusomer name
                  ,
                  SizedBox(
                    height: getSize(context) / 16,
                  ),
                  cubit2.basket.isEmpty
                      ? Center(child: Text("لا يوجد منتجات في السلة"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: cubit2.basket.length,
                          itemBuilder: (context, index) {
                            var item = cubit2.basket[index];
                            return CustomBasketItem(item: item);
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
                              title: 'show_price'.tr(),
                              onTap: () {
                                cubit2.createQuotation(
                                    warehouseId: '1',
                                    context: context,
                                    partnerId: widget.partner?.id ?? -1);
                                //!
                              })
                ],
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
