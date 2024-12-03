import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/assets_manager.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/basket_screen/cubit/cubit.dart';
import 'package:top_sale/features/basket_screen/cubit/state.dart';
import 'package:top_sale/features/details_order/screens/widgets/rounded_button.dart';
import 'package:top_sale/features/direct_sell/cubit/direct_sell_cubit.dart';
import 'package:top_sale/features/login/widget/textfield_with_text.dart';

void showAttachmentBottomSheet(
  BuildContext context,
) {
  var cubit = context.read<BasketCubit>();
  var cubit2 = context.read<DirectSellCubit>();
  TextEditingController noteController = TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return BlocBuilder<BasketCubit, BasketState>(builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: getSize(context) / 20,
            right: getSize(context) / 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: getSize(context) / 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.showImageSourceDialog(context);
                        }, // Use the passed camera function
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: cubit.profileImage == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_upload_outlined,
                                          size: 40, color: AppColors.primary),
                                      SizedBox(height: 5.sp),
                                      const Text(
                                        '  ارفع الصورة أو الملف',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    // Display the image using Image.file
                                    File(cubit.profileImage!.path),
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.asset(
                                          ImageAssets.pdfImage,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            cubit.removeImage();
                          },
                          icon: CircleAvatar(
                              backgroundColor: AppColors.secondPrimary,
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 30,
                              )))
                    ],
                  ),
                ),
                CustomTextFieldWithTitle(
                  title: "الملاحظات",
                  controller: noteController,
                  maxLines: 5,
                  hint: "ادخل الملاحظات",
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: getSize(context) / 20,
                      right: getSize(context) / 20),
                  child: RoundedButton(
                    backgroundColor: AppColors.primaryColor,
                    text: 'confirm'.tr(),
                    onPressed: () {
                      cubit2.createPicking(
                        context: context,
                        image: cubit.selectedBase64String,
                        note: noteController.text,
                        imagePath: cubit.profileImage == null
                            ? ""
                            : cubit.profileImage!.path.split('/').last,
                        partnerId: cubit.partner?.id,
                        pickingId: cubit.selectedFromWareHouseId ?? -1,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      });
    },
  );
}
