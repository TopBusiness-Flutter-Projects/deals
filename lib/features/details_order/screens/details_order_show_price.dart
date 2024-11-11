import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stepindicator/flutter_stepindicator.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/details_order/screens/widgets/card_from_details_order.dart';
import 'package:top_sale/features/details_order/screens/widgets/product_card.dart';
import 'package:top_sale/features/login/widget/custom_button.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/models/get_orders_model.dart';
import 'package:easy_localization/easy_localization.dart' as tr;
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/utils/dialogs.dart';
import '../cubit/details_orders_cubit.dart';
import '../cubit/details_orders_state.dart';
import 'widgets/custom_order_details_item.dart';

class DetailsOrderShowPrice extends StatefulWidget {
  DetailsOrderShowPrice(
      {super.key, required this.orderModel, required this.isClientOrder});
  bool isDelivered = false;
  bool isClientOrder;
  final OrderModel orderModel;
  @override
  State<DetailsOrderShowPrice> createState() => _DetailsOrderShowPriceState();
}

class _DetailsOrderShowPriceState extends State<DetailsOrderShowPrice> {
  @override
  void initState() {
    context
        .read<DetailsOrdersCubit>()
        .getDetailsOrders(orderId: widget.orderModel.id ?? -1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsOrdersCubit, DetailsOrdersState>(
      builder: (context, state) {
        var cubit = context.read<DetailsOrdersCubit>();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            actions: [
              (widget.orderModel.state == 'draft' && !widget.isClientOrder)
                  ? IconButton(
                      onPressed: () {
                        cubit.cancelOrder(
                            orderId: cubit.getDetailsOrdersModel!.id ?? -1,
                            orderModel: widget.orderModel,
                            context: context);
                      },
                      icon: Text("cancel".tr(),
                          style: TextStyle(
                            fontFamily: AppStrings.fontFamily,
                            color: AppColors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          )))
                  : IconButton(
                      onPressed: () {
                        print("ssssssssssssssssssssss");
                        Navigator.pushNamed(
                            context, Routes.detailsOrderShowPriceReturns,
                            arguments: {
                              'isClientOrder': false,
                              'orderModel': widget.orderModel
                            });
                      },
                      icon: Text("return_order".tr(),
                          style: TextStyle(
                            fontFamily: AppStrings.fontFamily,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          )))
            ],
            leading: IconButton(
                onPressed: () {
                   cubit.onClickBack(context);
                },
                icon: const Icon(Icons.arrow_back)),
            backgroundColor: AppColors.white,
            centerTitle: false,
            //leadingWidth: 20,
            title: Text(
              'details_order'.tr(),
              style: TextStyle(
                  fontFamily: AppStrings.fontFamily,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: getSize(context) / 33,
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: getSize(context) / 30, right: getSize(context) / 30),
                child: (cubit.getDetailsOrdersModel == null)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CardDetailsOrders(
                            isShowPrice: !widget.isClientOrder,
                            onTap: () {
                              cubit.newAllDiscountController.text =
                                  '0.0'.toString();
                              customShowBottomSheet(
                                  context, cubit.newAllDiscountController,
                                  onPressed: () {
                                if (double.parse(cubit
                                        .newAllDiscountController.text
                                        .toString()) <
                                    100) {
                                  cubit.onChnageAllDiscountOfUnit(context);
                                } else {
                                  errorGetBar('discount_validation'.tr());
                                }
                              });
                            },
                            orderModel: widget.orderModel,
                            orderDetailsModel: cubit.getDetailsOrdersModel!,
                          ),
                          SizedBox(height: getSize(context) / 12),
                          Flexible(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: cubit
                                    .getDetailsOrdersModel!.orderLines!.length,
                                itemBuilder: (context, index) {
                                  return widget.isClientOrder == true
                                      ? ProductCard(
                                          order: widget.orderModel,
                                          title: cubit.getDetailsOrdersModel
                                              ?.orderLines?[index].productName,
                                          price: cubit
                                                  .getDetailsOrdersModel
                                                  ?.orderLines?[index]
                                                  .priceSubtotal
                                                  .toString() ??
                                              '',
                                          text: cubit
                                                  .getDetailsOrdersModel
                                                  ?.orderLines?[index]
                                                  .productName ??
                                              '',
                                          number: cubit
                                                  .getDetailsOrdersModel
                                                  ?.orderLines?[index]
                                                  .productUomQty
                                                  .toString() ??
                                              '',
                                        )
                                      : CustomOrderDetailsShowPriceItem(
                                        isReturned: false,
                                          onPressed: () {
                                            //! on delete add item tp list to send it kat reqiesu of update
                                            setState(() {
                                              cubit.removeItemFromOrderLine(
                                                  index);
                                            });
                                          },
                                          item: cubit.getDetailsOrdersModel!
                                              .orderLines![index]);
                                }),
                          ),
                        ],
                      ),
              )),
              (state is LoadingUpdateQuotation ||
                      state is LoadingConfirmQuotation)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : cubit.getDetailsOrdersModel?.orderLines?.length == 0
                      ? Container()
                      : widget.isClientOrder == true
                          ? SizedBox()
                          : CustomButton(
                              title: 'make_order'.tr(),
                              onTap: () {
                                cubit.updateQuotation(
                                    orderModel: widget.orderModel,
                                    context: context,
                                    partnerId:
                                        widget.orderModel.partnerId?.id ?? -1);
                                //! api of update quotaion
                              },
                            ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 90.w,
                    padding: EdgeInsets.only(
                        left: 10.w, right: 10.w, top: 15.h, bottom: 10.h),
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Column(
                          // alignment: Alignment.center,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText('show_price'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600)),
                                  AutoSizeText('new'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600)),
                                  AutoSizeText('delivered'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600)),
                                  AutoSizeText('complete'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            // widget.isClientOrder==true?
                            //     SizedBox():
                            FlutterStepIndicator(
                              division: 3,
                              height: 28.h,
                              positiveColor: AppColors.orange,
                              negativeColor:
                                  const Color.fromRGBO(213, 213, 213, 1),
                              list: cubit.list,
                              onChange: (i) {},
                              positiveCheck: const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                              page: 0,
                              disableAutoScroll: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
