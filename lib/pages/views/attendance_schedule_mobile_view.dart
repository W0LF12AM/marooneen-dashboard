import 'package:flutter/material.dart';

class AttendanceScheduleMobileView extends StatelessWidget {
  const AttendanceScheduleMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mobile_friendly, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Mobile Attendance Interface',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This view is intended for student mobile access.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simulate Check-in',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
