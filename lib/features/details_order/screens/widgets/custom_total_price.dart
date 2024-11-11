import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_sale/core/utils/get_size.dart';

import '../../../../core/utils/app_fonts.dart';

class CustomTotalPrice extends StatelessWidget {
  CustomTotalPrice({
    super.key,
    required this.price,
    required this.currency,
  });
  String price;
  String currency;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        // height: getSize(context) / 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300.withOpacity(0.6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "total".tr(),
              style: getBoldStyle(),
            ),
            Text(
              "$price $currency",
              style: getBoldStyle(),
            ),
          ],
        ));
  }
}
