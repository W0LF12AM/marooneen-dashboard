import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _reportType = 'Attendance Log';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isExporting = false;

  // Pagination state
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics & Reports',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analisis data kehadiran, pantau anomali geofence, dan ekspor laporan tabular.',
            style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildReportConfigPanel()),
              const SizedBox(width: 24),
              Expanded(flex: 7, child: _buildReportPreviewData()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportConfigPanel() {
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
            'Report Parameters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'REPORT TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFF9F9F9),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _reportType,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF585857),
                ),
                items:
                    [
                      'Attendance Log',
                      'Fraud Violations',
                      'Pindah Kelas',
                      'Device Mapping',
                    ].map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text(
                          v,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    _reportType = v!;
                    _currentPage = 0; // Reset pagination on type change
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'ROWS PER PAGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFF9F9F9),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                isExpanded: true,
                items: [10, 25, 50, 100].map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text(
                      '$v Rows',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _rowsPerPage = v!),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE0E0E0)),
          const SizedBox(height: 32),

          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : () => _exportToCSV(),
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.table_chart,
                      color: Colors.white,
                      size: 18,
                    ),
              label: const Text(
                'Export to CSV',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isExporting ? null : () => _exportToExcel(),
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(
                      Icons.file_download,
                      color: Colors.black,
                      size: 18,
                    ),
              label: const Text(
                'Export to Excel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPreviewData() {
    return Container(
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
                Text(
                  'Preview: $_reportType',
                  style: const TextStyle(
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
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF585857),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExporting)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFF4F4F4),
              color: Colors.black,
              minHeight: 2,
            ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          _buildDynamicTable(),
        ],
      ),
    );
  }

  Widget _buildDynamicTable() {
    Query query;
    List<DataColumn> columns;
    List<DataRow> Function(List<QueryDocumentSnapshot>) rowMapper;

    if (_reportType == 'Device Mapping') {
      query = _firestore.collection('users').orderBy('name');
      columns = const [
        DataColumn(
          label: Text(
            'STUDENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'NPM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'DEVICE ID',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'DEVICE NAME',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
            ),
          ),
        ),
      ];
      rowMapper = (docs) {
        return docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DataRow(
            cells: [
              DataCell(
                Text(
                  data['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              DataCell(Text(data['npm'] ?? '-')),
              DataCell(
                Text(
                  data['deviceId'] ?? 'Unbound',
                  style: TextStyle(
                    color: data['deviceId'] == null
                        ? Colors.red
                        : const Color(0xFF585857),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(Text(data['deviceName'] ?? 'Unknown')),
            ],
          );
        }).toList();
      };
    } else if (_reportType == 'Fraud Violations') {
      // fraud_logs based report
      query = _firestore
          .collection('fraud_logs')
          .orderBy('timestamp', descending: true);
      columns = const [
        DataColumn(
          label: Text(
            'STUDENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
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
            ),
          ),
        ),
      ];
      rowMapper = (docs) {
        return docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String dateStr = '-';
          if (data['timestamp'] != null) {
            try {
              dateStr = DateFormat(
                'dd/MM/yy HH:mm',
              ).format((data['timestamp'] as Timestamp).toDate());
            } catch (_) {}
          }
          final fType = data['fraudType'] ?? 'unknown';
          return DataRow(
            cells: [
              DataCell(
                Text(
                  data['userName'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              DataCell(Text(data['className'] ?? '-')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fType.toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(Text(dateStr)),
            ],
          );
        }).toList();
      };
    } else {
      // presensi-based reports
      var baseQuery = _firestore
          .collection('presensi')
          .orderBy('timestamp', descending: true);

      if (_reportType == 'Pindah Kelas') {
        baseQuery = baseQuery.where('status', isEqualTo: 'Pindah Kelas');
      }

      query = baseQuery;
      columns = const [
        DataColumn(
          label: Text(
            'STUDENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
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
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'STATUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'KETERANGAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
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
            ),
          ),
        ),
      ];
      rowMapper = (docs) {
        return docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String dateStr = '-';
          if (data['timestamp'] != null) {
            try {
              dateStr = DateFormat(
                'dd/MM/yy HH:mm',
              ).format((data['timestamp'] as Timestamp).toDate());
            } catch (_) {}
          }
          return DataRow(
            cells: [
              DataCell(
                Text(
                  data['userName'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              DataCell(Text(data['className'] ?? '-')),
              DataCell(_buildStatusBadge(data['status'] ?? '-')),
              DataCell(Text(data['keterangan'] ?? '-')),
              DataCell(Text(dateStr)),
            ],
          );
        }).toList();
      };
    }

    return StreamBuilder<QuerySnapshot>(
      // Simple offset-based pagination isn't natively supported well in Firestore-StreamBuilder
      // We'll use limit and startAfter for true pagination, but for now we'll do real-time limit
      stream: query.limit(_rowsPerPage * (_currentPage + 1)).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(64.0),
            child: Center(
              child: SelectableText(
                'Terjadi kesalahan saat memuat data: \n${snapshot.error}\n\n'
                '(Jika pesan error mengandung link, copy-paste link tersebut ke browser untuk membuat Index Firestore yang dibutuhkan)',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final allDocs = snapshot.data?.docs ?? [];
        // Extract the current page docs
        final startIdx = _currentPage * _rowsPerPage;
        final docs = allDocs.length > startIdx
            ? allDocs.sublist(
                startIdx,
                (startIdx + _rowsPerPage).clamp(0, allDocs.length),
              )
            : <QueryDocumentSnapshot>[];

        if (docs.isEmpty && allDocs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(child: Text('Belum ada data untuk ditampilkan.')),
          );
        }

        return Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: const Color(0xFFE0E0E0),
                dataTableTheme: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFFBFBFB),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  horizontalMargin: 24,
                  columnSpacing: 24,
                  headingRowHeight: 56,
                  columns: columns,
                  rows: rowMapper(docs),
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
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Page ${_currentPage + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed:
                        allDocs.length >
                            (_currentPage * _rowsPerPage) + docs.length
                        ? () => setState(() => _currentPage++)
                        : null,
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
    } else if (status == 'pindah kelas') {
      bgColor = const Color(0xFFE0E7FF);
      fgColor = const Color(0xFF4338CA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fgColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);
    try {
      final List<List<dynamic>> rows = await _getDataForExport();
      String csvString = csv.encode(rows);

      final bytes = Uint8List.fromList(utf8.encode(csvString));
      final fileName =
          '${_reportType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV Exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final List<List<dynamic>> rows = await _getDataForExport();
      var excel = excel_lib.Excel.createExcel();
      var sheet =
          excel['${_reportType.substring(0, (_reportType.length > 30 ? 30 : _reportType.length))}'];

      for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        for (var colIndex = 0; colIndex < rows[rowIndex].length; colIndex++) {
          sheet
              .cell(
                excel_lib.CellIndex.indexByColumnRow(
                  columnIndex: colIndex,
                  rowIndex: rowIndex,
                ),
              )
              .value = excel_lib.TextCellValue(
            rows[rowIndex][colIndex].toString(),
          );
        }
      }

      final bytes = excel.save();
      if (bytes != null) {
        final fileName =
            '${_reportType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(bytes),
          fileExtension: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel Exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<List<List<dynamic>>> _getDataForExport() async {
    List<List<dynamic>> rows = [];

    if (_reportType == 'Device Mapping') {
      rows.add(['STUDENT', 'NPM', 'DEVICE ID', 'DEVICE NAME']);
      final snapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        rows.add([
          data['name'] ?? 'Unknown',
          data['npm'] ?? '-',
          data['deviceId'] ?? 'Unbound',
          data['deviceName'] ?? 'Unknown',
        ]);
      }
    } else if (_reportType == 'Fraud Violations') {
      rows.add(['STUDENT', 'CLASS', 'FRAUD TYPE', 'DESCRIPTION', 'TIMESTAMP']);
      final snapshot = await _firestore
          .collection('fraud_logs')
          .orderBy('timestamp', descending: true)
          .get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        String dateStr = '-';
        if (data['timestamp'] != null) {
          try {
            dateStr = DateFormat(
              'dd/MM/yy HH:mm',
            ).format((data['timestamp'] as Timestamp).toDate());
          } catch (_) {}
        }
        rows.add([
          data['userName'] ?? 'Unknown',
          data['className'] ?? '-',
          data['fraudType'] ?? 'unknown',
          data['description'] ?? '-',
          dateStr,
        ]);
      }
    } else {
      rows.add(['STUDENT', 'CLASS', 'STATUS', 'KETERANGAN', 'TIMESTAMP']);
      var baseQuery = _firestore
          .collection('presensi')
          .orderBy('timestamp', descending: true);

      if (_reportType == 'Pindah Kelas') {
        baseQuery = baseQuery.where('status', isEqualTo: 'Pindah Kelas');
      }

      final snapshot = await baseQuery.get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        String dateStr = '-';
        if (data['timestamp'] != null) {
          try {
            dateStr = DateFormat(
              'dd/MM/yy HH:mm',
            ).format((data['timestamp'] as Timestamp).toDate());
          } catch (_) {}
        }
        rows.add([
          data['userName'] ?? 'Unknown',
          data['className'] ?? '-',
          data['status'] ?? '-',
          data['keterangan'] ?? '-',
          dateStr,
        ]);
      }
    }
    return rows;
  }
}
