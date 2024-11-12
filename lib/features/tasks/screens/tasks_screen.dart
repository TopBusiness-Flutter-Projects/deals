import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:top_sale/core/utils/app_colors.dart';

import '../../attendance_and_departure/screens/holidays_type_screen.dart';


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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('tasks'.tr()),
        centerTitle: false,
        titleTextStyle: TextStyle(color: AppColors.black, fontSize: 20.sp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // FAB on bottom left
      floatingActionButton: FloatingActionButton(
        shape:  CircleBorder(),
        backgroundColor: AppColors.secondPrimary,
        onPressed: () {
          showAddTasksBottomSheet(context);
        },
        child: Icon(Icons.add, color: AppColors.white,size: 30.sp,),
      ),
      body: Column(
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
                  color: (_selectedDay != null && isSameDay(_selectedDay, DateTime.now()))
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
                weekdayStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
                weekendStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.bold),
                formatButtonVisible: false,
                titleCentered: true,
              ),
              headerVisible: true,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 70.0), // Add padding at the bottom to avoid overlap
              children: [
                TaskCard(
                  title: "عنوان المهمة",
                  description: "عندنا اجتماع في النشرة الساعة الخامسة اجتماع لمناقشة مهام الشركة",
                ),
                TaskCard(
                  title: "عنوان المهمة",
                  description: "عندنا اجتماع في النشرة الساعة الخامسة اجتماع لمناقشة مهام الشركة",
                ),
              ],
            ),
          ),
        ],
      ),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.sp),
              Text(
                description,
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );

  }

}
void showAddTasksBottomSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: AppColors.white,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
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
              label:    "date".tr(),
              selectedDate: "select_date".tr(),
            ),
            SizedBox(height: 10.h),
            Text(
              "address".tr(),
              style: TextStyle(fontSize: 18.sp,color: AppColors.black.withOpacity(0.7)),
            ),
            SizedBox(height: 10.h),
            TextField(
              decoration: InputDecoration(
                hintText: "enter_address".tr(),
                hintStyle: TextStyle(color: AppColors.black.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "task".tr(),
              style: TextStyle(fontSize: 18.sp,color: AppColors.black.withOpacity(0.7)),
            ),
            SizedBox(height: 8.h),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "add_your_task".tr(),
                hintStyle: TextStyle(color: AppColors.black.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.sp),
                  color: AppColors.primary,
                ),
                child: Center(child: Text("add".tr(),style: TextStyle(color: AppColors.white),),),
              ),
            )
          ],
        ),
      );
    },
  );
}
