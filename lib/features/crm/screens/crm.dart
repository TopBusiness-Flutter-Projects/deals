import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';

import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';

import 'package:top_sale/features/clients/cubit/clients_cubit.dart';
import 'package:top_sale/features/crm/cubit/crm_state.dart';

import '../cubit/crm_cubit.dart';
import 'widgets/crm_container.dart';

class CRMScreen extends StatefulWidget {
  const CRMScreen({super.key});

  @override
  State<CRMScreen> createState() =>
      _CRMScreenState();
}

class _CRMScreenState extends State<CRMScreen> {
  @override
  void initState() {
    context.read<CRMCubit>().getExchangePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CRMCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('clients_deals'.tr()),
        centerTitle: false,
        titleTextStyle: getBoldStyle(
          fontSize: 20.sp,
          color: AppColors.black,
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only( bottom: 60.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90.sp),
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
             Navigator.pushNamed(context, Routes.clientsRoute,
              arguments: ClientsRouteEnum.crm);
                                    
          },
          child: Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocBuilder<CRMCubit, CRMState>(
          builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0.sp, right: 10.0.sp),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // cubit.getPickingsModel == null ||
              //         cubit.getPickingsModel!.result == null
              //     ? const Center(child: CustomLoadingIndicator())
              //     : cubit.getPickingsModel!.result!.data!.isEmpty
              //         ? Center(child: Text("no_data".tr()))
              //         :
                       Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              cubit.getExchangePermission();
                            },
                            child: ListView.builder(
                                itemCount:
                                    10,
                                // itemCount: cubit.getPickingsModel?.result?.data
                                //         ?.length ??
                                //     0,
                                itemBuilder: (context, index) {
                                  return CustomCRMContainer(
                                    isClickable: true,
                                  );
                                }),
                          ),
                        ),
            ],
          ),
        );
      }),
    );
  }
}
