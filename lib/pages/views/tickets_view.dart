import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TicketsView extends StatefulWidget {
  const TicketsView({super.key});

  @override
  State<TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<TicketsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support Tickets',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kelola permintaan bantuan dan perbaikan data dari mahasiswa secara real-time.',
          style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
        ),
        const SizedBox(height: 32),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1A232222)),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                Expanded(child: _buildTicketsList()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('MAHASISWA', style: _headerStyle)),
          Expanded(flex: 3, child: Text('MASALAH / DESKRIPSI', style: _headerStyle)),
          Expanded(flex: 1, child: Text('STATUS', style: _headerStyle)),
          Expanded(flex: 1, child: Text('TANGGAL', style: _headerStyle)),
          SizedBox(width: 48), // Space for action button
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF585857),
    letterSpacing: 0.5,
  );

  Widget _buildTicketsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tickets')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada tiket bantuan masuk.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final ticketId = docs[index].id;
            return _buildTicketRow(ticketId, data);
          },
        );
      },
    );
  }

  Widget _buildTicketRow(String id, Map<String, dynamic> data) {
    final name = data['userName'] ?? 'Unknown';
    final npm = data['userNpm'] ?? '-';
    final subject = data['subject'] ?? 'No Subject';
    final description = data['description'] ?? '-';
    final status = data['status'] ?? 'open';
    
    String dateStr = '-';
    if (data['timestamp'] != null) {
      try {
        dateStr = DateFormat('dd/MM/yy').format((data['timestamp'] as Timestamp).toDate());
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(npm, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(status),
          ),
          Expanded(
            flex: 1,
            child: Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
            onPressed: () => _viewTicketDetails(id, data),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    status = status.toLowerCase();
    Color bgColor = const Color(0xFFF4F4F4);
    Color fgColor = const Color(0xFF585857);

    if (status == 'open') {
      bgColor = const Color(0xFFFEE2E2);
      fgColor = const Color(0xFFB91C1C);
    } else if (status == 'pending') {
      bgColor = const Color(0xFFFEF3C7);
      fgColor = const Color(0xFF92400E);
    } else if (status == 'resolved') {
      bgColor = Colors.black;
      fgColor = Colors.white;
    }

    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: fgColor,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _viewTicketDetails(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        String currentStatus = data['status'] ?? 'open';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ticket Detail', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Mahasiswa', '${data['userName']} (${data['userNpm']})'),
                const SizedBox(height: 16),
                _detailRow('Subjek', data['subject'] ?? ''),
                const SizedBox(height: 16),
                _detailRow('Deskripsi', data['description'] ?? ''),
                const SizedBox(height: 24),
                const Text('UPDATE STATUS', style: _headerStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusChip(id, 'open', currentStatus, data),
                    const SizedBox(width: 8),
                    _statusChip(id, 'pending', currentStatus, data),
                    const SizedBox(width: 8),
                    _statusChip(id, 'resolved', currentStatus, data),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _headerStyle),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }

  Widget _statusChip(String id, String status, String current, Map<String, dynamic> data) {
    bool isSelected = status == current;
    return InkWell(
      onTap: () async {
        await _firestore.collection('tickets').doc(id).update({'status': status});

        // Add notification to student app if resolved
        if (status == 'resolved') {
          await _firestore.collection('notifications').add({
            'userNpm': data['userNpm'],
            'title': 'Ticket Resolved',
            'message': 'Tiket Anda mengenai "${data['subject']}" telah diselesaikan!',
            'type': 'ticket_resolution',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status ticket diperbarui ke ${status.toUpperCase()}'),
              backgroundColor: Colors.black,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: isSelected ? Colors.black : Colors.black12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
