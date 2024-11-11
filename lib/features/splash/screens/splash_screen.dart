// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:top_sale/core/preferences/preferences.dart';
import 'package:top_sale/features/Itinerary/cubit/cubit.dart';
import 'package:top_sale/features/clients/cubit/clients_cubit.dart';
import 'package:top_sale/features/login/cubit/cubit.dart';
import '../../../core/utils/assets_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../core/utils/get_size.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Timer _timer;

  _goNext() {
    _getStoreUser2();
    // _getStoreUser();
  }

  _startDelay() async {
    _timer = Timer(
      const Duration(seconds: 3, milliseconds: 500),
      () {
        _goNext();
      },
    );
  }

  Future<void> _getStoreUser2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onBoarding') == true) {
      if (await Preferences.instance.getDataBaseName() == null ||
          await Preferences.instance.getOdooUrl() == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.registerScreen,
          (route) => false,
        );
      } else {
        if (await Preferences.instance.getEmployeeId() == null &&
            await Preferences.instance.getUserName() == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginRoute,
            (route) => false,
          );
        } else {
          if (await Preferences.instance.getMasterUserName() == null ||
              await Preferences.instance.getMasterUserPass() == null) {
            if (await Preferences.instance.getUserName() == null ||
                await Preferences.instance.getUserPass() == null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (route) => false,
              );
            } else {
              String session = await context.read<LoginCubit>().setSessionId(
                  phoneOrMail: await Preferences.instance.getUserName() ?? '',
                  password: await Preferences.instance.getUserPass() ?? '',
                  baseUrl: await Preferences.instance.getOdooUrl() ?? '',
                  database: await Preferences.instance.getDataBaseName() ?? '');
              if (session != "error") {
                Navigator.pushReplacementNamed(context, Routes.mainRoute);
              } else {
                Navigator.pushReplacementNamed(context, Routes.loginRoute);
              }
            }
          } else {
            if (await Preferences.instance.getEmployeeId() != null) {
              String session = await context.read<LoginCubit>().setSessionId(
                  phoneOrMail:
                      await Preferences.instance.getMasterUserName() ?? '',
                  password:
                      await Preferences.instance.getMasterUserPass() ?? '',
                  baseUrl: await Preferences.instance.getOdooUrl() ?? '',
                  database: await Preferences.instance.getDataBaseName() ?? '');
              if (session != "error") {
                Navigator.pushReplacementNamed(context, Routes.mainRoute);
              } else {
                Navigator.pushReplacementNamed(context, Routes.loginRoute);
              }
            } else if (await Preferences.instance.getUserName() == null ||
                await Preferences.instance.getUserPass() == null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (route) => false,
              );
            } else {
              String session = await context.read<LoginCubit>().setSessionId(
                  phoneOrMail: await Preferences.instance.getUserName() ?? '',
                  password: await Preferences.instance.getUserPass() ?? '',
                  baseUrl: await Preferences.instance.getOdooUrl() ?? '',
                  database: await Preferences.instance.getDataBaseName() ?? '');
              if (session != "error") {
                Navigator.pushReplacementNamed(context, Routes.mainRoute);
              } else {
                Navigator.pushReplacementNamed(context, Routes.loginRoute);
              }
            }
          }
        }
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.onboardingPageScreenRoute,
        (route) => false,
      );
    }
  }

  Future<void> _getStoreUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onBoarding') == true) {
      if (await Preferences.instance.getDataBaseName() == null ||
          await Preferences.instance.getOdooUrl() == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.registerScreen,
          (route) => false,
        );
      } else {
        if (await Preferences.instance.getEmployeeId() == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginRoute,
            (route) => false,
          );
        } else {
          if (await Preferences.instance.getMasterUserName() == null ||
              await Preferences.instance.getMasterUserPass() == null) {
            if (await Preferences.instance.getUserName() == null ||
                await Preferences.instance.getUserPass() == null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (route) => false,
              );
            } else {
              String session = await context.read<LoginCubit>().setSessionId(
                  phoneOrMail: await Preferences.instance.getUserName() ?? '',
                  password: await Preferences.instance.getUserPass() ?? '',
                  baseUrl: await Preferences.instance.getOdooUrl() ?? '',
                  database: await Preferences.instance.getDataBaseName() ?? '');
              if (session != "error") {
                Navigator.pushReplacementNamed(context, Routes.mainRoute);
              } else {
                Navigator.pushReplacementNamed(context, Routes.loginRoute);
              }
            }
          } else {
            String session = await context.read<LoginCubit>().setSessionId(
                phoneOrMail:
                    await Preferences.instance.getMasterUserName() ?? '',
                password: await Preferences.instance.getMasterUserPass() ?? '',
                baseUrl: await Preferences.instance.getOdooUrl() ?? '',
                database: await Preferences.instance.getDataBaseName() ?? '');
            if (session != "error") {
              Navigator.pushReplacementNamed(context, Routes.mainRoute);
            } else {
              Navigator.pushReplacementNamed(context, Routes.loginRoute);
            }
          }
        }
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.onboardingPageScreenRoute,
        (route) => false,
      );
    }
  }

  // void navigateToHome() async {
  //   Future.delayed(
  //     const Duration(seconds: 3),
  //     () {
  //       String userName = '';
  //       String userPass = '';

  //       Preferences.instance.getIsFirstTime(key: 'onBoarding').then((value) {
  //         if (value != null && value == true) {
  //           Preferences.instance.getUserName().then((value) async {
  //             if (value != null) {
  //               userName = value;

  //               Preferences.instance.getUserPass().then((value) async {
  //                 if (value != null) {
  //                   userPass = value;
  //                   String session = await context
  //                       .read<LoginCubit>()
  //                       .setSessionId(
  //                           phoneOrMail: userName, password: userPass);
  //                   if (session != "error") {
  //                     Navigator.pushReplacementNamed(context, Routes.mainRoute);
  //                   } else {
  //                     Navigator.pushReplacementNamed(
  //                         context, Routes.loginRoute);
  //                   }
  //                 }
  //               }).catchError((error) {
  //                 debugPrint("ffffffffff" + error.toString());
  //               });
  //             } else {
  //               Navigator.pushReplacementNamed(context, Routes.loginRoute);
  //             }
  //           }).catchError((error) {
  //             debugPrint("ffffffffff" + error.toString());
  //           });

  //           print('not first time');
  //         } else {
  //           Navigator.pushReplacementNamed(context, Routes.onBoarding);
  //           print('first time');
  //         }
  //       }).catchError((error) {
  //         print(error.toString());
  //       });
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    context.read<ItineraryCubit>().getInitialTrackingState();
    context.read<ClientsCubit>().checkAndRequestLocationPermission(context);
    _startDelay();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Hero(
              tag: 'logo',
              child: SizedBox(
                child: Image.asset(
                  ImageAssets.logoImage,
                  height: getSize(context) / 1.2,
                  width: getSize(context) / 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomSheet: Container(
      //   color: AppColors.white,
      //   height: getSize(context) / 10,
      //   child: Image.asset(ImageAssets.topbusinessImage),
      // ),
    );
    //   },
    // );
  }
}
