import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/circle_progress.dart';
import 'package:top_sale/core/utils/get_size.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DailyOrders extends StatefulWidget {
  const DailyOrders({super.key});
  @override
  State<DailyOrders> createState() => _DailyOrdersState();
}

class _DailyOrdersState extends State<DailyOrders> {
  @override
  void initState() {
    // context.read<HomeCubit>().getReturned();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<HomeCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('المبيعات اليومية'.tr()),
        centerTitle: false,
        titleTextStyle: getBoldStyle(
          fontSize: 20.sp,
          color: AppColors.black,
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0.sp, right: 10.0.sp),
          child: Column(
            children: [
              // CustomTextField(
              //   controller: cubit.searchController,
              //   // onChanged: cubit.onChangeSearch,
              //   labelText: "search_from_user".tr(),
              //   prefixIcon: Icon(
              //     Icons.search_rounded,
              //     size: 35,
              //     color: AppColors.gray2,
              //   ),
              // ),

              SizedBox(height: 20.h),

              //     cubit.returnOrderModel!.result == null
              // ? const Center(child: CustomLoadingIndicator())
              // : cubit.returnOrderModel!.result!.data!.isEmpty
              //     ? Center(child: Text("no_data".tr()))
              //     :
              Expanded(
                child: ListView.builder(
                    itemCount: 10,
                    //  cubit.returnOrderModel?.result
                    //         ?.data?.length ??
                    //     0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(8.0.sp),
                        child: Container(
                            padding: EdgeInsets.only(
                              left: 8.0.sp,
                              right: 8.0.sp,
                              top: 10.0.sp,
                              bottom: 10.0.sp,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurStyle: BlurStyle.outer,
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: AppColors.gray2,
                                          size: 20.sp,
                                        ),
                                        SizedBox(
                                          width: 5.sp,
                                        ),
                                        Text(
                                          "cubiteeName " ?? "",
                                          style: getBoldStyle(
                                              color: AppColors.black,
                                              fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 2, bottom: 2),
                                      child: AutoSizeText(
                                          "cubit.rntAt(index).dg(0,10)" ?? "",
                                          style: getBoldStyle(
                                              color: AppColors.black,
                                              fontSize: 14.sp)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.sp,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText(
                                      "cubdex).name" ?? "",
                                      style: getBoldStyle(
                                          color: AppColors.black,
                                          fontSize: 14.sp),
                                    ),
                                    AutoSizeText(
                                      "cubit.amountToted(0)" +
                                          "  ${context.read<HomeCubit>().currencyName}",
                                      style: getBoldStyle(
                                          color: AppColors.blue,
                                          fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.sp,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "dd"
                                        // "cubit.returnOrderModel?.result?.data?.elementAt(index).status!.toString() == "false" ? "":cubit.returnOrderModel?.result?.data?.elementAt(index).status"
                                        ,
                                        style: getMediumStyle()),
                                    //                   GestureDetector(
                                    // onTap: () {

                                    //   Navigator.push(context, MaterialPageRoute(
                                    //     builder: (context) {
                                    //       return PdfViewerPage(
                                    //         baseUrl: EndPoints.printInvoice +
                                    //         (cubit.returnOrderModel?.result?.data?.elementAt(index).id.toString() ?? ""),
                                    //       );
                                    //     },
                                    //   ));
                                    // },
                                    // child: SvgPicture.asset(ImageAssets.printIcon)),
                                  ],
                                )
                              ],
                            )),
                      );
                    }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
