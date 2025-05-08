import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import 'widgets/bottom_sheet.dart';
import 'widgets/crm_container.dart';

class DealsDetails extends StatefulWidget {
  const DealsDetails({super.key, this.lead, });
final LeadModel? lead; 
  @override
  State<DealsDetails> createState() => _DealsDetailsState();
}

class _DealsDetailsState extends State<DealsDetails> {
      int status = 0;

  @override
  Widget build(BuildContext context) {
     

    var cubit = context.read<CRMCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('deal_details'.tr()),
        centerTitle: false,
        titleTextStyle: getBoldStyle(
          fontSize: 20.sp,
          color: AppColors.black,
        ),
      ),
     
      body: BlocBuilder<CRMCubit, CRMState>(
          builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0.sp, right: 10.0.sp),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                CustomCRMContainer(     
                  lead: widget.lead,                                      
                                            ),
                SizedBox(height: 20.h),
               status == 2 ? // completed
            
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 "visit_location".tr(),
                  style: getBoldStyle(
                    color: AppColors.secondry,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                            onTap: () {
                              context
                                  .read<ClientsCubit>()
                                  .openGoogleMapsRoute(
                                    context
                                            .read<ClientsCubit>()
                                            .currentLocation
                                            ?.latitude ??
                                        0.0,
                                    context
                                            .read<ClientsCubit>()
                                            .currentLocation
                                            ?.longitude ??
                                        0.0,
                                   0.0,
                                    0.0,
                                  );
                            },
                                                  child: Row(
                                                    children: [
                                                       Image.asset(
                                                         ImageAssets.addressIcon,
                                                         width: 25.w,
                                                       ),
                                                       10.w.horizontalSpace,
                                                      Expanded(
                                                        child: Text(
                                                            
                                                                "موقع الزيارة",
                                                            style: getBoldStyle(
                                                                color: AppColors
                                                                    .secondry,
                                                                fontSize: 14.sp),
                                                          ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                20.h.verticalSpace,
                                                  Text(
                  "notes".tr(),
                  style: getBoldStyle(
                    color: AppColors.secondry,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  " الملاحظاتهناا",
                  style: getRegularStyle(
                    color: AppColors.secondry,
                    fontSize: 16.sp,
                  ),
                ),
            
              ],
            )
                 : Padding(
                    padding: EdgeInsets.only(
                        left: getSize(context) / 20,
                        right: getSize(context) / 20),
                    child: CustomButton(
            
                      title: 
                    
                      status == 1 ?
                       'end_visit'.tr() : 'start_visit'.tr()
                      ,onTap: 
                      () {
                        if (status == 1) {
                          setState(() {
                            // status = 2;
                          });
                          showEndVisitSheet(
                           "1",
                            context,
                          );
                          // cubit.updateStatus(
                          //     status: 2,
                          //     id: cubit.dealId,
                          //     context: context);
                        } else {
                          setState(() {
                            status = 1;
                          });
                          // cubit.updateStatus(
                          //     status: 1,
                          //     id: cubit.dealId,
                          //     context: context);
                        }
                      
                        
                      },
                    ),
                  )
                       
              ],
            ),
          ),
        );
      }),
    );
  }
}

