import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/custom_button.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/crm/cubit/crm_cubit.dart';
import 'package:top_sale/features/crm/cubit/crm_state.dart';
import 'package:top_sale/features/details_order/screens/widgets/rounded_button.dart';
import 'package:top_sale/features/login/widget/textfield_with_text.dart';

void showEndVisitSheet(
  String visitId,
  BuildContext context,
) {
  var cubit = context.read<CRMCubit>();
  var _formKey = GlobalKey<FormState>();
 

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {

      return BlocBuilder<CRMCubit, CRMState>(
          builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: getSize(context) / 20,
            right: getSize(context) / 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: getSize(context) / 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(

                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                CustomTextFieldWithTitle(
                    title: "notes".tr(),
                    controller: cubit.noteController,
                    maxLines: 5,
                    hint:  "enter_notes".tr(),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "enter_notes".tr();
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
                          // cubit.endVisit(
                          //   visitId: visitId,
                          //   note: cubit.noteController.text,
                          //   context: context,
                          // );
                        }
                        // cubit.createQuotation(
                        //     warehouseId: '1',
                        //     note: noteController.text,
                        //     context: context,
                        //     partnerId: partnerId);
                        
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
