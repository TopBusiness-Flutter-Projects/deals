import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/features/exchange_permission/cubit/exchange_permission_state.dart';
import 'package:top_sale/features/returns/cubit/returns_cubit.dart';
import 'package:top_sale/features/returns/cubit/returns_state.dart';
import '../cubit/exchange_permission_cubit.dart';

class ExchangePermissionScreen extends StatefulWidget {
  const ExchangePermissionScreen({super.key});

  @override
  State<ExchangePermissionScreen> createState() =>
      _ExchangePermissionScreenState();
}

class _ExchangePermissionScreenState extends State<ExchangePermissionScreen> {
  @override
  void initState() {
    context.read<ExchangePermissionCubit>().getExchangePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ExchangePermissionCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('exchange_permissions'.tr()),
        centerTitle: false,
        titleTextStyle: getBoldStyle(
          fontSize: 20.sp,
          color: AppColors.black,
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90.sp),
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, Routes.productsRoute,
                arguments: ["انشاء اذن الصرف", '0']);
          },
          child: Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocBuilder<ExchangePermissionCubit, ExchangePermissionState>(
          builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0.sp, right: 10.0.sp),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              cubit.getPickingsModel == null ||
                      cubit.getPickingsModel!.result == null
                  ? const Center(child: CircularProgressIndicator())
                  : cubit.getPickingsModel!.result!.data!.isEmpty
                      ? Center(child: Text("no_data".tr()))
                      : Expanded(
                          child: ListView.builder(
                              itemCount: cubit
                                      .getPickingsModel?.result?.data?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
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
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.sp),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AutoSizeText(
                                                    cubit.getPickingsModel
                                                            ?.result?.data
                                                            ?.elementAt(index)
                                                            .scheduledDate
                                                            .toString()
                                                            .substring(0, 10) ??
                                                        "",
                                                    style: getBoldStyle(
                                                        color: AppColors.orange,
                                                        fontSize: 14.sp),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.orange
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.sp),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5,
                                                              top: 2,
                                                              bottom: 2),
                                                      child: AutoSizeText(
                                                        (cubit.getPickingsModel
                                                                ?.result?.data
                                                                ?.elementAt(
                                                                    index)
                                                                .status ??
                                                            ""),
                                                        style: getBoldStyle(
                                                            color: AppColors
                                                                .orange,
                                                            fontSize: 14.sp),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.sp),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AutoSizeText(
                                                    cubit.getPickingsModel
                                                            ?.result?.data
                                                            ?.elementAt(index)
                                                            .transferName ??
                                                        "",
                                                    style: getBoldStyle(
                                                        color: AppColors.black,
                                                        fontSize: 14.sp),
                                                  ),
                                                  AutoSizeText(
                                                    "",
                                                    style: getBoldStyle(
                                                        color: AppColors.blue,
                                                        fontSize: 14.sp),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.sp),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    cubit.getPickingsModel
                                                            ?.result?.data
                                                            ?.elementAt(index)
                                                            .sourceLocation
                                                            ?.locationName ??
                                                        "",
                                                    style: getMediumStyle(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    )
                                  ],
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