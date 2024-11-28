import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/date_widget.dart';
import 'package:top_sale/core/utils/textfield_widget.dart';
import 'package:top_sale/features/login/widget/custom_button.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../../../core/utils/style_text.dart';
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> arabicDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<TasksCubit>(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('tasks'.tr()),
        centerTitle: false,
        titleTextStyle: TextStyles.size16FontWidget400Black,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // FAB on bottom left
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            left: 5.0.w, bottom: 80.0.h), // Adjust padding if needed
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: AppColors.secondPrimary,
          onPressed: () {
            showAddTasksBottomSheet(context, cubit);
          },
          child: Icon(
            Icons.add,
            color: AppColors.white,
            size: 30.sp,
          ),
        ),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(builder: (context, state) {
        return ListView(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: EdgeInsets.all(8.0.sp),
              margin: EdgeInsets.all(8.0.sp),
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadiusDirectional.circular(8.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'ar',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  todayTextStyle: TextStyle(
                    color: (_selectedDay != null &&
                            isSameDay(_selectedDay, DateTime.now()))
                        ? Colors.white
                        : Colors.black,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  markerMargin: EdgeInsets.symmetric(horizontal: 0.5),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) {
                      return arabicDays[date.weekday % 7];
                    },
                    weekdayStyle: TextStyles.size16FontWidget400Black,
                    weekendStyle: TextStyles.size16FontWidget400Black),
                headerStyle: HeaderStyle(
                  formatButtonShowsNext: false,
                  titleTextStyle: TextStyles.size18FontWidget700Gray,
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                headerVisible: true,
              ),
            ),
            SizedBox(height: 10.h),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  bottom: 70.0), // Add padding at the bottom to avoid overlap
              children: [
                TaskCard(
                  title: "عنوان المهمة",
                  description:
                      "عندنا اجتماع في النشرة الساعة الخامسة اجتماع لمناقشة مهام الشركة",
                ),
                TaskCard(
                  title: "عنوان المهمة",
                  description:
                      "عندنا اجتماع في النشرة الساعة الخامسة اجتماع لمناقشة مهام الشركة",
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;

  TaskCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0.sp),
      child: Card(
        color: AppColors.white,
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyles.size16FontWidget400Primary),
                  Icon(Icons.delete_forever_rounded,
                      color: AppColors.red, size: 25.sp),
                ],
              ),
              SizedBox(height: 8.sp),
              Text(
                description,
                style: TextStyles.size14FontWidget400Black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddTasksBottomSheet(BuildContext context, TasksCubit cubit) {
  showModalBottomSheet(
    backgroundColor: AppColors.white,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return BlocBuilder<TasksCubit, TasksState>(builder: (context, state) {
        var cubit = BlocProvider.of<TasksCubit>(context);

        return Padding(
          padding: EdgeInsets.only(
            left: 16.sp,
            right: 16.sp,
            top: 16.sp,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DatePickerField(
                title: "موعد التسليم",
                onTab: () {
                  cubit.onSelectedDate(context);
                },
                selectedDate: cubit.selectedDate,
            
              ),
              SizedBox(height: 10.h),
              TextFieldWidget(
                  titleFromTextField: "address".tr(),
                  controller: cubit.titleController,
                  hintFromTextField: "enter_address".tr()),
              SizedBox(height: 20.h),
              TextFieldWidget(
                controller: cubit.tasksController,
                maxLines: 4,
                hintFromTextField: "add_your_task".tr(),
                titleFromTextField: "task".tr(),
              ),
              SizedBox(height: 20.h),
              CustomButton(
                title: "add".tr(),
                onTap: () {
                  if (cubit.titleController.text.isNotEmpty &&
                      cubit.tasksController.text.isNotEmpty) {
                    cubit.createTask(context: context);
                  }
                },
              )
            ],
          ),
        );
      });
    },
  );
}
