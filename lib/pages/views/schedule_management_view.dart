import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final TextEditingController _courseCtrl = TextEditingController();
  final TextEditingController _meetingCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _startCtrl = TextEditingController();
  final TextEditingController _endCtrl = TextEditingController();

  Map<String, dynamic>? _selectedLocData;

  @override
  void dispose() {
    _courseCtrl.dispose();
    _meetingCtrl.dispose();
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _showCreateClassDialog({String? docId, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      _courseCtrl.text = existingData['kelas'] ?? '';
      _meetingCtrl.text = (existingData['pertemuan'] ?? '').toString();
      _dateCtrl.text = existingData['tanggal'] ?? '';
      
      // Parse "08.00 - 10.00" back to start and end
      final jam = existingData['jam'] as String? ?? '';
      if (jam.contains(' - ')) {
        final parts = jam.split(' - ');
        _startCtrl.text = parts[0];
        _endCtrl.text = parts[1];
      }
      
      _selectedLocData = {
        'tempat': existingData['tempat'],
        'latitude': existingData['latitude'],
        'longitude': existingData['longitude'],
        'radius': existingData['radius'],
      };
    } else {
      _courseCtrl.clear();
      _meetingCtrl.clear();
      _dateCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
      _selectedLocData = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create New Class',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'Course Name',
                    'e.g., Software Engineering',
                    _courseCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Meeting Number',
                          'e.g., 1',
                          _meetingCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('Date', 'YYYY-MM-DD', _dateCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Start Time',
                          '08.00',
                          _startCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('End Time', '10.00', _endCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLocationDropdown(),
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
              onPressed: () {
                if (_courseCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a course name')),
                  );
                  return;
                }
                if (_selectedLocData == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a location')),
                  );
                  return;
                }

                // Ambil data sebelum dialog di-pop
                final String courseName = _courseCtrl.text;
                final String meeting = _meetingCtrl.text;
                final String date = _dateCtrl.text;
                final String startTime = _startCtrl.text;
                final String endTime = _endCtrl.text;
                final Map<String, dynamic>? locData = _selectedLocData;

                // 1. Pop dialog SEGERA
                Navigator.pop(context);

                // 2. Jalankan di background
                _saveClassToFirestore(
                  courseName,
                  meeting,
                  date,
                  startTime,
                  endTime,
                  locData,
                  docId: docId,
                );

                // 3. Bersihkan form hanya jika bukan sedang update, atau bersihkan selalu
                _courseCtrl.clear();
                _meetingCtrl.clear();
                _dateCtrl.clear();
                _startCtrl.clear();
                _endCtrl.clear();
                setState(() => _selectedLocData = null);
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
                docId == null ? 'Publish Class' : 'Update Class',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveClassToFirestore(
    String courseName,
    String meeting,
    String date,
    String startTime,
    String endTime,
    Map<String, dynamic>? locData, {
    String? docId,
  }) async {
    try {
      final String jamStr = "$startTime - $endTime";

      final Map<String, dynamic> classData = {
        'kelas': courseName,
        'pertemuan': meeting,
        'tanggal': date,
        'jam': jamStr,
        'tempat': locData?['tempat'],
        'latitude': locData?['latitude'],
        'longitude': locData?['longitude'],
        'radius': locData?['radius'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (docId == null) {
        classData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('kelas').add(classData).timeout(const Duration(seconds: 15));
      } else {
        await _firestore.collection('kelas').doc(docId).update(classData).timeout(const Duration(seconds: 15));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Class schedule ${docId == null ? 'published' : 'updated'} successfully!'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish class: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('lokasi').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading locations: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const LinearProgressIndicator(color: Colors.black);
            }

            final locations = snapshot.data!.docs;
            if (locations.isEmpty) {
              return Text(
                'No locations found. Please add one in Fraud Detection.',
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              );
            }

            // Document ID of the selected location
            String? selectedId;
            if (_selectedLocData != null) {
              try {
                selectedId = locations
                    .firstWhere(
                      (d) =>
                          (d.data() as Map<String, dynamic>)['tempat'] ==
                          _selectedLocData!['tempat'],
                    )
                    .id;
              } catch (_) {}
            }

            return DropdownButtonFormField<String>(
              value: selectedId,
              decoration: InputDecoration(
                hintText: 'Select authorized location...',
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
              items: locations.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['tempat'] ?? 'Unnamed Location';
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(name, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final matched = locations.firstWhere((d) => d.id == id);
                setState(() {
                  _selectedLocData = matched.data() as Map<String, dynamic>;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Schedules',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create and organize classes before users can mark attendance.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showCreateClassDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Create New Class',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Table Card
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toolbar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 320,
                        height: 44,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search schedules...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_list,
                          size: 18,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Filters',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Data Table connected to Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('kelas')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading schedules: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try checking if an index is needed in Firestore console.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No classes scheduled yet.'),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: DataTable(
                          headingRowHeight: 56,
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 70,
                          headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.grey.shade50,
                          ),
                          horizontalMargin: 24,
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Course Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Meeting',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Schedule',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
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
                                    data['kelas'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      data['pertemuan']?.toString() ?? '1',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['tanggal'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        data['jam'] ?? '-',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['tempat'] ?? '-',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () => _showCreateClassDialog(docId: doc.id, existingData: data),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _confirmDeleteClass(doc.id, data['kelas'] ?? 'this class'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  void _confirmDeleteClass(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Delete schedule for $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _firestore.collection('kelas').doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
