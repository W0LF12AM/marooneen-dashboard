import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _statusFilter = 'All';

  // Pagination state
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentPage = 0;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDate = null;
      _statusFilter = 'All';
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor absensi mahasiswa, filter data, dan lakukan penyesuaian manual jika diperlukan.',
            style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
          ),
          const SizedBox(height: 32),
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
                  child: _buildFiltersHeader(),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildAttendanceTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    _currentPage = 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search name or NPM...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF585857),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF585857),
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedDate == null ? const Color(0xFFF9F9F9) : Colors.black,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: _selectedDate == null ? const Color(0xFF585857) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedDate == null ? const Color(0xFF585857) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF9F9F9),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  items: ['All', 'Hadir', 'Izin', 'Sakit', 'Alpa'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _statusFilter = newValue!;
                      _currentPage = 0;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchQuery.isNotEmpty || _selectedDate != null || _statusFilter != 'All')
              TextButton(
                onPressed: _clearFilters,
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF585857)),
                child: const Text('Clear Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(width: 8),
            const Text('Show:', style: TextStyle(fontSize: 13, color: Color(0xFF585857))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFFF9F9F9),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [10, 25, 50].map((v) {
                    return DropdownMenuItem(
                      value: v,
                      child: Text('$v', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _rowsPerPage = v!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('presensi').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (_searchQuery.isNotEmpty) {
            final name = (data['userName'] ?? '').toString().toLowerCase();
            final npm = (data['userNpm'] ?? '').toString().toLowerCase();
            if (!name.contains(_searchQuery) && !npm.contains(_searchQuery)) return false;
          }
          if (_statusFilter != 'All') {
            final status = (data['status'] ?? '').toString().toLowerCase();
            if (status != _statusFilter.toLowerCase()) return false;
          }
          if (_selectedDate != null && data['timestamp'] != null) {
            try {
              final date = (data['timestamp'] as Timestamp).toDate();
              if (date.year != _selectedDate!.year || date.month != _selectedDate!.month || date.day != _selectedDate!.day) return false;
            } catch (_) {}
          }
          return true;
        }).toList();

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(child: Text('No attendance records found.', style: TextStyle(color: Color(0xFF585857)))),
          );
        }

        // Pagination
        final startIdx = _currentPage * _rowsPerPage;
        if (startIdx >= docs.length) {
          Future.microtask(() => setState(() => _currentPage = 0));
          return const SizedBox.shrink();
        }

        final pagedDocs = docs.sublist(
          startIdx,
          (startIdx + _rowsPerPage).clamp(0, docs.length),
        );

        return Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: const Color(0xFFE0E0E0),
                dataTableTheme: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  horizontalMargin: 24,
                  columnSpacing: 24,
                  headingRowHeight: 56,
                  dataRowMaxHeight: 76,
                  dataRowMinHeight: 76,
                  columns: const [
                    DataColumn(label: Text('EMPLOYEE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF585857)))),
                    DataColumn(label: Text('CLASS / LOC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF585857)))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF585857)))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF585857)))),
                  ],
                  rows: pagedDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String timeStr = '-';
                    if (data['timestamp'] != null) {
                      try {
                        timeStr = DateFormat('dd/MM HH:mm').format((data['timestamp'] as Timestamp).toDate());
                      } catch (_) {}
                    }
                    return DataRow(
                      cells: [
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data['userName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                            Text(data['userNpm'] ?? '-', style: const TextStyle(color: Color(0xFF585857), fontSize: 11)),
                          ],
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data['className'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(timeStr, style: const TextStyle(color: Color(0xFF585857), fontSize: 11)),
                          ],
                        )),
                        DataCell(_buildStatusBadge(data['status'] ?? 'Hadir')),
                        DataCell(InkWell(
                          onTap: () => _openManualAdjustmentModal(context, data, doc.id),
                          child: const Text('Adjust', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline)),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                    icon: const Icon(Icons.chevron_left, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text('Page ${_currentPage + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: (_currentPage + 1) * _rowsPerPage < docs.length ? () => setState(() => _currentPage++) : null,
                    icon: const Icon(Icons.chevron_right, size: 20),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    status = status.toLowerCase();
    Color bgColor = const Color(0xFFF4F4F4);
    Color fgColor = const Color(0xFF585857);
    if (status == 'hadir') {
      bgColor = Colors.black;
      fgColor = Colors.white;
    } else if (status == 'alpa') {
      bgColor = const Color(0xFFFEE2E2);
      fgColor = const Color(0xFFB91C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: fgColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _openManualAdjustmentModal(BuildContext context, Map<String, dynamic> record, String docId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _ManualAdjustmentModal(recordData: record, docId: docId),
    );
  }
}

class _ManualAdjustmentModal extends StatefulWidget {
  final Map<String, dynamic> recordData;
  final String docId;
  const _ManualAdjustmentModal({required this.recordData, required this.docId});

  @override
  State<_ManualAdjustmentModal> createState() => _ManualAdjustmentModalState();
}

class _ManualAdjustmentModalState extends State<_ManualAdjustmentModal> {
  late String _selectedStatus;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    String existingStatus = widget.recordData['status'] ?? 'Hadir';
    _selectedStatus = existingStatus.isNotEmpty ? existingStatus[0].toUpperCase() + existingStatus.substring(1).toLowerCase() : 'Hadir';
    _notesController.text = widget.recordData['notes'] ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adjust Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Mahasiswa: ${widget.recordData['userName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('STATUS', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: ['Hadir', 'Izin', 'Sakit', 'Alpa'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('REASON / NOTES', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Provide a reason...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAdjustment,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAdjustment() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('presensi').doc(widget.docId).update({
        'status': _selectedStatus.toLowerCase(),
        'notes': _notesController.text,
        'adjustedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
