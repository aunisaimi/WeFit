import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common.dart';
import 'package:diet_app/screen/workout_tracker/add_schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/RoundButton.dart';

class WorkoutScheduleView extends StatefulWidget {
  const WorkoutScheduleView({super.key});

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  late DateTime _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  List<Map<String, dynamic>> eventArr = [];

  // Map to store schedules based on dates
  Map<DateTime, List<Map<String, dynamic>>> schedules = {};

  List<Map<String, dynamic>> selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    setDayEventWorkoutList();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workouts = prefs.getStringList('workouts') ?? [];
    for (String workout in workouts){
      List<String> split = workout.split('|');
      String name = split[0];
      DateTime date = DateTime.parse(split[1]);
      DateTime startDate = dateToStartDate(date);
      if(schedules.containsKey(startDate)){
        schedules[startDate]!.add({"name": name, "date": date});
      } else {
        schedules[startDate] = [{"name": name, "date": date}];
      }
    }
    setDayEventWorkoutList();
  }

  // void setDayEventWorkoutList() async {
  //   var date = dateToStartDate(_selectedDate);
  //   selectDayEventArr = eventArr.map((wObj) {
  //     return {
  //       "name": wObj["name"],
  //       "start_time": wObj["start_time"],
  //       "date": stringToDate(
  //           wObj["start_time"].toString(),
  //           formatStr: "dd/MM/yyyy hh:mm:aa")
  //     };
  //   }).where((wObj) {
  //     return dateToStartDate(wObj["date"] as DateTime) == date;
  //   }).toList();
  //
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDate);
    selectDayEventArr = schedules[date] ?? [];

    if (mounted) {
      setState(() {});
    }
  }

  DateTime dateToStartDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child:IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_rounded))
          ),
        ),
        title: Text(
          "Workout Schedule",
          style: TextStyle(
              color: TColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _calendarFormat = CalendarFormat.week;
                setDayEventWorkoutList();
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _selectedDate = focusedDay;
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var timelineDataWidth = (media.width * 1.5) - (80 + 40);
                      var availWidth = (media.width * 1.2) - (80 + 40);
                      var slotArr = selectDayEventArr.where((wObj) {
                        return (wObj["date"] as DateTime).hour == index;
                      }).toList();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                getTime(index * 60),
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (slotArr.isNotEmpty)
                              Expanded(
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: slotArr.map((sObj) {
                                      var min =
                                          (sObj["date"] as DateTime).minute;
                                      //(0 to 2)
                                      var pos = (min / 60) * 2 - 1;

                                      return Align(
                                        alignment: Alignment(pos, 0),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  contentPadding: EdgeInsets.zero,
                                                  content: Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15, horizontal: 20),
                                                    decoration: BoxDecoration(
                                                      color: TColor.white,
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                margin:
                                                                const EdgeInsets.all(8),
                                                                height: 40,
                                                                width: 40,
                                                                alignment: Alignment.center,
                                                                decoration: BoxDecoration(
                                                                    color: TColor.lightGray,
                                                                    borderRadius: BorderRadius.circular(10)),
                                                                child: IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  icon: const Icon(Icons.close),

                                                                )
                                                              ),
                                                            ),
                                                            Text(
                                                              "Workout Schedule",
                                                              style: TextStyle(
                                                                  color: TColor.black,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w700),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(height: 15),

                                                        Text(
                                                          sObj["name"].toString(),
                                                          style: TextStyle(
                                                              color: TColor.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.w700),
                                                        ),
                                                        const SizedBox(height: 4,),
                                                        Row(
                                                            children: [
                                                              Image.asset(
                                                                "assets/img/time_workout.png",
                                                                height: 20,
                                                                width: 20,
                                                          ),
                                                          const SizedBox(width: 8,),
                                                          Text(
                                                            "${getDayTitle(
                                                                sObj["start_time"]
                                                                    .toString())}|${getStringDateToOtherFormate(
                                                                sObj["start_time"]
                                                                    .toString(),
                                                                outFormatStr: "h:mm aa")}",
                                                            style: TextStyle(
                                                                color: TColor.gray,
                                                                fontSize: 12),
                                                          )
                                                        ]),
                                                        const SizedBox(height: 15,),
                                                        RoundButton(
                                                            title: "Mark Done",
                                                            onPressed: () {}),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 35,
                                            width: availWidth * 0.5,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    TColor.secondaryColor1,
                                                    TColor.secondaryColor2,
                                                  ]),
                                              borderRadius:
                                              BorderRadius.circular(17.5),
                                            ),
                                            child: Text(
                                              sObj["name"].toString(),
                                              style: TextStyle(
                                                color: TColor.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ))
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 0.5,
                        color: TColor.gray,
                      );
                    },
                    itemCount: 24),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddScheduleView(date: _selectedDate)),
          );

          // Handle the result and update the eventArr
          if (result != null) {
            setState(() {
              DateTime date = dateToStartDate(result["date"]);
              if(schedules.containsKey(date)){
                schedules[date]!.add(result);
              } else {
                schedules[date] = [result];
              }
              setDayEventWorkoutList();
              // eventArr.add(result);
              // setDayEventWorkoutList();
            });
          }
        },
        backgroundColor: TColor.primaryColor1,
        child: const Icon(Icons.add),
      ),
    );
  }


  DateTime stringToDate(String dateStr, {String formatStr = "yyyy-MM-dd"}) {
    return DateFormat(formatStr).parse(dateStr);
  }

  String getStringDateToOtherFormate(String dateStr,
      {String outFormatStr = "yyyy-MM-dd"}) {
    DateTime date = DateFormat("dd/MM/yyyy hh:mm aa").parse(dateStr);
    return DateFormat(outFormatStr).format(date);
  }

  String getTime(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(
        2, '0')}';
  }

  String getDayTitle(String dateStr) {
    DateTime date = DateFormat("dd/MM/yyyy hh:mm aa").parse(dateStr);
    return DateFormat('EEEE').format(date);
  }
}


