import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _strictGeofencing = true;
  bool _mockLocationDetection = true;
  bool _requireDeviceBinding = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure multiple locations and adjust security parameters.',
            style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
          ),
          const SizedBox(height: 32),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildGeofenceCard(),
                const SizedBox(height: 24),
                _buildSecurityPoliciesCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A232222)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Authorized Geofences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('lokasi').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No geofences defined. Manage them in Fraud Detection.',
                    style: TextStyle(color: Color(0xFF585857), fontSize: 13),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      _buildLocationItem(
                        data['tempat'] ?? 'Unknown',
                        '${data['latitude']}, ${data['longitude']}',
                        '${data['radius']}m',
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String name, String coords, String radius) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                coords,
                style: const TextStyle(color: Color(0xFF585857), fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              'Radius: $radius',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityPoliciesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A232222)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Policies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildToggleRow(
            'Strict Geofencing Restrictions',
            'App prevents check-ins outside the configured radiuses.',
            _strictGeofencing,
            (v) => setState(() => _strictGeofencing = v),
          ),
          const SizedBox(height: 20),
          _buildToggleRow(
            'Mock Location / Fake GPS Detection',
            'Instantly flags users utilizing spoofing networks.',
            _mockLocationDetection,
            (v) => setState(() => _mockLocationDetection = v),
          ),
          const SizedBox(height: 20),
          _buildToggleRow(
            'Enforce Device Binding',
            'Binds an account strictly to a single physical device.',
            _requireDeviceBinding,
            (v) => setState(() => _requireDeviceBinding = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF585857), fontSize: 13),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xFF585857),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.black
                : const Color(0xFFE0E0E0),
          ),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ],
    );
  }
}
