import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_sale/core/remote/service.dart';
import 'package:top_sale/core/utils/appwidget.dart';
import 'package:top_sale/core/utils/dialogs.dart';

import 'package:top_sale/features/tasks/cubit/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this.api) : super(TasksInitial());
  ServiceApi api;
  TextEditingController titleController = TextEditingController();
  TextEditingController tasksController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());

  Future<void> onSelectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(9999),
    );

    if (picked != null) {
      selectedDate = picked;
      updateFormattedDate();
      emit(
          DeadlineDateSelectedState()); // Emit updated state with formatted date
    }
  }

  void updateFormattedDate() {
    formattedDate = DateFormat('yyyy-MM-dd', 'en').format(selectedDate);
  }

  Future<void> createTask({
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, "loading".tr());
    emit(LoadingCreateTaskState());
    final result = await api.createTask(
      deadline: formattedDate,
      description: tasksController.text,
      title: titleController.text,
    );
    result.fold(
      (failure) {
        emit(FailureCreateTaskState());
        Navigator.pop(context);
      },
      (r) {
        Navigator.pop(context);
        if (r.result!.error != null) {
          errorGetBar(r.result!.error!);
        } else {
          Navigator.pop(context);
          successGetBar(r.result!.message!);

          emit(SuccessCreateTaskState());
          titleController.clear();
          tasksController.clear();
          selectedDate = DateTime.now();
          formattedDate = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
        }

        // getPermissions();
      },
    );
  }
}
