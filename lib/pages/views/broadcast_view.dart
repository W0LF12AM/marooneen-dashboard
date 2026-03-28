import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastView extends StatefulWidget {
  const BroadcastView({super.key});

  @override
  State<BroadcastView> createState() => _BroadcastViewState();
}

class _BroadcastViewState extends State<BroadcastView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _audienceFilter = 'All Active Users';

  bool _isSending = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await _firestore.collection('broadcasts').add({
        'title': _titleController.text,
        'message': _messageController.text,
        'target': _audienceFilter,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': 'Admin Marooneen',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Broadcast sent successfully!'),
            backgroundColor: Colors.black,
          ),
        );
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Broadcast',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compose and push real-time alerts or announcements to specific audience groups.',
            style: TextStyle(fontSize: 14, color: Color(0xFF585857)),
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x1A232222)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compose Message',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'TARGET AUDIENCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585857),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFF9F9F9),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _audienceFilter,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF585857),
                            ),
                            items:
                                [
                                  'All Active Users',
                                  'Specific Informatics',
                                  'Managers',
                                  'Specific Department',
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
                            onChanged: _isSending
                                ? null
                                : (v) => setState(() => _audienceFilter = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'NOTIFICATION TITLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585857),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        enabled: !_isSending,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDeco(
                          'e.g., Important System Maintenance',
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'DETAILED MESSAGE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585857),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _messageController,
                        enabled: !_isSending,
                        onChanged: (_) => setState(() {}),
                        maxLines: 6,
                        decoration: _inputDeco(
                          'Type the full broadcast message here...',
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendBroadcast,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            _isSending ? 'Sending...' : 'Send Broadcast',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: _buildDevicePreview()),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF585857), fontSize: 14),
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
    );
  }

  Widget _buildDevicePreview() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'DEVICE PREVIEW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF585857),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0D000000),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Administration',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF585857),
                            ),
                          ),
                          const Text(
                            'now',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF585857),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _titleController.text.isEmpty
                            ? 'Notification Title'
                            : _titleController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _messageController.text.isEmpty
                            ? 'This is how your broadcast message will appear to the selected recipients on their mobile devices.'
                            : _messageController.text,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
