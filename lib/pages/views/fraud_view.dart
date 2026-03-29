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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('lokasi').snapshots(),
      builder: (context, locSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('fraud_logs')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, fraudSnapshot) {
            final locDocs = locSnapshot.data?.docs ?? [];
            final fraudDocs = fraudSnapshot.data?.docs ?? [];

            // Collect all points with valid coords
            final List<_MapPoint> points = [];

            for (final doc in locDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final lat = (data['latitude'] as num?)?.toDouble();
              final lng = (data['longitude'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                points.add(
                  _MapPoint(
                    lat: lat,
                    lng: lng,
                    label: data['tempat'] ?? 'Location',
                    radius: (data['radius'] as num?)?.toDouble() ?? 100,
                    isAlert: false,
                  ),
                );
              }
            }

            for (final doc in fraudDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final lat = (data['latitude'] as num?)?.toDouble();
              final lng = (data['longitude'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                points.add(
                  _MapPoint(
                    lat: lat,
                    lng: lng,
                    label: data['userName'] ?? 'Unknown',
                    radius: 0,
                    isAlert: true,
                    sub: _getFraudTypeLabel(data['fraudType'] ?? 'fraud'),
                  ),
                );
              }
            }

            return Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: points.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No location data to display.\nAdd locations in the Geofences section below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF585857),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        const h = 400.0;
                        const pad = 60.0;

                        double minLat = points
                            .map((p) => p.lat)
                            .reduce((a, b) => a < b ? a : b);
                        double maxLat = points
                            .map((p) => p.lat)
                            .reduce((a, b) => a > b ? a : b);
                        double minLng = points
                            .map((p) => p.lng)
                            .reduce((a, b) => a < b ? a : b);
                        double maxLng = points
                            .map((p) => p.lng)
                            .reduce((a, b) => a > b ? a : b);

                        // Add padding so single-point doesn't collapse
                        const coordPad = 0.0005;
                        minLat -= coordPad;
                        maxLat += coordPad;
                        minLng -= coordPad;
                        maxLng += coordPad;

                        double px(double lng) {
                          if (maxLng == minLng) return w / 2;
                          return pad +
                              ((lng - minLng) / (maxLng - minLng)) *
                                  (w - pad * 2);
                        }

                        double py(double lat) {
                          if (maxLat == minLat) return h / 2;
                          return pad +
                              (1 - (lat - minLat) / (maxLat - minLat)) *
                                  (h - pad * 2);
                        }

                        double approxRadius(double radiusM) {
                          const metersPerDeg = 111320.0;
                          final lngRange = maxLng - minLng;
                          if (lngRange <= 0) return 30;
                          final radiusDeg = radiusM / metersPerDeg;
                          final pxPerDeg = (w - pad * 2) / lngRange;
                          return (radiusDeg * pxPerDeg).clamp(16.0, 140.0);
                        }

                        final List<Widget> pins = [];

                        // Geofence circles under the pins (non-alert)
                        for (final p in points.where(
                          (p) => !p.isAlert && p.radius > 0,
                        )) {
                          final cx = px(p.lng);
                          final cy = py(p.lat);
                          final r = approxRadius(p.radius);
                          pins.add(
                            Positioned(
                              left: cx - r,
                              top: cy - r,
                              child: IgnorePointer(
                                child: Container(
                                  width: r * 2,
                                  height: r * 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.06),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Location pins
                        for (final p in points.where((p) => !p.isAlert)) {
                          final cx = px(p.lng);
                          final cy = py(p.lat);
                          pins.add(
                            Positioned(
                              left: cx - 60,
                              top: cy - 52,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Fraud alert pins
                        for (final p in points.where((p) => p.isAlert)) {
                          final cx = px(p.lng);
                          final cy = py(p.lat);
                          pins.add(
                            Positioned(
                              left: cx - 65,
                              top: cy - 58,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 130,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC0000),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          p.label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        if (p.sub != null)
                                          Text(
                                            p.sub!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 8,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.warning_rounded,
                                    color: Color(0xFFCC0000),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(painter: _GridPainter()),
                            ),
                            ...pins,
                            // Legend
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.black,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Geofence',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Color(0xFFCC0000),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Fraud Alert',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFCC0000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnomalyAlertsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('fraud_logs')
          .orderBy('timestamp', descending: true)
          .limit(5)
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
              'Error loading fraud data.',
              style: TextStyle(color: Color(0xFF585857)),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gpp_good_outlined,
                    size: 40,
                    color: Color(0xFF585857),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No anomalies detected.',
                    style: TextStyle(color: Color(0xFF585857), fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Color(0xFFE0E0E0), height: 32),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['userName'] ?? 'Unknown';
            final npm = data['userNpm'] ?? '';
            final fraudType = data['fraudType'] ?? 'unknown';
            final description = data['description'] ?? 'No details available.';
            final className = data['className'] ?? '-';

            String timeStr = 'Just now';
            if (data['timestamp'] != null) {
              try {
                final dt = (data['timestamp'] as Timestamp).toDate();
                timeStr = DateFormat('hh:mm a').format(dt);
              } catch (_) {}
            }

            final String displayType = _getFraudTypeLabel(fraudType);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232222),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
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
                            displayType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 13,
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
                      const SizedBox(height: 3),
                      Text(
                        '$name${npm.isNotEmpty ? ' · $npm' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF585857),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF585857),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF585857),
                          fontStyle: FontStyle.italic,
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

  String _getFraudTypeLabel(String fraudType) {
    switch (fraudType.toLowerCase()) {
      case 'fake_gps':
        return 'Fake GPS Detected';
      case 'out_of_radius':
        return 'Out of Radius';
      case 'rooted_device':
        return 'Rooted Device';
      case 'multiple_login':
        return 'Multiple Device Login';
      default:
        return fraudType.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildHistoricalLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('fraud_logs')
          .orderBy('timestamp', descending: true)
          .limit(20)
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

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 40,
                    color: Color(0xFF585857),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No fraud logs found.',
                    style: TextStyle(color: Color(0xFF585857)),
                  ),
                ],
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
              dataRowMaxHeight: 80,
              columns: const [
                DataColumn(
                  label: Text(
                    'STUDENT',
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
                    'CLASS',
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
                    'FRAUD TYPE',
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
                    'DESCRIPTION',
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
                    'TIMESTAMP',
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
                final name = data['userName'] ?? 'Unknown';
                final npm = data['userNpm'] ?? '';
                final className = data['className'] ?? '-';
                final fraudType = data['fraudType'] ?? 'unknown';
                final description = data['description'] ?? '-';

                String dateStr = '-';
                if (data['timestamp'] != null) {
                  try {
                    dateStr = DateFormat(
                      'MMM dd, hh:mm a',
                    ).format((data['timestamp'] as Timestamp).toDate());
                  } catch (_) {}
                }

                final displayType = _getFraudTypeLabel(fraudType);

                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          if (npm.isNotEmpty)
                            Text(
                              npm,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF585857),
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF585857),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          displayType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF585857),
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF585857),
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

class _MapPoint {
  final double lat;
  final double lng;
  final String label;
  final double radius;
  final bool isAlert;
  final String? sub;

  const _MapPoint({
    required this.lat,
    required this.lng,
    required this.label,
    required this.radius,
    required this.isAlert,
    this.sub,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.8;

    const double spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
