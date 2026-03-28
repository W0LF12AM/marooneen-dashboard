import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentView extends StatefulWidget {
  const StudentView({super.key});

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Pagination state
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola profil mahasiswa, informasi akademik, dan detail pendaftaran.',
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
                  child: _buildHeader(),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildStudentTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                _currentPage = 0; // Reset pagination on search
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, NPM, or jurusan...',
              hintStyle: const TextStyle(
                color: Color(0xFF585857),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF585857),
                size: 20,
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
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddEditStudentDialog(context),
          icon: const Icon(Icons.person_add_alt_1, size: 20),
          label: const Text(
            'Add Student',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final npm = (data['npm'] ?? '').toString().toLowerCase();
            final jurusan = (data['jurusan'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                npm.contains(_searchQuery) ||
                jurusan.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(
              child: Text(
                'No students found.',
                style: TextStyle(color: Color(0xFF585857)),
              ),
            ),
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
                  dataRowMaxHeight: 76,
                  dataRowMinHeight: 76,
                  columns: const [
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
                        'JURUSAN / KELAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585857),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585857),
                        ),
                      ),
                    ),
                  ],
                  rows: pagedDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown Student';
                    final npm = data['npm'] ?? '-';
                    final jurusan = data['jurusan'] ?? '-';
                    final kelas = data['kelas'] ?? '-';

                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF232222),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            npm,
                            style: const TextStyle(color: Color(0xFF585857)),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                jurusan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              _buildKelasBadge(kelas),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: Color(0xFF585857),
                                ),
                                onPressed: () =>
                                    _showProfileModal(context, data, doc.id),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () =>
                                    _showAddEditStudentDialog(context, docId: doc.id, existingData: data),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _confirmDeleteStudent(doc.id, name),
                              ),
                            ],
                          ),
                        ),
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
                    onPressed: (_currentPage + 1) * _rowsPerPage < docs.length
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

  Widget _buildKelasBadge(String kelas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        kelas,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showProfileModal(
    BuildContext context,
    Map<String, dynamic> userData,
    String docId,
  ) {
    final name = userData['name'] ?? 'Unknown Student';
    final npm = userData['npm'] ?? '-';
    final fakultas = userData['fakultas'] ?? '-';
    final jurusan = userData['jurusan'] ?? '-';
    final kelas = userData['kelas'] ?? '-';
    final phone = userData['phone'] ?? '-';
    final gender = userData['gender'] ?? '-';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
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
                    const Text(
                      'Student Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.black,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          npm,
                          style: const TextStyle(color: Color(0xFF585857)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _infoItem('Fakultas', fakultas),
                _infoItem('Jurusan', jurusan),
                _infoItem('Kelas', kelas),
                _infoItem('Phone', phone),
                _infoItem('Gender', gender),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
                _buildFaceStatusRow(userData['faceEmbedding'] != null),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceStatusRow(bool isRegistered) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Facial Data Status',
          style: TextStyle(
            color: Color(0xFF585857),
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isRegistered ? Colors.black : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRegistered ? Icons.verified : Icons.error_outline,
                color: isRegistered ? Colors.white : const Color(0xFFB91C1C),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                isRegistered ? 'REGISTERED' : 'NOT REGISTERED',
                style: TextStyle(
                  color: isRegistered ? Colors.white : const Color(0xFFB91C1C),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteStudent(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(docId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEditStudentDialog(BuildContext context, {String? docId, Map<String, dynamic>? existingData}) {
    final nameCtrl = TextEditingController(text: existingData?['name']);
    final npmCtrl = TextEditingController(text: existingData?['npm']);
    final jurusanCtrl = TextEditingController(text: existingData?['jurusan']);
    final kelasCtrl = TextEditingController(text: existingData?['kelas']);
    final fakultasCtrl = TextEditingController(text: existingData?['fakultas']);
    final phoneCtrl = TextEditingController(text: existingData?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add New Student' : 'Edit Student'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormInput('Full Name', nameCtrl),
                _buildFormInput('NPM', npmCtrl),
                _buildFormInput('Fakultas', fakultasCtrl),
                _buildFormInput('Jurusan', jurusanCtrl),
                _buildFormInput('Kelas', kelasCtrl),
                _buildFormInput('Phone', phoneCtrl),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              final data = {
                'name': nameCtrl.text,
                'npm': npmCtrl.text,
                'fakultas': fakultasCtrl.text,
                'jurusan': jurusanCtrl.text,
                'kelas': kelasCtrl.text,
                'phone': phoneCtrl.text,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              if (docId == null) {
                data['createdAt'] = FieldValue.serverTimestamp();
                await FirebaseFirestore.instance.collection('users').add(data);
              } else {
                await FirebaseFirestore.instance.collection('users').doc(docId).update(data);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(docId == null ? 'Add Student' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF585857),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
