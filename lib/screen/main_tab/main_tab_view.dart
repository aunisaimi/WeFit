import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/main_tab/select_view.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/meal_plan_view.dart';
import 'package:diet_app/screen/photo_progress/photo_progress_view.dart';
import 'package:diet_app/screen/settings/settings_screen.dart';
import 'package:flutter/material.dart';

import '../../common/common_widget/tab_button.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  final int? remainingCalories;
  const MainTabView({Key? key, this.remainingCalories}) : super(key: key);

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectTab = 0;
  late Widget _currentTab;

  @override
  void initState() {
    _currentTab = HomeView(remainingCalories: widget.remainingCalories ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: _currentTab,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {},
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: TColor.primaryG),
              borderRadius: BorderRadius.circular(35),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2),
              ],
            ),
            child: Image.asset("assets/img/logo.png")
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            color: TColor.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                icon: "assets/img/home_tab.png",
                selectIcon: "assets/img/home_tab_select.png",
                isActive: _selectTab == 0,
                onTap: () {
                  setState(() {
                    _selectTab = 0;
                    _currentTab = HomeView(remainingCalories: 2500,);
                  });
                },
              ),
              TabButton(
                icon: "assets/img/activity_tab.png",
                selectIcon: "assets/img/activity_tab_select.png",
                isActive: _selectTab == 1,
                onTap: () {
                  setState(() {
                    _selectTab = 1;
                    _currentTab = const SelectView();
                  });
                },
              ),
              const SizedBox(width: 40),
              TabButton(
                icon: "assets/img/settings.png",
                selectIcon: "assets/img/set.png",
                isActive: _selectTab == 2,
                onTap: () {
                  setState(() {
                    _selectTab = 2;
                    _currentTab =  SettingsPage();
                  });
                },
              ),
              TabButton(
                icon: "assets/img/user_text.png",
                selectIcon: "assets/img/profile_tab_select.png",
                isActive: _selectTab == 3,
                onTap: () {
                  setState(() {
                    _selectTab = 3;
                    _currentTab = ProfileView();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}