import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;

  const AddScheduleView({Key? key, required this.date}) : super(key: key);

  @override
  _AddScheduleViewState createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(widget.date.year, widget.date.month,
            widget.date.day, picked.hour, picked.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout Schedule"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RoundTextField(
              controller: _nameController,
              hitText: 'Workout name',
              obscureText: false,
              icon: 'assets/img/choose_workout.png',
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _selectTime(context),
              child: Text(
                _selectedTime == null
                    ? "Select Time"
                    : "Selected Time: ${_selectedTime!.hour}:${_selectedTime!.minute}",
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _selectedTime != null)  {
                  // save the workout to shared pref
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  List<String> workouts = prefs.getStringList('workouts') ?? [];
                  workouts.add('${_nameController.text} | ${_selectedTime!.toIso8601String()}');
                  prefs.setStringList('workouts', workouts);

                  // Schedule Notification
                  scheduleNotification(_nameController.text, _selectedTime!);

                  Navigator.pop(
                    context,
                    {
                      "name": _nameController.text,
                      "date": _selectedTime,
                    },
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
