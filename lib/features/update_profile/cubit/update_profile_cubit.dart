import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_sale/core/remote/service.dart';
import 'package:top_sale/features/home_screen/cubit/cubit.dart';
import 'package:top_sale/features/update_profile/cubit/update_profile_state.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/models/defaul_model.dart';
import '../../../core/preferences/preferences.dart';
import '../../../core/utils/dialogs.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit(this.api) : super(UpdateProfileInitial());
  ServiceApi api;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? profileImage;
  String selectedBase64String="";

  // Method to pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        selectedBase64String=await fileToBase64String(pickedFile.path);
        emit(UpdateProfileImagePicked()); // Emit state for image picked
      }
    } catch (e) {
      // Handle any errors
      emit(UpdateProfileError(error: "Failed to pick image"));
    }
  }
  //photo transfer
  Future<String> fileToBase64String(String filePath) async {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
  String base64String = base64Encode(bytes);
    return base64String;
  }
  //post user data
  DefaultModel? defaultModel;
  void UpdateProfileUser( BuildContext context) async {
    emit(UpdateProfileUserLoading());
    final result = await api.updateUserData(image: selectedBase64String.isNotEmpty?selectedBase64String:context.read<HomeCubit>().imageOfUser, name: nameController.text, mobile: phoneController.text, email: emailController.text);
    result.fold((l) {
      emit(UpdateProfileUserError());
    }, (r) {
      defaultModel = r;
      successGetBar("update_sucess".tr());
      emit(UpdateProfileUserLoaded());
      Navigator.popAndPushNamed(context, Routes.initialRoute);
    }
      //!}
    );}
  // post employee data
  void UpdateEmployeeProfile( BuildContext context) async {
    emit(UpdateProfileEmployeeLoading());
    final result = await api.updateEmployeeData(image:  selectedBase64String.isNotEmpty?selectedBase64String:context.read<HomeCubit>().imageOfUser, name: nameController.text, mobile: phoneController.text, email:  emailController.text);
    result.fold((l) {
      emit(UpdateProfileEmployeeError());
    }, (r) {
      defaultModel = r;
      successGetBar("update_sucess".tr());
      emit(UpdateProfileEmployeeLoaded());
      Navigator.popAndPushNamed(context, Routes.initialRoute);

    }
      //!}
    );}
  //check update profile for any one?
  void checkEmployeeOrUser( BuildContext context){
    Preferences.instance.getEmployeeId().then((value){
      debugPrint('${value.toString()}');
      if(value==null){
      //  getUserData();
        debugPrint("user");
        // name= getUserDataModel?.name.toString()??"";
        UpdateProfileUser(context);
      }
      else{
        debugPrint("employee");
        UpdateEmployeeProfile(context);
       // getEmployeeData();
        // name= getEmployeeDataModel?.name.toString()??"";
      }
      emit(CheckIfUserOrEmployee());

    });
    emit(CheckIfUserOrEmployee());
  }



}
