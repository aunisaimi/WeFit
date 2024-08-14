import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/notification_row.dart';
import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List notiArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Hey time for lunch",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Hey leg day!",
      "time": "About 2 hours ago"
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "You are done for today",
      "time": "About 15 minutes ago"
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: (){},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Icon(Icons.more_horiz_rounded),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 25),
          itemBuilder: ((context,index){
            var nObj = notiArr[index] as Map? ?? {};
            return NotificationRow(nObj: nObj);
          }),
          separatorBuilder: (context,index){
          return Divider(
            color: TColor.gray.withOpacity(0.5),
            height: 1);
          },
          itemCount: notiArr.length),
    );
  }
}
