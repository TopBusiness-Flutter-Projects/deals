import 'package:flutter/material.dart';
import 'package:top_sale/core/utils/circle_progress.dart';

import '../utils/app_colors.dart';

class ShowLoadingIndicator extends StatelessWidget {
  const ShowLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height/2-50),
        Center(
          child: CustomLoadingIndicator(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
