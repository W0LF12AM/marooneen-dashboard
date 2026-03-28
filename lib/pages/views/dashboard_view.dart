import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _totalUsers = 0;
  int _totalKelas = 0;
  int _totalLokasi = 0;
  int _presensiToday = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final usersQuery = await _firestore.collection('users').count().get();
      _totalUsers = usersQuery.count ?? 0;

      final kelasQuery = await _firestore.collection('kelas').count().get();
      _totalKelas = kelasQuery.count ?? 0;

      final lokasiQuery = await _firestore.collection('lokasi').count().get();
      _totalLokasi = lokasiQuery.count ?? 0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final presensiQuery = await _firestore
          .collection('presensi')
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .count()
          .get();
      _presensiToday = presensiQuery.count ?? 0;
    } catch (e) {
      debugPrint("Error loading stats: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // --- STATISTIC CARDS (Black & White Theme) ---
          Row(
            children: [
              _buildStatCard(
                'Total Mahasiswa',
                _isLoadingStats ? '...' : '$_totalUsers',
                Icons.people,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Total Kelas Aktif',
                _isLoadingStats ? '...' : '$_totalKelas',
                Icons.class_,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Presensi Hari Ini',
                _isLoadingStats ? '...' : '$_presensiToday',
                Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Titik Lokasi',
                _isLoadingStats ? '...' : '$_totalLokasi',
                Icons.location_on_outlined,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // --- RECENT PRESENSI & KELAS INFO ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List Presensi Terbaru
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Feed Presensi Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLiveFeedStream(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Widget info tambahan
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kelas Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TOTAL: $_totalKelas',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Daftar kelas aktif yang sedang berjalan.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      _buildTodayClassesStream(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeedStream() {
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
          return const Text('Terjadi kesalahan memuat data.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('Belum ada data presensi.');
        }

        final docs = snapshot.data!.docs;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.black12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['userName'] ?? 'Unknown';
            final npm = data['userNpm'] ?? '-';
            final kelas = data['className'] ?? '-';
            final status = data['status'] ?? '-';

            String timeStr = '-';
            if (data['timestamp'] != null) {
              try {
                final dt = (data['timestamp'] as Timestamp).toDate();
                timeStr = DateFormat('hh:mm a').format(dt);
              } catch (e) {
                timeStr = '-';
              }
            }

            return _buildRecentPresensiItem(name, npm, kelas, timeStr, status);
          },
        );
      },
    );
  }

  Widget _buildTodayClassesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('kelas').limit(5).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Text('Terjadi kesalahan memuat kelas.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.black12,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada jadwal kelas.',
                style: TextStyle(color: Colors.black38, fontSize: 13),
              ),
            ],
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final namaKelas = data['kelas'] ?? 'Unknown Class';
            final pertemuan = data['pertemuan'] ?? '-';
            final jam = data['jam'] ?? '00:00 - 00:00';

            return _buildClassItem(namaKelas, pertemuan, jam);
          },
        );
      },
    );
  }

  Widget _buildClassItem(String name, dynamic pertemuan, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              'Ke-$pertemuan',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black, // Dark background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPresensiItem(
    String name,
    String npm,
    String kelas,
    String time,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '$npm • $kelas',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'hadir'
                      ? Colors.black
                      : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status.toLowerCase() == 'hadir'
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
