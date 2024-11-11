import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/api/end_points.dart';
import 'package:top_sale/core/models/all_payments_model.dart';
import 'package:top_sale/core/remote/service.dart';
import 'package:top_sale/core/utils/appwidget.dart';
import 'package:top_sale/core/utils/dialogs.dart';
import 'package:top_sale/features/details_order/screens/pdf.dart';
import '../../../core/models/all_journals_model.dart';
import '../../../core/models/defaul_model.dart';
import 'create_receipt_coucher_state.dart';

class CreateReceiptCoucherCubit extends Cubit<CreateReceiptCoucherState> {
  CreateReceiptCoucherCubit(this.api) : super(CreateReceiptCoucherInitial());
  ServiceApi api;
  DateTime? selectedDate;
  int? selectedPaymentMethod;
  TextEditingController amountController = TextEditingController();
  TextEditingController refController = TextEditingController();
  GetAllJournalsModel? getAllJournalsModel;
  void getAllJournals() async {
    emit(GetAllJournalsLoadingState());
    final result = await api.getAllJournals();
    result.fold(
      (failure) =>
          emit(GetAllJournalsErrorState('Error loading  data: $failure')),
      (r) {
        getAllJournalsModel = r;
        emit(GetAllJournalsLoadedState());
      },
    );
  }

  void partnerPaymentMethod(BuildContext context,
      {required int partnerId}) async {
    AppWidget.createProgressDialog(context, "جاري التحميل");
    emit(GetAllJournalsLoadingState());
    String formattedDate = DateFormat('yyyy-MM-dd',).format(selectedDate!);
    final result = await api.partnerPayment(
      amount: amountController.text,
      journalId: selectedPaymentMethod!,
      ref: refController.text,
      date: formattedDate,
      // date: selectedDate.toString(),
      partnerId: partnerId,
    );
    result.fold((failure) {
      Navigator.pop(context);
      errorGetBar("error_register_payment".tr());
      emit(GetAllJournalsErrorState('Error loading  data: $failure'));
    }, (r) {
      Navigator.pop(context);
      if (r.result != null) {
        if (r.result!.message != null) {
          emit(GetAllJournalsLoadedState());
          successGetBar("do_create_receipt_coucher".tr());
          Navigator.pop(context);
          Navigator.pop(context);
          refController.clear();
          amountController.clear();
          selectedPaymentMethod = null;
          selectedDate = null;
          if (r.result!.paymentId != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return PdfViewerPage(
                  baseUrl:
                      '${EndPoints.printPayment}${r.result!.paymentId.toString()}',
                );
                // return PaymentWebViewScreen(url: "",);
              },
            ));
          }

          getAllReceiptVoucher();
        } else {
          errorGetBar("error_register_payment".tr());
          emit(GetAllJournalsErrorState('Error loading  data: '));
        }
      } else {
        errorGetBar("error_register_payment".tr());
        emit(GetAllJournalsErrorState('Error loading  data: '));
      }
    });
  }

  TextEditingController searchController = TextEditingController();
  AllPaymentsModel allPaymentsModel = AllPaymentsModel();
  getAllReceiptVoucher({String? searchKey}) async {
    emit(GetPaymentsLoading());
    final result = await api.getAllPayments(searchKey);
    result.fold(
      (failure) => emit(GetPaymentsError()),
      (r) {
        allPaymentsModel = r;
        emit(GetPaymentsLoaded());
      },
    );
  }
}
