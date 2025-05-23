import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/models/all_partners_for_reports_model.dart';
import 'package:top_sale/core/models/get_all_leads.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/app_strings.dart';
import 'package:top_sale/core/utils/assets_manager.dart';
import 'package:top_sale/core/utils/custom_button.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/clients/cubit/clients_cubit.dart';
import 'package:top_sale/features/clients/screens/widgets/custom_card_client.dart';
import 'package:top_sale/features/crm/cubit/crm_state.dart';
import 'package:top_sale/features/details_order/screens/widgets/rounded_button.dart';
import 'package:top_sale/features/login/widget/textfield_with_text.dart';
import '../cubit/crm_cubit.dart';

class CreateDealScreen extends StatelessWidget {
  const CreateDealScreen({super.key, this.partner});
  final AllPartnerResults? partner;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    var cubit = context.read<CRMCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('create_deal'.tr()),
        centerTitle: false,
        titleTextStyle: getBoldStyle(
          fontSize: 20.sp,
          color: AppColors.black,
        ),
      ),
      body: BlocBuilder<CRMCubit, CRMState>(builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 10.0.sp, right: 10.0.sp),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  CustomCardClient(
                    partner: partner,
                  ),
                  SizedBox(height: 20.h),
                  CustomTextFieldWithTitle(
                    title: "expected_revenue".tr(),
                    controller: cubit.priceController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    hint: "expected_revenue".tr(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "expected_revenue".tr();
                      }
                      return null;
                    },
                  ),
                  // SizedBox(
                  //   height: 10.h,
                  // ),
                  CustomTextFieldWithTitle(
                    title: "chance".tr(),
                    controller: cubit.chanceController,
                    // maxLines: 5,
                    hint: "enter".tr(),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'chance'.tr();
                      }
                      return null;
                    },
                  ),
                  // SizedBox(
                  //   height: 10.h,
                  // ),
                  CustomTextFieldWithTitle(
                    title: "notes".tr(),
                    controller: cubit.descriptionController,
                    maxLines: 5,
                    hint: "enter".tr(),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'notes'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: getSize(context) / 20,
                        right: getSize(context) / 20),
                    child: CustomButton(
                      title: 'confirm'.tr(),
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          log('chance: ${cubit.chanceController.text}');
                          if (context.read<ClientsCubit>().currentLocation ==
                              null) {
                            context
                                .read<ClientsCubit>()
                                .checkAndRequestLocationPermission(context);
                          } else {
                            cubit.createLead(context,
                                partnerId: partner?.id.toString(),
                                lat: context
                                        .read<ClientsCubit>()
                                        .currentLocation
                                        ?.latitude ??
                                    0.0,
                                long: context
                                        .read<ClientsCubit>()
                                        .currentLocation
                                        ?.longitude ??
                                    0,
                                address: context.read<ClientsCubit>().address);
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
