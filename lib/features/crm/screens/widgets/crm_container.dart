
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/app_strings.dart';
import 'package:top_sale/core/utils/assets_manager.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/clients/cubit/clients_cubit.dart';


class CustomCRMContainer extends StatelessWidget {
  const CustomCRMContainer({
    super.key,
    this.isClickable = false,
  });
final bool isClickable;
  @override
  Widget build(BuildContext context) {
    return Padding(
                                    padding: EdgeInsets.all(8.0.sp),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isClickable) {
                                          Navigator.pushNamed(
                                              context, Routes.dealDetailsRoute);
                                        }
                                           
                                      },
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
                                                BorderRadius.circular(
                                                    10.sp),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // partner?.image.toString() != 'false'
        //     ? ClipRRect(
        //         borderRadius: BorderRadius.circular(100),
        //         child: CustomDecodedImage(
        //           base64String: partner?.image,
        //           // context: context,
        //           height: 70.h,
        //           width: 70.h,
        //         ),
        //       )
        //     :
             CircleAvatar(
                radius: 35.h,
                backgroundImage: AssetImage(ImageAssets.user),
              ),
        SizedBox(
          width: 10.w,
        ),
        Flexible(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      // partner?.name.toString() ??
                       'name',
                      style: TextStyle(
                          fontFamily: AppStrings.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: getSize(context) / 30),
                    ),
                    Text(
                      // partner?.phone.toString() == 'false'
                      //     ? '_'
                      //     : partner?.phone.toString() ??
                           '000000000',
                      style: TextStyle(
                          fontFamily: AppStrings.fontFamily,
                          fontSize: getSize(context) / 30),
                    ),
                   
                   
                  ],
                ),
              ),
              // if (partner?.phone.toString() != 'false')
                GestureDetector(
                  onTap: () {
                    // context
                    //     .read<ContactUsCubit>()
                    //     .launchURL('tel:${partner?.phone}');
                  },
                  child: Center(
                    child: Icon(
                      Icons.phone,
                      color: AppColors.orangeThirdPrimary,
                      size: 36,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Spacer(),
      ],
    ),
    10.h.verticalSpace,
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
                                                          
                                                              "موقع العميل",
                                                          style: getBoldStyle(
                                                              color: AppColors
                                                                  .secondry,
                                                              fontSize: 14.sp),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10.sp),
                                              Row(
                                                
                                                children: [
                                                Text(
                                                        "chance".tr() + ": ",
                                                    style: getBoldStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 14.sp),
                                                  ),
                                                Flexible(
                                                    child: Text(
                                                      " الفرصة",
                                                      style: getMediumStyle(
                                                         
                                                              
                                                          fontSize: 14.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                           ],
                                          )),
                                    ),
                                  );
  }
}
