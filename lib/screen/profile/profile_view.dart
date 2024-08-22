import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/title_subtitle_cell.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/screen/profile/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _goalController = TextEditingController();
  String profilePicture = '';
  String selectedDietId = '';
  String totalSteps = '';

  List<Map<String, dynamic>> historyList = []; // State variable to store history data

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserHistory();
  }

  // Future<int> _fetchDailySteps() async {
  //   String uid = _auth.currentUser!.uid;
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('steps')
  //       .doc('dailySteps')
  //       .get();
  //
  //   if (snapshot.exists && snapshot.data() != null) {
  //     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //     return data['totalSteps'] ?? 0;
  //   }
  //   return 0;
  // }

  Future<void> fetchUserData() async {
    try {
      // Get the current user's ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the user's document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract and set user data to the respective TextEditingController
        setState(() {
          _emailController.text = userDoc['email'];
          _firstnameController.text = userDoc['fname'];
          _lastnameController.text = userDoc['lname'];
          _genderController.text = userDoc['gender'];
          _goalController.text = userDoc['goal'];
          profilePicture = userDoc['profilePicture'];
          txtHeight.text = userDoc['height'].toString();
          txtWeight.text = userDoc['weight'].toString();
          selectedDietId = userDoc['selectedDietName'];
          totalSteps = userDoc['totalSteps'].toString();
        });
        print("This is the current user email: ${userDoc['email']}");
        print("This is the current user name: ${userDoc['fname']}");
      } else {
        print("Data not exist");
      }
    } catch (e) {
      print("Error, please check: ${e}");
    }
  }

  Future<void> fetchUserHistory() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the user's history from Firestore
      final historySnapshot = await FirebaseFirestore.instance
          .collection('history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> fetchedHistory = historySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if the required fields exist and handle missing fields gracefully
        final exercise = data.containsKey('exercise') ? data['exercise'] : {};
        final name = exercise.containsKey('name') ? exercise['name'] : 'Unknown Exercise';
        final title = exercise.containsKey('title') ? exercise['title'] : 'No Title';
        final status = data.containsKey('status') ? data['status'] : 'Unknown Status';
        final userDetails = data.containsKey('userDetails') ? data['userDetails'] : {};
        final bmi = userDetails.containsKey('bmi') ? userDetails['bmi'] : 'Unknown BMI';
        final finishTime = data.containsKey('finishTimestamp') && data['finishTimestamp'] is Timestamp
            ? (data['finishTimestamp'] as Timestamp).toDate()
            : null;
        final startTime = data.containsKey('startTimestamp') && data['startTimestamp'] is Timestamp
            ? (data['startTimestamp'] as Timestamp).toDate()
            : null;

        int? elapsedTime;
        if (startTime != null && finishTime != null) {
          elapsedTime = finishTime.difference(startTime).inSeconds;
        }

        print("Exercise: $name, Title: $title, Status: $status, BMI: $bmi, Start Time: $startTime, Finish Time: $finishTime, Elapsed Time: $elapsedTime"); // Debugging information

        return {
          'name': name,
          'title': title,
          'status': status,
          'bmi': bmi,
          'startTime': startTime,
          'finishTime': finishTime,
          'elapsedTime': elapsedTime, // Store elapsed time in seconds
        };
      }).toList();

      setState(() {
        historyList = fetchedHistory;
      });

    } catch (e) {
      print("Error fetching history: $e");
    }
  }

  String formatElapsedTime(int? seconds) {
    if (seconds == null) {
      return 'Unknown';
    }
    return '${seconds}s';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'late':
        return Colors.red;
      case 'pending':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User profile information
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: profilePicture.isNotEmpty
                        ? Image.network(
                        profilePicture,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover)
                        : Image.asset(
                      "assets/img/workingcats.jpg",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_firstnameController.text} ${_lastnameController.text}",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_goalController.text}",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: RoundButton(
                      title: "Edit",
                      type: RoundButtonType.bgSGradient,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfile())
                        );
                        // Navigate to edit profile page
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: txtHeight.text,
                      subtitle: "Height",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: txtWeight.text,
                      subtitle: "Weight",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: _genderController.text,
                      subtitle: "Gender",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              TitleSubtitleCell(
                title: selectedDietId,
                subtitle: "Selected Diet",
              ),

              const SizedBox(height: 15),
              TitleSubtitleCell(
                title: totalSteps,
                subtitle: "Total Steps",
              ),

              // User history information
              const SizedBox(height: 20),
              Text(
                "Exercise History",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  var historyItem = historyList[index];
                  final startTime = historyItem['startTime'] != null
                      ? DateFormat('hh:mm a').format(historyItem['startTime'])
                      : 'Unknown';
                  final finishTime = historyItem['finishTime'] != null
                      ? DateFormat('hh:mm a').format(historyItem['finishTime'])
                      : 'Unknown';
                  final elapsedTime = formatElapsedTime(historyItem['elapsedTime']);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: TColor.primaryColor2,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historyItem['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColor.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Title: ${historyItem['title']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColor.gray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Status: ${historyItem['status']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(historyItem['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'BMI: ${historyItem['bmi'] != null
                              ? double.parse(historyItem['bmi'].toStringAsFixed(2))
                              : 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColor.gray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Time: $startTime - $finishTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColor.gray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Elapsed Time: $elapsedTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColor.gray,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}