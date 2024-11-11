import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../login/widget/custom_button.dart';
import '../../login/widget/textfield_with_text.dart';
import '../cubit/create_receipt_coucher_cubit.dart';
import '../cubit/create_receipt_coucher_state.dart';

class CreateReceiptCoucherScreen extends StatefulWidget {
  CreateReceiptCoucherScreen({super.key, required this.partnerId});
  int partnerId;
  @override
  State<CreateReceiptCoucherScreen> createState() =>
      _CreateReceiptCoucherScreenState();
}

class _CreateReceiptCoucherScreenState
    extends State<CreateReceiptCoucherScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CreateReceiptCoucherCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding:
                EdgeInsets.only(left: 12.0.sp, right: 12.0.sp, top: 10.0.sp),
            child: BlocBuilder<CreateReceiptCoucherCubit,
                CreateReceiptCoucherState>(builder: (context, state) {
              return (cubit.getAllJournalsModel == null)
                  ? CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "date".tr(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0.sp,
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            setState(() {
                              cubit.selectedDate = pickedDate;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0.sp),
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0.sp, vertical: 12.0.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cubit.selectedDate == null
                                      ? 'chose_date'.tr()
                                      : "${cubit.selectedDate?.day}/${cubit.selectedDate?.month}/${cubit.selectedDate?.year}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const Icon(Icons.calendar_today,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
            }),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 12.0.sp, right: 12.0.sp, top: 10.0.sp),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'payment_method'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10.0.sp),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: cubit
                          .selectedPaymentMethod, // This will store the ID (not the name)
                      hint: Text(
                        'choose_payment_method'.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      isExpanded: true,
                      onChanged: (int? newValue) {
                        setState(() {
                          cubit.selectedPaymentMethod =
                              newValue; // Store the ID in cubit
                        });
                      },
                      items: cubit.getAllJournalsModel?.result
                              ?.map<DropdownMenuItem<int>>((resultItem) {
                            return DropdownMenuItem<int>(
                              value: resultItem.id,
                              child: Text(resultItem.displayName ??
                                  ''), // Display the name
                            );
                          }).toList() ??
                          [],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          CustomTextFieldWithTitle(
            controller: cubit.amountController,
            title: "Paid_in_full".tr(),
            hint: "enter_paid".tr(),
          ),
          CustomTextFieldWithTitle(
            controller: cubit.refController,
            title: "statement".tr(),
            maxLines: 5,
            hint: "statement".tr(),
          ),
          SizedBox(
            height: 20.h,
          ),
          CustomButton(
            title: "confirm".tr(),
            onTap: () {
              cubit.partnerPaymentMethod(context, partnerId: widget.partnerId);
            },
          )
        ]),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: false,
        title: Text(
          "create_receipt_coucher".tr(),
          style: TextStyle(
              fontFamily: AppStrings.fontFamily,
              color: AppColors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
