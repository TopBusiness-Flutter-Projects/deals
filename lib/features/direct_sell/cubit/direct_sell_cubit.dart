import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_sale/config/routes/app_routes.dart';
import 'package:top_sale/core/models/get_orders_model.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/app_fonts.dart';
import 'package:top_sale/core/utils/appwidget.dart';
import 'package:top_sale/core/utils/dialogs.dart';
import 'package:top_sale/features/clients/cubit/clients_cubit.dart';
import '../../../core/models/all_products_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/create_order_model.dart';
import '../../../core/remote/service.dart';
import '../../details_order/screens/widgets/custom_order_details_item.dart';
import 'direct_sell_state.dart';

class DirectSellCubit extends Cubit<DirectSellState> {
  DirectSellCubit(this.api) : super(DirectSellInitial());
  ServiceApi api;
  List<CategoryModelData>? result;

  int currentIndex = -1;
  changeIndex(int index, int? id) {
    currentIndex = index;
    emit(ChangeIndexState());
    print("sucess change");
    if (currentIndex == -1) {
      getAllProducts();
    } else {
      print("catogrey id" + '$id');
      getAllProductsByCatogrey(id: id);
    }

    allProductsModel.result?.products = [];
    print("sucess change 2");
  }

  String selectedProducsStockType = "stock";
  changeProductsStockType(String value) {
    selectedProducsStockType = value;
    emit(UpdateProductsStockState());
  }

  CategoriesModel? catogriesModel;
  Future<void> getCategries() async {
    emit(LoadingCatogries());
    final response = await api.getAllCategories();
    //
    response.fold((l) {
      emit(ErrorCatogriesextends());
    }, (right) async {
      print("sucess cubit");
      catogriesModel = right;
      print("loaded");
      emit(LoadedCatogries(catogriesModel: catogriesModel));
    });
  }

  AllProductsModel allProductsModel = AllProductsModel();
  AllProductsModel homeProductsModel = AllProductsModel();
  Future<void> getAllProducts(
      {bool isHome = false, bool isGetMore = false, int pageId = 1}) async {
    isGetMore ? emit(Loading2Product()) : emit(LoadingProduct());
    final response =
        await api.getAllProducts(pageId, selectedProducsStockType == "stock");

    response.fold((l) {
      emit(ErrorProduct());
    }, (right) async {
      print("sucess cubit");
      if (isHome) {
        homeProductsModel = right;
        updateUserOrderedQuantities(homeProductsModel);
      } else {
        if (isGetMore) {
          allProductsModel = AllProductsModel(
            result: ProductsResult(
              products: [
                ...allProductsModel.result!.products!,
                ...right.result!.products!
              ],
            ),
          );

          updateUserOrderedQuantities(allProductsModel);
        } else {
          allProductsModel = right;
        }
        updateUserOrderedQuantities(allProductsModel);
      }
      print("loaded");
      emit(LoadedProduct(allProductmodel: allProductsModel));
    });
  }

  List<ProductModelData> basket = [];

  double totalBasket() {
    double total = 0.0;
    for (int i = 0; i < basket.length; i++) {
      total += (basket[i].userOrderedQuantity * (basket[i].listPrice ?? 1));
    }
    return total;
  }

  void addAndRemoveToBasket({
    required bool isAdd,
    required ProductModelData product,
  }) {
    emit(LoadingTheQuantityCount());
    print('Current userOrderedQuantity: ${product.userOrderedQuantity}');

    if (isAdd) {
      // **Add Product to Basket**
      bool existsInBasket = basket.any((item) => item.id == product.id);

      if (!existsInBasket) {
        // if (product.userOrderedQuantity < product.stockQuantity) {
        product.userOrderedQuantity++;
        basket.add(product);
        emit(IncreaseTheQuantityCount());
        print(
            'Product added to basket: ${product.id}, Quantity: ${product.userOrderedQuantity}');
        // } else {
        //   print(
        //       'Cannot add more. Stock limit reached for product: ${product.id}');
        // }
      } else {
        final existingProduct =
            basket.firstWhere((item) => item.id == product.id);

        // if (existingProduct.userOrderedQuantity <
        //     existingProduct.stockQuantity) {
        existingProduct.userOrderedQuantity++;
        emit(IncreaseTheQuantityCount());
        debugPrint(
            'Updated quantity for product ${existingProduct.id}: ${existingProduct.userOrderedQuantity}');
        // } else {
        //   print(
        //       'Cannot add more. Stock limit reached for product: ${existingProduct.id}');
        // }
      }
    } else {
      // **Remove Product from Basket**
      print(
          "Removing product. Current userOrderedQuantity: ${product.userOrderedQuantity}");
      if (product.userOrderedQuantity > 0) {
        product.userOrderedQuantity--;
        emit(DecreaseTheQuantityCount());
        print(
            'Product quantity decreased: ${product.id}, New Quantity: ${product.userOrderedQuantity}');

        if (product.userOrderedQuantity == 0) {
          basket.removeWhere((item) => item.id == product.id);
          debugPrint('Product removed from basket: ${product.id}');
        }
      } else {
        print(
            'Cannot remove. Product quantity is already zero for product: ${product.id}');
      }
    }

    // **Update Quantities Across All Relevant Models**
    updateUserOrderedQuantities(homeProductsModel);
    updateUserOrderedQuantities(allProductsModel);

    updateUserOrderedQuantities(searchedProductsModel);

    emit(OnChangeCountOfProducts());
    totalBasket();
  }

  // addAndRemoveToBasket(
  //     {required bool isAdd, required ProductModelData product}) {
  //   emit(LoadingTheQuantityCount());
  //   if (isAdd) {
  //     bool existsInBasket = basket.any((item) => item.id == product.id);
  //     if (!existsInBasket) {
  //       if (product.userOrderedQuantity < product.stockQuantity) {
  //         product.userOrderedQuantity++;
  //         basket.add(product);
  //       }

  //       emit(IncreaseTheQuantityCount());
  //     } else {
  //       final existingProduct =
  //           basket.firstWhere((item) => item.id == product.id);
  //       if (product.userOrderedQuantity < product.stockQuantity) {
  //         existingProduct.userOrderedQuantity++;
  //       }
  //       emit(IncreaseTheQuantityCount());
  //       debugPrint('::::||:::: ${existingProduct.userOrderedQuantity}');
  //     }
  //   } else {
  //     if (product.userOrderedQuantity == 0) {
  //       basket.removeWhere((item) => item.id == product.id);
  //       emit(DecreaseTheQuantityCount());
  //     } else {
  //       product.userOrderedQuantity--;
  //       emit(DecreaseTheQuantityCount());
  //     }
  //   }
  //   emit(OnChangeCountOfProducts());
  //   // updateUserOrderedQuantities(allProductsModel);
  //   // updateUserOrderedQuantities(homeProductsModel);
  //   totalBasket();
  // }
  // addAndRemoveToBasket(
  //     {required bool isAdd, required ProductModelData product}) {
  //   emit(LoadingTheQuantityCount());
  //   print(product.userOrderedQuantity);
  //   if (isAdd) {
  //     bool existsInBasket = basket.any((item) => item.id == product.id);
  //     if (!existsInBasket) {
  //       if (product.userOrderedQuantity < product.stockQuantity) {
  //         product.userOrderedQuantity++;
  //         basket.add(product);
  //         emit(IncreaseTheQuantityCount());
  //       }
  //     } else {
  //       final existingProduct =
  //           basket.firstWhere((item) => item.id == product.id);
  //       if (existingProduct.userOrderedQuantity <
  //           existingProduct.stockQuantity) {
  //         existingProduct.userOrderedQuantity++;
  //         emit(IncreaseTheQuantityCount());
  //         debugPrint('::::||:::: ${existingProduct.userOrderedQuantity}');
  //       }
  //     }
  //   } else {
  //     if (product.userOrderedQuantity > 0) {
  //       product.userOrderedQuantity--;
  //       emit(DecreaseTheQuantityCount());
  //       if (product.userOrderedQuantity == 0) {
  //         basket.removeWhere((item) => item.id == product.id);
  //         debugPrint('Product removed from basket: ${product.id}');
  //       }
  //     }
  //   }
  //   updateUserOrderedQuantities(homeProductsModel);
  //   updateUserOrderedQuantities(allProductsModel);
  //   // if (searchedProductsModel != null) {
  //   //   updateUserOrderedQuantities(searchedProductsModel!);
  //   // }

  //   emit(OnChangeCountOfProducts());
  //   // updateUserOrderedQuantities(allProductsModel);
  //   // updateUserOrderedQuantities(homeProductsModel);
  //   totalBasket();
  // }

  Future<void> getAllProductsByCatogrey({required int? id}) async {
    print("sucess change 3");
    emit(LoadingProductByCatogrey());
    final response = await api.getAllProductsByCategory(
        1, selectedProducsStockType == "stock",
        categoryId: id!);
    //
    response.fold((l) {
      emit(ErrorProductByCatogrey());
    }, (right) async {
      allProductsModel = right;
      // for (var element in allProductsModel.result!) {}
      updateUserOrderedQuantities(allProductsModel);
      updateUserOrderedQuantities(homeProductsModel);
      // updateUserOrderedQuantities(s);
      // updateUserOrderedQuantities(searchedProductsModel);
      emit(LoadedProductByCatogrey(allProductmodel: allProductsModel));
    });
  }

  //! Method to update userOrderedQuantity based on items in the basket
  void updateUserOrderedQuantities(AllProductsModel allProductsModes) {
    for (var basketItem in basket) {
      for (ProductModelData product
          in allProductsModes.result!.products ?? []) {
        if (product.id == basketItem.id) {
          product.userOrderedQuantity =
              basketItem.userOrderedQuantity; //! Update quantity
        }
      }

      // emit(OnChangeCountOfProducts());
    }
  }

  File? profileImage;
  String selectedBase64String = "";
  removeImage() {
    profileImage = null;
    emit(FileRemovedSuccessfully());
  }

  void showImageSourceDialog(
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'select_image'.tr(),
            style: getMediumStyle(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                pickFile(context, true);
              },
              child: Text(
                'gallery'.tr(),
                style:
                    getRegularStyle(fontSize: 12.sp, color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                pickImage(context, false);
                // var status = await Permission.camera.status;
                // if (status.isDenied ||
                //     status.isRestricted ||
                //     status.isPermanentlyDenied) {
                //   if (await Permission.camera.request().isGranted) {
                //     pickImage(context, false);
                //   } else {
                //     errorGetBar(
                //         'يرجى السماح بإذن الكاميرا لاستخدام هذه الميزة');
                //   }

                //   await Permission.camera.request();
                // } else {
                //   pickImage(context, false);
                // }
              },
              child: Text(
                "camera".tr(),
                style:
                    getRegularStyle(fontSize: 12.sp, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future pickImage(BuildContext context, bool isGallery) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      selectedBase64String = await fileToBase64String(pickedFile.path);
      emit(UpdateProfileImagePicked()); // Emit state for image picked
      Navigator.pop(context);
    } else {
      emit(UpdateProfileError());
    }
  }

  Future pickFile(BuildContext context, bool isGallery) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      selectedBase64String = await fileToBase64String(pickedFile.path);
      emit(UpdateProfileImagePicked()); // Emit state for image picked
      Navigator.pop(context);
    } else {
      emit(UpdateProfileError());
    }
  }

  //photo transfer
  Future<String> fileToBase64String(String filePath) async {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
    String base64String = base64Encode(bytes);
    return base64String;
  }

  CreateOrderModel? createOrderModel;
  createQuotation(
      {required int partnerId,
      required BuildContext context,
      required String warehouseId,
      String? note}) async {
    AppWidget.createProgressDialog(context, "جاري التحميل ..");
    emit(LoadingCreateQuotation());
    final result = await api.createQuotation(
        note: note,
        image: selectedBase64String,
        imagePath:
            profileImage == null ? "" : profileImage!.path.split('/').last,
        partnerId: partnerId,
        products: basket,
        warehouseId: warehouseId,
        lat: context.read<ClientsCubit>().currentLocation?.latitude ?? 0.0,
        long: context.read<ClientsCubit>().currentLocation?.longitude ?? 0.0,
        address: context.read<ClientsCubit>().address);

    result.fold((l) {
      Navigator.pop(context);
      emit(ErrorCreateQuotation());
    }, (r) {
      if (r.result?.message == null) {
        errorGetBar('عدم كفاية المخزون لمنتج واحد أو أكثر');
      } else {
        createOrderModel = r;
        successGetBar('Success Create Quotation');
        debugPrint("Success Create Quotation");
        profileImage = null;
        selectedBase64String = '';

        getOrderFromId(context, createOrderModel!.result!.orderId!);

        basket = [];
        // **Update Quantities Across All Relevant Models**
        updateUserOrderedQuantities(homeProductsModel);
        updateUserOrderedQuantities(allProductsModel);

        updateUserOrderedQuantities(searchedProductsModel);
        emit(LoadedCreateQuotation());
      }
    });
  }

  GetOrdersModel getOrdersModel = GetOrdersModel();
  Future<void> getOrderFromId(BuildContext context, int orderId) async {
    emit(OrdersLoadingState());

    final result = await api.getOrderFromId(orderId);
    result.fold(
      (failure) {
        Navigator.pop(context);
        emit(OrdersErrorState());
      },
      (r) async {
        getOrdersModel = r;
        if (r.result != null) {
          if (r.result!.isNotEmpty) {
            Navigator.pop(context);

            Navigator.pushNamed(
              context,
              Routes.detailsOrderShowPrice,
              arguments: {
                'orderModel': r.result!.first,
                'isClientOrder': false, // or false based on your logic
              },
            );
          }
        }

        emit(OrdersLoadedState());
      },
    );
  }

  clearSearchText() {
    searchController.clear();
    emit(ClearSearchText());
  }

  TextEditingController searchController = TextEditingController();
  AllProductsModel searchedProductsModel = AllProductsModel();

  // Search products by name
  searchProducts(
      {int pageId = 1, bool isGetMore = false, bool isBarcode = false}) async {
    final response =
        await api.searchProducts(pageId, searchController.text, isBarcode);
    response.fold((l) => emit(ErrorProduct()), (r) {
      searchedProductsModel = r;
      // final updatedResults = _updateUserOrderedQuantity(r.result!);
      updateUserOrderedQuantities(searchedProductsModel);
      // searchedproductsModel = AllProductsModel(
      //   count: r.count,
      //   next: r.next,
      //   prev: r.prev,
      //   result: updatedResults,
      // );

      emit(LoadedProduct(allProductmodel: allProductsModel));
    });
  }

  TextEditingController newPriceController = TextEditingController();

  onChnagePriceOfUnit(ProductModelData item, BuildContext context) {
    item.listPrice = double.parse(newPriceController.text.toString());
    Navigator.pop(context);
    newPriceController.clear();
    emit(OnChangeUnitPriceOfItem());
  }

  TextEditingController newQtyController = TextEditingController();

  onChnageProductQuantity(ProductModelData item, BuildContext context) {
    item.userOrderedQuantity = int.parse(newQtyController.text.toString());
    Navigator.pop(context);
    newQtyController.clear();
    emit(OnChangeUnitPriceOfItem());
  }

  deleteFromBasket(int id) {
    basket.removeWhere((element) {
      return element.id == id;
    });
    print('|||||||||::${basket.length}::|||||||||');
    emit(OnDeleteItemFromBasket());
  }

  TextEditingController newDiscountController = TextEditingController();

  onChnageDiscountOfUnit(ProductModelData item, BuildContext context) {
    if (double.parse(calculateDiscountedPrice(
            double.parse(newDiscountController.text.toString()),
            item.listPrice,
            item.userOrderedQuantity)) >=
        double.parse(item.cost.toString())) {
      item.discount = double.parse(newDiscountController.text.toString());
    } else {
      errorGetBar('discount_invalid'.tr());
    }
    Navigator.pop(context);
    newDiscountController.clear();
    emit(OnChangeUnitPriceOfItem());
  }

  TextEditingController newAllDiscountController = TextEditingController();

  onChnageAllDiscountOfUnit(BuildContext context) {
    for (int i = 0; i < basket.length; i++) {
      if (double.parse(calculateDiscountedPrice(
              double.parse(newAllDiscountController.text.toString()),
              basket[i].listPrice,
              basket[i].userOrderedQuantity)) >=
          double.parse(basket[i].cost.toString())) {
        basket[i].discount =
            double.parse(newAllDiscountController.text.toString());
      } else {
        errorGetBar('discount_invalid'.tr());
      }
    }
    Navigator.pop(context);
    newAllDiscountController.clear();
    emit(OnChangeAllUnitPriceOfItem());
  }

  CreateOrderModel? creaPickingModel;
  createPicking({
    required int pickingId,
    required String image,
    String? note,
    int? partnerId,
    required String imagePath,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, "جاري التحميل ..");
    emit(LoadingCreatePicking());
    final result = await api.createPicking(
        sourceWarehouseId: pickingId,
        products: basket,
        image: image,
        partnerId: partnerId,
        imagePath: imagePath,
        note: note);
    result.fold((l) {
      Navigator.pop(context);
      emit(ErrorCreatePicking());
    }, (r) {
      Navigator.pop(context);
      creaPickingModel = r;
      if (creaPickingModel!.result!.message != null) {
        successGetBar(creaPickingModel!.result!.message.toString());
        basket = [];
        debugPrint("Success Create Pick");
        Navigator.pushReplacementNamed(context, Routes.mainRoute);
        Navigator.pushNamed(context, Routes.exchangePermissionRoute);
      } else {
        errorGetBar("error".tr());
      }

      emit(LoadedCreatePicking());
    });
  }
}

//
//
