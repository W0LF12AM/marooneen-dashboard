import 'package:flutter/material.dart';
import 'package:marooneen_dashboard/pages/views/attendance_view.dart';
import 'package:marooneen_dashboard/pages/views/broadcast_view.dart';
import 'package:marooneen_dashboard/pages/views/dashboard_view.dart';
import 'package:marooneen_dashboard/pages/views/student_view.dart';
import 'package:marooneen_dashboard/pages/views/fraud_view.dart';
import 'package:marooneen_dashboard/pages/views/reports_view.dart';
import 'package:marooneen_dashboard/pages/views/settings_view.dart';
import 'package:marooneen_dashboard/pages/views/schedule_management_view.dart';
import 'package:marooneen_dashboard/pages/views/tickets_view.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Students', 'icon': Icons.people_outline},
    {'title': 'Attendance', 'icon': Icons.access_time},
    {'title': 'Schedules', 'icon': Icons.calendar_month_outlined},
    {'title': 'Fraud Detection', 'icon': Icons.security},
    {'title': 'Settings', 'icon': Icons.settings_outlined},
    {'title': 'Reports', 'icon': Icons.description_outlined},
    {'title': 'Broadcast', 'icon': Icons.campaign_outlined},
    {'title': 'Support Tickets', 'icon': Icons.confirmation_num_outlined},
  ];

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const StudentView();
      case 2:
        return const AttendanceView();
      case 3:
        return const ScheduleManagementView();
      case 4:
        return const FraudView();
      case 5:
        return const SettingsView();
      case 6:
        return const ReportsView();
      case 7:
        return const BroadcastView();
      case 8:
        return const TicketsView();
      default:
        return const Center(child: Text('Halaman tidak ditemukan'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- SIDEBAR ---
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & App Name
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/marooneen_logo.png",
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Marooneen',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'MAIN MENU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          hoverColor: Colors.grey.shade100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.grey.shade200
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _menuItems[index]['icon'],
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _menuItems[index]['title'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade800,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context); // Balik ke Login Screen
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- VERTICAL DIVIDER ---
          Container(width: 1, color: Colors.grey.shade200),

          // --- MAIN CONTENT AREA ---
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  // Top App Bar Area (Optional, for Breadcrumbs or User Profile)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _menuItems[_selectedIndex]['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Profil Admin
                        Row(
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Admin Marooneen',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'admin@marooneen.com',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Content Page
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildBodyContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
