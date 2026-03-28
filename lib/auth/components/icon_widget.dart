import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  const IconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.black,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: SizedBox(
        //     height: 48,
        //     width: 48,
        //     child: Center(
        //       child: Text(
        //         'M',
        //         style: TextStyle(
        //           fontSize: 24,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // const Icon(Icons.school, size: 80),
        Image.asset('assets/marooneen_logo.png', height: 120, width: 120),
        SizedBox(height: 8),
        Text(
          'Marooneen Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Please sign in to continue',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
