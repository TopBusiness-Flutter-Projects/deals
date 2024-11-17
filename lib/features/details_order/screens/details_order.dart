import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as tr;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stepindicator/flutter_stepindicator.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/details_order/cubit/details_orders_cubit.dart';
import 'package:top_sale/features/details_order/cubit/details_orders_state.dart';
import 'package:top_sale/features/details_order/screens/pdf.dart';
import 'package:top_sale/features/details_order/screens/widgets/card_from_details_order.dart';
import 'package:top_sale/features/details_order/screens/widgets/custom_total_price.dart';
import 'package:top_sale/features/details_order/screens/widgets/product_card.dart';
import 'package:top_sale/features/details_order/screens/widgets/rounded_button.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/api/end_points.dart';
import '../../../core/models/get_orders_model.dart';
import '../../../core/models/order_details_model.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';

class DetailsOrder extends StatefulWidget {
  DetailsOrder(
      {super.key, required this.orderModel, required this.isClientOrder});
  bool isDelivered = false;
  bool isClientOrder;
  final OrderModel orderModel;
  @override
  State<DetailsOrder> createState() => _DetailsOrderState();
}

class _DetailsOrderState extends State<DetailsOrder> {
  @override
  void initState() {
    context
        .read<DetailsOrdersCubit>()
        .getDetailsOrders(orderId: widget.orderModel.id ?? -1);
    context.read<DetailsOrdersCubit>().changePage(
        // تم السليم
        widget.orderModel.state == 'sale' &&
                widget.orderModel.invoiceStatus == 'to invoice' &&
                (widget.orderModel.deliveryStatus == 'done' ||
                    widget.orderModel.deliveryStatus == 'full')
            ? 2
            : widget.orderModel.state == 'sale' &&
                    widget.orderModel.invoiceStatus == 'invoiced' &&
                    (widget.orderModel.deliveryStatus == 'done' ||
                        widget.orderModel.deliveryStatus == 'full')
                ? 3
                : widget.orderModel.state == 'sale' &&
                        widget.orderModel.invoiceStatus == 'to invoice' &&
                        (widget.orderModel.deliveryStatus == 'assigned' ||
                            widget.orderModel.deliveryStatus == 'pending')
                    ? 1
                    : 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DetailsOrdersCubit>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          (widget.orderModel.state == 'sale' &&
                  widget.orderModel.invoiceStatus == 'to invoice' &&
                 ( widget.orderModel.deliveryStatus == 'assigned'  ||
              widget.orderModel.deliveryStatus == 'pending')
              )
              ? IconButton(
                  onPressed: () {
                    cubit.cancelOrder(
                        orderId: cubit.getDetailsOrdersModel?.id ?? -1,
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
                        color: AppColors.secondPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      )))
        ],
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
      body: BlocConsumer<DetailsOrdersCubit, DetailsOrdersState>(
          listener: (context, state) {
        if (state is ConfirmDeliveryLoadedState) {
          setState(() {
            // تم السليم
            widget.orderModel.state = 'sale';
            widget.orderModel.invoiceStatus = 'to invoice';
            widget.orderModel.deliveryStatus = 'done';
            // widget.orderModel.deliveryStatus = 'full';
          });
          cubit.changePage(2);
        }
        if (state is CreateAndValidateInvoiceLoadedState) {
          // مكتملة
          setState(() {
            widget.orderModel.state = 'sale';
            widget.orderModel.invoiceStatus = 'invoiced';
            widget.orderModel.deliveryStatus = 'done';
            // widget.orderModel.deliveryStatus = 'full';
          });
          cubit.changePage(3);
        }
        if (state is RegisterPaymentLoadedState) {
          setState(() {
            widget.orderModel.state = 'sale';
            widget.orderModel.invoiceStatus = 'invoiced';
            widget.orderModel.deliveryStatus = 'done';
            // widget.orderModel.deliveryStatus = 'full';
          });
          cubit.changePage(4);
        }
        if (state is LoadingCancel) {
          setState(() {
            widget.orderModel.state = 'cancel';
          });
          //cubit.changePage(4);
        }
        if (state is CreateAndValidateInvoiceLoadingState) {
          setState(() {
            const CircularProgressIndicator();
          });
        }
        if (state is ConfirmDeliveryLoadingState) {
          setState(() {
            const CircularProgressIndicator();
          });
        }
      }, builder: (context, state) {
        return Column(
          children: [
            Flexible(
              child: Column(
                children: [
                  SizedBox(
                    height: getSize(context) / 33,
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(
                        left: getSize(context) / 30,
                        right: getSize(context) / 30),
                    child: (cubit.getDetailsOrdersModel == null)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CardDetailsOrders(
                                orderModel: widget.orderModel,
                                orderDetailsModel: cubit.getDetailsOrdersModel!,
                              ),
                              SizedBox(
                                height: getSize(context) / 12,
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    await cubit.getDetailsOrders(
                                        orderId: widget.orderModel.id ?? -1);
                                  },
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: cubit.getDetailsOrdersModel
                                          ?.orderLines!.length,
                                      itemBuilder: (context, index) {
                                        return ProductCard(
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
                                        );
                                      }),
                                ),
                              ),

                              CustomTotalPrice(
                                currency:
                                    widget.orderModel.currencyId?.name ?? '',
                                price: cubit.getDetailsOrdersModel?.amountTotal
                                        .toString() ??
                                    '',
                                //  calculateTotalDiscountedPrice(
                                //     cubit.getDetailsOrdersModel?.orderLines ??
                                //         [])
                              ),
                              if (cubit
                                  .getDetailsOrdersModel!.invoices!.isNotEmpty)
                                CustomTotalPriceDue(
                                  currency:
                                      widget.orderModel.currencyId?.name ?? '',
                                  price: cubit.getDetailsOrdersModel?.invoices!
                                          .first.amountDue
                                          .toString() ??
                                      '',
                                  state: cubit.getDetailsOrdersModel?.invoices!
                                          .first.paymentState
                                          .toString() ??
                                      '',
                                ),

                              // SizedBox(
                              //   height: getSize(context) / 12,
                              // ),
                              //     تم التسليييييييييييييم
                              widget.orderModel.state == 'sale' &&
                                      widget.orderModel.invoiceStatus ==
                                          'to invoice' &&
                                      (widget.orderModel.deliveryStatus ==
                                              'done' ||
                                          widget.orderModel.deliveryStatus ==
                                              'full')
                                  ? Row(
                                      children: [
                                        widget.isClientOrder == true
                                            ? const Expanded(
                                                child: SizedBox(),
                                              )
                                            : Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: RoundedButton(
                                                    text: 'Create_an_invoice'
                                                        .tr(),
                                                    onPressed: () {
                                                      setState(() {
                                                        cubit.createAndValidateInvoice(
                                                            context,
                                                            orderId: widget
                                                                    .orderModel
                                                                    .id ??
                                                                -1);
                                                      });
                                                    },
                                                    backgroundColor:
                                                        AppColors.blue,
                                                  ),
                                                ),
                                              ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        AppColors.orange),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.print,
                                                    color: AppColors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  AutoSizeText(
                                                    'delivery_order'.tr(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.sp,
                                                        color: AppColors.white),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (cubit
                                                      .getDetailsOrdersModel!
                                                      .pickings!
                                                      .isNotEmpty) {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        return PdfViewerPage(
                                                          baseUrl:
                                                              '${EndPoints.printPicking}${cubit.getDetailsOrdersModel!.pickings![0].pickingId.toString()}',
                                                        );
                                                        // return PaymentWebViewScreen(url: "",);
                                                      },
                                                    ));
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  :
                                  // جديدةةةةةةةةةةةةةةة
                                  (widget.orderModel.state == 'sale' &&
                                              widget.orderModel.invoiceStatus ==
                                                  'to invoice' &&
                                              widget.orderModel
                                                      .deliveryStatus ==
                                                  'pending' ||
                                          widget.orderModel.deliveryStatus ==
                                              'assigned')
                                      ? Row(
                                          children: [
                                            widget.isClientOrder == true
                                                ? const Expanded(
                                                    child: SizedBox())
                                                : Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: RoundedButton(
                                                        text:
                                                            'delivery_confirmation'
                                                                .tr(),
                                                        onPressed: () {
                                                          setState(() {
                                                            cubit.confirmDelivery(
                                                                context,
                                                                orderId: widget
                                                                        .orderModel
                                                                        .id ??
                                                                    -1,
                                                                pickingId: cubit
                                                                        .getDetailsOrdersModel
                                                                        ?.pickings?[
                                                                            0]
                                                                        .pickingId ??
                                                                    -1);
                                                          });
                                                        },
                                                        backgroundColor:
                                                            AppColors.blue,
                                                      ),
                                                    ),
                                                  ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(AppColors
                                                                .orange),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.print,
                                                        color: AppColors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ),
                                                      Text(
                                                        'order_sales'.tr(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20.sp,
                                                            color: AppColors
                                                                .white),
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (cubit
                                                              .getDetailsOrdersModel!
                                                              .id !=
                                                          null) {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                          builder: (context) {
                                                            return PdfViewerPage(
                                                              baseUrl:
                                                                  '/report/pdf/sale.report_saleorder/${cubit.getDetailsOrdersModel!.id.toString()}',
                                                            );
                                                            // return PaymentWebViewScreen(url: "",);
                                                          },
                                                        ));
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : widget.orderModel.state == 'sale' &&
                                              widget.orderModel.invoiceStatus ==
                                                  'invoiced' &&
                                              (widget.orderModel
                                                          .deliveryStatus ==
                                                      'done' ||
                                                  widget.orderModel
                                                          .deliveryStatus ==
                                                      'full')
                                          ?
                                          // مكتملةةةةةةةةةةةة
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                (cubit
                                                            .getDetailsOrdersModel!
                                                            .invoices!
                                                            .isNotEmpty &&
                                                        cubit
                                                            .getDetailsOrdersModel!
                                                            .payments!
                                                            .isEmpty)
                                                    ? widget.isClientOrder ==
                                                            true
                                                        ? const Expanded(
                                                            child: SizedBox())
                                                        :
                                                        // ادفع
                                                        Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child:
                                                                  RoundedButton(
                                                                text: 'payment'
                                                                    .tr(),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        Routes
                                                                            .paymentRoute,
                                                                        arguments:
                                                                            false);
                                                                    // cubit.createAndValidateInvoice(
                                                                    //     orderId: widget.orderModel.id ?? -1);
                                                                  });
                                                                },
                                                                backgroundColor:
                                                                    AppColors
                                                                        .blue,
                                                              ),
                                                            ),
                                                          )
                                                    :
                                                    // الدفع وسند القبض
                                                    cubit.getDetailsOrdersModel!
                                                            .invoices!.isNotEmpty
                                                        ? Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  if (cubit
                                                                              .getDetailsOrdersModel!
                                                                              .invoices!
                                                                              .first
                                                                              .amountDue <
                                                                          cubit
                                                                              .getDetailsOrdersModel!
                                                                              .invoices!
                                                                              .first
                                                                              .amountTotal &&
                                                                      cubit
                                                                              .getDetailsOrdersModel!
                                                                              .invoices!
                                                                              .first
                                                                              .amountDue >
                                                                          0)
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10.0),
                                                                      child:
                                                                          RoundedButton(
                                                                        text: 'payment'
                                                                            .tr(),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            Navigator.pushNamed(context,
                                                                                Routes.paymentRoute,
                                                                                arguments: false);
                                                                            // cubit.createAndValidateInvoice(
                                                                            //     orderId: widget.orderModel.id ?? -1);
                                                                          });
                                                                        },
                                                                        backgroundColor:
                                                                            AppColors.blue,
                                                                      ),
                                                                    ),

                                                                  // طباعة سند القبض
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10.0),
                                                                    child:
                                                                        ElevatedButton(
                                                                      style:
                                                                          ButtonStyle(
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(AppColors.blue),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Center(
                                                                            child:
                                                                                Icon(
                                                                              Icons.print,
                                                                              color: AppColors.white,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                5.w,
                                                                          ),
                                                                          Center(
                                                                            child: AutoSizeText('receipt_voucher'.tr(),
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: AppColors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 20.sp,
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        if (cubit
                                                                            .getDetailsOrdersModel!
                                                                            .payments!
                                                                            .isNotEmpty) {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                            builder:
                                                                                (context) {
                                                                              return PdfViewerPage(
                                                                                baseUrl: '${EndPoints.printPayment}${cubit.getDetailsOrdersModel!.payments![0].paymentId.toString()}',
                                                                              );
                                                                              // return PaymentWebViewScreen(url: "",);
                                                                            },
                                                                          ));
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                // طباعة الفاتورة
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(AppColors
                                                                    .orange),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.print,
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 5.w,
                                                          ),
                                                          Text('invoice'.tr(),
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20.sp,
                                                              )),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                          builder: (context) {
                                                            return PdfViewerPage(
                                                              baseUrl:
                                                                  '/report/pdf/account.report_invoice_with_payments/${cubit.getDetailsOrdersModel!.invoices!.first.invoiceId.toString()}',
                                                            );
                                                            // return PaymentWebViewScreen(url: "",);
                                                          },
                                                        ));

                                                        // Navigator.pushNamed(context, Routes.paymentRoute);
                                                        // cubit.createAndValidateInvoice(
                                                        //     orderId: widget.orderModel.id ?? -1);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),

                              // const Expanded(child: SizedBox()),
                            ],
                          ),
                  ))
                ],
              ),
            ),
            cubit.getDetailsOrdersModel?.state == 'cancel'
                ? const SizedBox()
                : Container(
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
                        height: 80.w,
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
                                  page: cubit.page,
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
        );
      }),
    );
  }
}

String calculateTotalDiscountedPrice(List<OrderLine> items) {
  double total = items.fold(0.0, (sum, item) {
    dynamic priceUnit = item.priceUnit;
    dynamic quantity = item.productUomQty;
    dynamic discount = item.discount;
    // Calculate the total price with the discount applied for the current item
    double totalPrice = (priceUnit * quantity) * (1 - discount / 100);
    // Add to the running total
    return sum + totalPrice;
  });
  // Return the total formatted to 2 decimal places
  return total.toStringAsFixed(2);
}
