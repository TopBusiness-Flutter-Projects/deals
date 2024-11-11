// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/api/end_points.dart';
import 'package:top_sale/core/models/check_employee_model.dart';
import 'package:top_sale/core/models/login_model.dart';
import 'package:top_sale/core/preferences/preferences.dart';
import 'package:top_sale/core/remote/service.dart';
import 'package:top_sale/core/utils/app_strings.dart';
import 'package:top_sale/core/utils/appwidget.dart';
import 'package:top_sale/core/utils/dialogs.dart';

import 'state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.api) : super(LoginStateInitial());
  ServiceApi api;
  TextEditingController companynameController = TextEditingController();
  TextEditingController odooLinkController = TextEditingController();
  TextEditingController dbNumberController = TextEditingController();
  TextEditingController adminNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();
//! case user
  TextEditingController usernameController = TextEditingController();
  //! case emplyee
  TextEditingController emplyeeNumberController = TextEditingController();

  bool isEmplyee = false;
  onchangeEmplyeeStatus(bool status) {
    isEmplyee = status;
    emplyeeNumberController.clear();
    usernameController.clear();

    emit(ChnageStatusOfEmplyeeAndUser());
  }

  AuthModel? authModel;
  login(BuildContext context,
      {required String phoneOrMail,
      required String password,
      required String baseUrl,
      required String database,
      required bool isEmployeeType,
      required bool isVisitor}) async {
    emit(LoadingLoginState());
    AppWidget.createProgressDialog(context, 'انتظر');
    final response = isVisitor
        ? await api.login(
            phoneOrMail: AppStrings.demoUserName,
            password: AppStrings.demoUserpassword,
            baseUrl: AppStrings.demoBaseUrl,
            database: AppStrings.demoDB)
        : await api.login(
            phoneOrMail: phoneOrMail,
            password: password,
            baseUrl: baseUrl,
            database: database);
    response.fold((l) {
      Navigator.pop(context);
      errorGetBar(l.message ?? '');
      emit(FailureLoginState());
    }, (r) async {
      if (r.result != null) {
        authModel = r;
        print("rrrrrrrrrrrrrrrrrr");

        String sessionId = isVisitor
            ? await api.getSessionId(
                phone: AppStrings.demoUserName,
                password: AppStrings.demoUserpassword,
                baseUrl: AppStrings.demoBaseUrl,
                database: AppStrings.demoDB)
            : await api.getSessionId(
                phone: phoneOrMail,
                password: password,
                baseUrl: baseUrl,
                database: database);

        emit(SuccessLoginState());
        await Preferences.instance.setSessionId(sessionId);
        if (!isVisitor) {
          if (isEmployeeType) {
            await Preferences.instance.setMasterUserName(phoneOrMail);
            await Preferences.instance.setMasterUserPass(password);
          } else {
            await Preferences.instance.setUserName(phoneOrMail);
            await Preferences.instance.setUserPass(password);
          }

          await Preferences.instance.setOdooUrl(baseUrl);
          await Preferences.instance.setDataBaseName(database);
        }
        Navigator.pop(context);
        Preferences.instance.setUserId(r.result!.userContext!.uid.toString());
        Preferences.instance.setUserModel(r);
        print("wwwwwwwwwwwwww ${r.result!.propertyWarehouseId}");

        if (isEmployeeType) {
          //  isEmplyee = true;
          Navigator.pushNamed(context, Routes.loginRoute);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.mainRoute, (route) => false);
        }
      } else {
        errorGetBar("حدث خطأ ما");
        Navigator.pop(context);
      }
    });
  }

  CheckEmployeeModel? employeeModel;
  checkEmployee(
    BuildContext context, {
    required String employeeId,
    required String password,
  }) async {
    if (await Preferences.instance.getMasterUserName() == null ||
        await Preferences.instance.getOdooUrl() == null) {
      errorGetBar("من فضلك أدخل معلومات الشركة أولا");
    } else {
      emit(LoadingCheckEmployeeState());
      AppWidget.createProgressDialog(context, 'انتظر');
      final response = await api.checkEmployee(
        employeeId: employeeId,
        password: password,
      );
      response.fold((l) {
        Navigator.pop(context);
        errorGetBar("حدث خطأ ما");
        emit(FailureCheckEmployeeState());
      }, (r) async {
        Navigator.pop(context);
        emit(SuccessCheckEmployeeState());
        if (r.result != null) {
          if (r.result!.isNotEmpty) {
            await Preferences.instance
                .setEmployeeId(r.result!.first.id.toString());
            print(
                "ffffffffffffff ${r.result!.first.messagePartnerIds!.first.id.toString()}");
            if (r.result!.first.messagePartnerIds!.isNotEmpty) {
              await Preferences.instance.setEmployeePartnerId(
                  r.result!.first.messagePartnerIds!.first.id.toString());
            }
            successGetBar("تم بنجاح");
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.mainRoute, (route) => false);
          } else {
            errorGetBar("حدث خطأ ما");
          }
          //  employeeModel = r;
        } else {
          errorGetBar("حدث خطأ ما");
        }
      });
    }
  }

  Future<String> setSessionId({
    required String phoneOrMail,
    required String password,
    required String baseUrl,
    required String database,
  }) async {
    String mySessionId = await api.getSessionId(
        phone: phoneOrMail,
        password: password,
        baseUrl: baseUrl,
        database: database);

    return mySessionId;
  }
}
//https://novapolaris-top-staging-15626573.dev.odoo.com
//novapolaris-top-staging-15626573
// master@gmail.com
// master