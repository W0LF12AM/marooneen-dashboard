import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FraudView extends StatefulWidget {
  const FraudView({super.key});

  @override
  State<FraudView> createState() => _FraudViewState();
}

class _FraudViewState extends State<FraudView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddLocationDialog({
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    final TextEditingController tempatCtrl = TextEditingController(
      text: existingData?['tempat'],
    );
    final TextEditingController latCtrl = TextEditingController(
      text: existingData?['latitude']?.toString(),
    );
    final TextEditingController lngCtrl = TextEditingController(
      text: existingData?['longitude']?.toString(),
    );
    final TextEditingController radiusCtrl = TextEditingController(
      text: existingData?['radius']?.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            docId == null
                ? 'Add Authorized Location'
                : 'Edit Authorized Location',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogField(
                    'Location Name',
                    'e.g., Central Office',
                    tempatCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogField(
                          'Latitude',
                          'e.g., -6.2000',
                          latCtrl,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDialogField(
                          'Longitude',
                          'e.g., 106.8166',
                          lngCtrl,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDialogField(
                    'Radius (meters)',
                    'e.g., 100',
                    radiusCtrl,
                    isNumber: true,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final tempat = tempatCtrl.text;
                final lat = double.tryParse(latCtrl.text) ?? 0.0;
                final lng = double.tryParse(lngCtrl.text) ?? 0.0;
                final radius = int.tryParse(radiusCtrl.text) ?? 0;

                if (tempat.isNotEmpty) {
                  final data = {
                    'tempat': tempat,
                    'latitude': lat,
                    'longitude': lng,
                    'radius': radius,
                  };

                  if (docId == null) {
                    await _firestore.collection('lokasi').add(data);
                  } else {
                    await _firestore
                        .collection('lokasi')
                        .doc(docId)
                        .update(data);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Geofence ${docId == null ? 'added' : 'updated'} successfully!',
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                docId == null ? 'Save Geofence' : 'Update Geofence',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Fraud & Security Command',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor out-of-radius alerts, map validations, and tracking anomalies.',
            style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
          ),
          const SizedBox(height: 32),

          // Main Map and Alerts Split
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Map Visualization
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x1A232222)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Live Map Tracking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.redAccent,
                                    size: 8,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'RADAR ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      _buildMapVisualization(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Anomaly Alerts Panel
              Expanded(
                flex: 4,
                child: Container(
                  height: 485, // align with map roughly
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x1A232222)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Security Anomalies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      Expanded(child: _buildAnomalyAlertsStream()),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Historical Flags Table
          Container(
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
                    'Recent Fraud Logs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildHistoricalLogs(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Geofence Management Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1A232222)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authorized Geofences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage locations where attendance is allowed.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF585857),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddLocationDialog,
                        icon: const Icon(Icons.add_location_alt, size: 16),
                        label: const Text(
                          'Add Location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildGeofenceList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('lokasi').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                'No geofences defined. Add one to start tracking.',
                style: TextStyle(color: Color(0xFF585857), fontSize: 13),
              ),
            ),
          );
        }

        return Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: const Color(0xFFE0E0E0)),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              horizontalMargin: 24,
              columnSpacing: 24,
              headingRowHeight: 56,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(
                  label: Text(
                    'LOCATION NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'COORDINATES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'RADIUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ACTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        data['tempat'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${data['latitude']}, ${data['longitude']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF585857),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${data['radius'] ?? 0}m',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => _showAddLocationDialog(
                              docId: doc.id,
                              existingData: data,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _confirmDeleteLocation(
                              doc.id,
                              data['tempat'] ?? 'this location',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapVisualization() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Stack(
        children: [
          // Background Grid Simulation
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Mock Data points
          _buildMapPin(
            top: 80,
            left: 120,
            label: 'Central Hub',
            color: Colors.black,
          ),
          _buildMapPin(
            top: 150,
            left: 240,
            label: 'Approved Zone',
            color: const Color(0xFF585857),
            size: 8,
          ),
          _buildMapPin(
            top: 220,
            left: 180,
            label: 'Approved Zone',
            color: const Color(0xFF585857),
            size: 8,
          ),

          // Out of radius Anomaly Pin
          Positioned(
            bottom: 60,
            right: 80,
            child: _buildRadarRipple(
              child: _buildMapPin(
                top: 0,
                left: 0,
                label: 'Out of Radius\n(Unknown User)',
                color: Colors.black,
                isAlert: true,
              ),
            ),
          ),

          // Map Controls Placeholder
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 20),
                    onPressed: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarRipple({required Widget child}) {
    // Usually uses AnimationController, wrapping in a stylized pulsing red shade container
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.redAccent.withAlpha(20), // 0x33 or similar transparency
        border: Border.all(color: Colors.redAccent.withAlpha(100), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildMapPin({
    required double top,
    required double left,
    required String label,
    required Color color,
    double size = 12,
    bool isAlert = false,
  }) {
    if (top == 0 && left == 0) {
      // relative layout use case
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAlert ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isAlert ? Colors.black : const Color(0xFFE0E0E0),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isAlert ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            isAlert ? Icons.location_on : Icons.my_location,
            color: color,
            size: size * 2,
          ),
        ],
      );
    }

    return Positioned(
      top: top,
      left: left,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.my_location, color: color, size: size * 2),
        ],
      ),
    );
  }

  Widget _buildAnomalyAlertsStream() {
    // Assuming potential "alerts" collection exists or derived from presensi querying 'isFraud' / anomalies
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('presensi')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error analyzing data.',
              style: TextStyle(color: Color(0xFF585857)),
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        // For demonstration, we'll arbitrarily flag the first item or simulate filtering for anomalies.
        // Replace 'isAnomaly' logic with actual backend checks (e.g., Fake GPS, Rooted, Out of radius).
        var anomalyDocs = docs.where((doc) {
          // If you have `isFraud` boolean:
          // final data = doc.data() as Map<String, dynamic>;
          // return data['isFraud'] == true || data['outOfRadius'] == true;
          return true; // Mock displaying them as "recent checks evaluated"
        }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No anomalies detected today.',
                style: TextStyle(color: Color(0xFF585857), fontSize: 13),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: anomalyDocs.length > 5
              ? 5
              : anomalyDocs.length, // Show up to 5 alerts
          separatorBuilder: (context, index) =>
              const Divider(color: Color(0xFFE0E0E0), height: 32),
          itemBuilder: (context, index) {
            final data = anomalyDocs[index].data() as Map<String, dynamic>;
            final name = data['userName'] ?? 'Unknown Member';

            // Simulating a specific anomaly type for UI richness
            final anomalyTypes = [
              'Out of Radius',
              'Fake GPS Detected',
              'Multiple Device Login',
            ];
            final String anomalyType = index < 2
                ? anomalyTypes[index % 3]
                : 'Verified OK';
            final bool isThreat = index < 2; // Mock logic

            String timeStr = 'Just now';
            if (data['timestamp'] != null) {
              try {
                final dt = (data['timestamp'] as Timestamp).toDate();
                timeStr = DateFormat('hh:mm a').format(dt);
              } catch (_) {}
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isThreat
                        ? const Color(0xFF232222)
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isThreat ? Colors.black : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Icon(
                    isThreat ? Icons.warning_rounded : Icons.gpp_good_rounded,
                    color: isThreat ? Colors.white : const Color(0xFF585857),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            anomalyType,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isThreat
                                  ? Colors.black
                                  : const Color(0xFF585857),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF585857),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account: $name',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF585857),
                        ),
                      ),
                      if (isThreat)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: InkWell(
                            onTap: () {},
                            child: const Text(
                              'Review Details →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHistoricalLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('presensi')
          .orderBy('timestamp', descending: true)
          .limit(8)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: Text(
                'No historical logs found.',
                style: TextStyle(color: Color(0xFF585857)),
              ),
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: const Color(0xFFE0E0E0),
            dataTableTheme: DataTableThemeData(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
              dataRowColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered))
                  return const Color(0xFFF5F5F5);
                return Colors.white;
              }),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              horizontalMargin: 24,
              columnSpacing: 24,
              headingRowHeight: 56,
              dataRowMinHeight: 70,
              dataRowMaxHeight: 70,
              columns: const [
                DataColumn(
                  label: Text(
                    'EMPLOYEE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DATE LOG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'LOCATION MATCH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DEVICE METRICS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'EVALUATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['userName'] ?? 'Unknown Member';

                String dateStr = '-';
                if (data['timestamp'] != null) {
                  try {
                    dateStr = DateFormat(
                      'MMM dd, hh:mm a',
                    ).format((data['timestamp'] as Timestamp).toDate());
                  } catch (_) {}
                }

                // Simulating evaluations based on arbitrary metric
                bool isClean = name.toString().length % 2 == 0;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF585857),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isClean ? 'Radius Match' : 'Out of Bounds',
                        style: TextStyle(
                          color: isClean
                              ? const Color(0xFF585857)
                              : Colors.black,
                          fontWeight: isClean
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isClean ? 'Verified' : 'Fake GPS Risk',
                        style: TextStyle(
                          color: isClean
                              ? const Color(0xFF585857)
                              : Colors.black,
                          fontWeight: isClean
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isClean
                              ? const Color(0xFFF4F4F4)
                              : Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isClean
                                ? const Color(0xFFE0E0E0)
                                : Colors.black,
                          ),
                        ),
                        child: Text(
                          isClean ? 'PASSED' : 'FLAGGED',
                          style: TextStyle(
                            color: isClean
                                ? const Color(0xFF585857)
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteLocation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Delete authorized location for $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _firestore.collection('lokasi').doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a minimalist grid matching the aesthetic
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0).withAlpha(100)
      ..strokeWidth = 1.0;

    const double spacing = 40.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double j = 0; j < size.height; j += spacing) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
