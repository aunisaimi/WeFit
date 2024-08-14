import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/model/steps.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';

class StepDetailRow extends StatelessWidget {
  final StepModel sObj;
  final bool isLast;

  const StepDetailRow({
    Key? key,
    required this.sObj,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stepNumber = sObj.stepNumber ?? 'N/A';
    final description = sObj.description ?? 'No Description Available';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32, // Increase size for better visibility
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [TColor.secondaryColor1, TColor.secondaryColor2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16, // Increase font size for better readability
                      fontWeight: FontWeight.bold, // Bold font for step number
                    ),
                  ),
                ),
                if (!isLast)
                  DottedDashedLine(
                    height: 60, // Adjust height to fit the content
                    width: 2, // Adjust width for better visibility
                    dashColor: TColor.secondaryColor1,
                    axis: Axis.vertical,
                  ),
              ],
            ),
            const SizedBox(width: 12), // Increase spacing between step number and description
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $stepNumber', // Display the step number with label
                    style: TextStyle(
                      color: TColor.primaryColor1, // Change to primary color for contrast
                      fontSize: 16, // Increase font size
                      fontWeight: FontWeight.bold, // Bold font for step label
                    ),
                  ),
                  const SizedBox(height: 4), // Add a small space between the step label and description
                  Text(
                    description, // Display the description
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14, // Increase font size
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          const SizedBox(height: 8), // Space between steps
      ],
    );
  }
}
