import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Replace with your actual home/dashboard screen

class SuccessScreen extends StatelessWidget {

  final String checklistId;
  const SuccessScreen({super.key,required this.checklistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Checklist Created!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your checklist has been\ncreated successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5B3DF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChecklistOverviewScreen(checklistId: checklistId),
                      ),
                    );
                    

                  },
                  child: const Text(
                    "View Checklist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateCheckListScreen(),
                      ),
                      (route) => false,
                    );

                  },
                  child: const Text(
                    "Add Another",
                    style: TextStyle(
                      color: Color(0xff5B3DF5),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}