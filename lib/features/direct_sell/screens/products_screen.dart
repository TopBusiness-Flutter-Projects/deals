import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/get_size.dart';
import 'package:top_sale/features/direct_sell/cubit/direct_sell_state.dart';
import 'package:top_sale/features/direct_sell/screens/widgets/custom_product_section.dart';
import 'package:top_sale/features/direct_sell/screens/widgets/scanner.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/models/all_products_model.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/assets_manager.dart';
import '../../clients/cubit/clients_cubit.dart';
import '../cubit/direct_sell_cubit.dart';
import 'widgets/custom_product_widget.dart';
class ProductsScreen extends StatefulWidget {
  const ProductsScreen(
      {super.key, required this.categoryName, required this.catId});
  final String categoryName;
  final String catId;
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}
class _ProductsScreenState extends State<ProductsScreen> {
  late final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    //! listen pangination
    scrollController.addListener(_scrollListener);
    ///!
    context.read<DirectSellCubit>().currentIndex = -1;
    // TODO: implement initState
    if (widget.catId != '-1') {
      context
          .read<DirectSellCubit>()
          .getAllProductsByCatogrey(id: int.parse(widget.catId));
    } else {
      context.read<DirectSellCubit>().getAllProducts();
      context.read<DirectSellCubit>().currentIndex == -1;
    }
  }

  _scrollListener() {
    if (scrollController.position.maxScrollExtent == scrollController.offset) {
      //! pagination
      if (context.read<DirectSellCubit>().allProductsModel.result!.page !=
          null) {
        context.read<DirectSellCubit>().getAllProducts(
            isGetMore: true,
            pageId:
                context.read<DirectSellCubit>().allProductsModel.result!.page +
                        1 ??
                    1);
        debugPrint('new posts');
      }
    } else {
      print('dddddddddtop');
    }
  }
  @override
  Widget build(BuildContext context) {
    // String testImage =
    //     'https://img.freepik.com/free-photo/organic-cosmetic-product-with-dreamy-aesthetic-fresh-background_23-2151382816.jpg';
    return BlocBuilder<DirectSellCubit, DirectSellState>(
        builder: (context, state) {
      var cubit = context.read<DirectSellCubit>();
      return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.white,
            centerTitle: false,
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.clientsRoute,
                      arguments: ClientsRouteEnum.cart);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(
                    'assets/images/basket1.png',
                    width: getSize(context) / 15,
                    color: cubit.currentIndex == 1
                        ? AppColors.orange
                        : Colors.black,
                  ),
                ),
              ),
            ],
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_outlined,
                size: 25.w,
              ),
            ),
            // //leadingWidth: 20,
            title: Text(
              widget.categoryName,
              style: getBoldStyle(
                fontSize: 20.sp,
              ),
            ),
          ),
          backgroundColor: AppColors.white,
          body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Column(children: [
                const CustomSearchWidget(),
                cubit.searchController.text.isNotEmpty
                    ? Expanded(
                        child: ListView(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomProductSection(
                                isSearch: true,
                                result: cubit.searchedProductsModel?.result
                                        ?.products ??
                                    []),
                          ),
                        ]),
                      )
                    : Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15.h,
                            ),
                            if (widget.categoryName == "products".tr())
                              cubit
                                            .catogriesModel == null ?
                                            
                                            SizedBox(height: 2,)
                                            :
                              SizedBox(
                                height: 50.h,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cubit.changeIndex(-1, 0);
                                      },
                                      child: CustomCategoryText(
                                          text: "all".tr(),
                                          isSelected: cubit.currentIndex == -1),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Flexible(
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: cubit
                                            .catogriesModel!.result!.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(
                                          width: 10.w,
                                        ),
                                        itemBuilder: (context, index) =>
                                            GestureDetector(
                                          onTap: () {
                                            cubit.changeIndex(
                                                index,
                                                cubit.catogriesModel
                                                    ?.result?[index].id);
                                          },
                                          child: CustomCategoryText(
                                              text: cubit.catogriesModel
                                                      ?.result?[index].name ??
                                                  "",
                                              isSelected:
                                                  cubit.currentIndex == index),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (cubit.allProductsModel.result == [] ||
                                cubit.allProductsModel == AllProductsModel())
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageAssets.nodata,
                                      width: getSize(context) / 8,
                                    ),
                                    Text("no_data".tr()),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              )
                            else
                              state is LoadingProduct
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Expanded(
                                      child: SingleChildScrollView(
                                        controller: scrollController,
                                        child: cubit.allProductsModel.result ==
                                                null
                                            ? Container()
                                            : StaggeredGrid.count(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 10.h,
                                                crossAxisSpacing: 10.w,
                                                children: List.generate(
                                                  cubit.allProductsModel.result!
                                                      .products!.length,
                                                  (index) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: CustomProductWidget(
                                                        product: cubit
                                                            .allProductsModel
                                                            .result!
                                                            .products![index]),
                                                  ),
                                                )),
                                      ),
                                    )
                          ],
                        ),
                      )
              ])));
    });
  }
}

class CustomCategoryText extends StatelessWidget {
  const CustomCategoryText(
      {super.key, required this.text, required this.isSelected});
  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: getMediumStyle(
              fontSize: 18.sp,
              color: isSelected ? AppColors.red : AppColors.primaryText),
        ),
        // IntrinsicHeight(
        //   child: Container(
        //     height: 4.h,
        //     //  width: double.maxFinite,
        //     decoration: BoxDecoration(
        //       color: AppColors.red,
        //       borderRadius: BorderRadius.circular(15.sp),
        //     ),
        //   ),
        // )
      ],
    );
  }
}
