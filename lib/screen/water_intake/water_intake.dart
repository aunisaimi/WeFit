import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/screen/water_intake/WavePainter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../common/RoundButton.dart';

class WaterIntake extends StatefulWidget {
  final Function(double) onUpdate;

  const WaterIntake({
    Key? key,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<WaterIntake> createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> with SingleTickerProviderStateMixin {
  final TextEditingController _intakeController = TextEditingController();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final List<Map<String, String>> tips = [
    {
      "image": "assets/img/4d.png",
      "subtitle": "Drinking Water Helps Maintain\nthe Balance of Body Fluids"
    },
    {
      "image": "assets/img/5d.png",
      "subtitle": "Water Helps\nYour Kidneys"
    },
    {
      "image": "assets/img/6d.png",
      "subtitle": "Water Helps Maintain\nNormal Bowel Function."
    },
    {
      "image": "assets/img/3d.png",
      "subtitle": "Water Helps Keep\nSkin Looking Good"
    },
    {
      "image": "assets/img/2d.png",
      "subtitle": "Water Helps Energize\nMuscles"
    },
    {
      "image": "assets/img/1d.png",
      "subtitle": "Water Can Help\nControl Calories"
    },
  ];

  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logIntake(double intake) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(now); // Format the date

    final intakeEntry = {
      'intake': intake,
      'timestamp': now,
      'date': formattedDate, //now.toIso8601String().split('T').first,
      'userId': userId,
    };

    await FirebaseFirestore.instance.collection('intake').add(intakeEntry);
  }

  void _startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
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
              title: Text(
                "Water Intake",
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/drinks.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TColor.gray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                      Center(
                        child: Text(
                          "Log Your Water Intake Daily",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                      CarouselSlider(
                        items: tips.map((item) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: TColor.secondaryG,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: media.width * 0.05, horizontal: 10),
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Column(
                              children: [
                                Image.asset(
                                  item['image']!,
                                  width: media.width * 0.55,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(height: media.width * 0.05),
                                Text(
                                  item['subtitle']!,
                                  style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.7,
                          aspectRatio: 16 / 9,
                          initialPage: 0,
                          height: 250,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        ),
                      ),
                      const SizedBox(height: 30),
                      RoundTextField(
                        controller: _intakeController,
                        hitText: "Enter water intake (ml)",
                        icon: "assets/img/drop.png",
                        keyboardType: TextInputType.number,
                        obscureText: false,
                      ),
                      const SizedBox(height: 30),
                      ScaleTransition(
                        scale: _buttonAnimation,
                        child: RoundButton(
                          title: "Enter",
                          onPressed: () {
                            final intake = double.parse(_intakeController.text);
                            widget.onUpdate(intake);
                            _logIntake(intake); // save to firestore
                            _startAnimation();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WavePainter(animation: _waveAnimation),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
