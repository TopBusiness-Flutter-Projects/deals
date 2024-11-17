import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/clients/cubit/clients_state.dart';
import 'package:top_sale/features/clients/screens/widgets/custom_card_client.dart';
import 'package:top_sale/features/home_screen/cubit/cubit.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/decode_image.dart';
import '../../details_order/screens/widgets/rounded_button.dart';
import '../../login/widget/textfield_with_text.dart';
import '../cubit/clients_cubit.dart';

// ignore: must_be_immutable
class ClientScreen extends StatefulWidget {
  ClientScreen({required this.clientsRouteEnum, super.key});
  ClientsRouteEnum clientsRouteEnum;

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    if (context.read<ClientsCubit>().allPartnersModel == null) {
      context.read<ClientsCubit>().getAllPartnersForReport();
    }
    super.initState();
  }

  //
  late final ScrollController scrollController = ScrollController();

  _scrollListener() {
    if (scrollController.position.maxScrollExtent == scrollController.offset) {
      print('dddddddddbottom');
      if (context.read<ClientsCubit>().allPartnersModel!.next != null) {
        context.read<ClientsCubit>().getAllPartnersForReport(
            isGetMore: true,
            page: context.read<ClientsCubit>().allPartnersModel?.next ?? 1);
        debugPrint('new posts');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ClientsCubit>();
    return BlocBuilder<ClientsCubit, ClientsState>(
      builder: (context, state) {
        return Scaffold(
            backgroundColor: AppColors.white,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (cubit.currentLocation != null) {
                        _showBottomSheet(context, cubit);
                      } else {
                        cubit.checkAndRequestLocationPermission(context);
                      }
                    },
                    child: Container(
                      height: 30.sp,
                      width: 30.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadiusDirectional.circular(90),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 20.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              backgroundColor: AppColors.white,
              centerTitle: false,
              //leadingWidth: 20,
              title: Text(
                'clients'.tr(),
                style: TextStyle(
                  fontFamily: AppStrings.fontFamily,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  CustomTextField(
                    controller: cubit.searchController,
                    onChanged: cubit.onChangeSearch,
                    labelText: "search_client".tr(),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 35,
                      color: AppColors.gray2,
                    ),
                  ),
                  Flexible(
                    child: (state is LoadingGetPartnersState)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : (cubit.allPartnersModel == null ||
                                cubit.allPartnersModel?.result == [])
                            ? Center(
                                child: Text('no_data'.tr()),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await cubit.getAllPartnersForReport();
                                },
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      cubit.allPartnersModel!.result!.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    //! we will padd partner data
                                    //! cubit.allPartnersModel!.result![index]
                                    return GestureDetector(
                                        onTap: () {
                                          if (widget.clientsRouteEnum ==
                                              ClientsRouteEnum.cart) {
                                            Navigator.pushNamed(context,
                                                Routes.basketScreenRoute,
                                                arguments: cubit
                                                    .allPartnersModel!
                                                    .result![index]);
                                          }
                                          if (widget.clientsRouteEnum ==
                                              ClientsRouteEnum.receiptVoucher) {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.createReceiptVoucherRoute,
                                              arguments: cubit.allPartnersModel!
                                                  .result![index].id,
                                            );
                                          }
                                          if (widget.clientsRouteEnum ==
                                              ClientsRouteEnum.details) {
                                            context
                                                .read<ClientsCubit>()
                                                .getPartenerDetails(
                                                    id: cubit
                                                            .allPartnersModel!
                                                            .result![index]
                                                            .id ??
                                                        1);
                                            Navigator.pushNamed(
                                              context,
                                              Routes.profileClientRoute,
                                            );
                                          }
                                        },
                                        child: CustomCardClient(
                                          partner: cubit
                                              .allPartnersModel!.result![index],
                                        ));
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  void _showBottomSheet(BuildContext context, ClientsCubit cubit) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<ClientsCubit, ClientsState>(
          builder: (context, state) {
            return Padding(
              // Adjust bottom padding to avoid keyboard overlap
              padding: EdgeInsets.only(
                left: getSize(context) / 20,
                right: getSize(context) / 20,
                top: getSize(context) / 20,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    getSize(context) / 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: cubit.formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: cubit.profileImage == null
                              ? Image.asset(
                                  ImageAssets.user,
                                  height: 100.sp,
                                  width: 100.sp,
                                )
                              : Image.file(
                                  (File(cubit.profileImage!.path)),
                                  fit: BoxFit.cover,
                                  height: 100.h,
                                  width: 100.h,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              cubit.showImageSourceDialog(context);
                              // cubit.pickImage(ImageSource.gallery);
                            },
                            child: const Icon(
                              Icons.camera_alt,
                            ),
                          ),
                        )
                      ],
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('Company'.tr()),
                            leading: Radio<String>(
                              value: 'Company',
                              groupValue: cubit.selectedClientType,
                              onChanged: (value) {
                                setState(() {
                                  cubit.changeClientType(value);
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text('Indivalal'.tr()),
                            leading: Radio<String>(
                              value: 'Indivalal',
                              groupValue: cubit.selectedClientType,
                              onChanged: (value) {
                                setState(() {
                                  cubit.changeClientType(value);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    CustomTextFieldWithTitle(
                      title: "name".tr(),
                      controller: cubit.clientNameController,
                      hint: "enter_name".tr(),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "enter_name".tr();
                        } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                          // Adjust the regex as needed for language-specific characters
                          return "ادخل اسم حقيقي";
                        }
                        return null;
                      },
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    CustomTextFieldWithTitle(
                      title: "phone".tr(),
                      controller: cubit.phoneController,
                      hint: "enter_phone".tr(),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "enter_phone".tr();
                        } else if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                          // Adjust the regex as needed for the desired phone format
                          return "من فضلك ادخل رقم صالح";
                        }
                        return null;
                      },
                    ),
                    // SizedBox(
                    //   height: getSize(context) / 30,
                    // ),
                    CustomTextFieldWithTitle(
                      title: "email".tr(),
                      isRequired: false,
                      controller: cubit.emailController,
                      hint: "enter_email".tr(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                          // return "Please enter your email.";
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          // Adjust the regex as needed for stricter validation
                          return "من فضلك ادخل بريد صالح";
                        }
                        return null;
                      },
                    ),
                    // SizedBox(
                    //   height: getSize(context) / 30,
                    // ),
                    
                    CustomTextFieldWithTitle(
                      title: "address".tr(),
                      controller: cubit.addressController,
                      isRequired: false,
                      hint: "enter_address".tr(),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    cubit.selectedClientType == 'Company'
                        ? CustomTextFieldWithTitle(
                            title: "الرقم الضريبي".tr(),
                            controller: cubit.vatController,
                            hint: "الرقم الضريبي".tr(),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "ادخل الرقم الضريبي";
                              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                                // Adjust this regex to enforce length or other specific rules if needed
                                return "ادخل رقم صالح";
                              }
                              return null;
                            },
                          )
                        : const SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(
                          left: getSize(context) / 20,
                          right: getSize(context) / 20),
                      child: RoundedButton(
                        backgroundColor: AppColors.primaryColor,
                        text: 'confirm'.tr(),
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            print("Validated");
                            cubit.createClient(context);
                          } else {
                            // Handle validation failure
                            print("Validation failed");
                          }
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
