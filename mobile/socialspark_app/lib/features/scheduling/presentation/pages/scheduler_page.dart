import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'package:socialspark_app/features/library/data/library_data_service.dart';

class SchedulerPage extends StatefulWidget {
  final dynamic item;
  final int? index;
  
  const SchedulerPage({
    Key? key,
    this.item,
    this.index,
  }) : super(key: key);

  @override
  _SchedulerPageState createState() => _SchedulerPageState();
  
  String get _contentPath => item?['image'] ?? '';
  String get _caption => item?['description'] ?? '';
  String get _platform => item?['platform']?.toLowerCase() ?? 'all';
  int get itemIndex => index ?? -1;
}


class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _isScheduling = false; // To differentiate between post now and schedule

  void _postNow() {
    setState(() {
      _isLoading = true;
      _isScheduling = false;
    });
    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content shared successfully!')),
        );
      }
    });
  }

  Future<void> _schedulePost() async {
    setState(() {
      _isLoading = true;
      _isScheduling = true;
    });
    final scheduledTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    LibraryDataService.updateStatus(widget.itemIndex, 'scheduled');

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post scheduled for ${scheduledTime.toString()}')),
      );
      context.go('/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0, // Set to the appropriate index for this page
      // showBottomNav: false, // Hide the main bottom nav
      child: Column(
        children: [
          // Custom app bar
          Container(
            color: const Color(0xFF0F2137),
            padding:
                const EdgeInsets.only(top: 40, bottom: 12, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Schedule Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Preview Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: widget._contentPath.isNotEmpty
                              ? Image.asset(
                                  widget._contentPath,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Container(
                                    height: 200,
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.image,
                                        size: 50, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.image,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('No media selected',
                                            style: TextStyle(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Post Details',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              // Date and Time Picker Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateTimePicker(
                                      context,
                                      icon: Icons.calendar_today_outlined,
                                      value: "${_scheduledDate.toLocal()}"
                                          .split(' ')[0],
                                      label: 'Date',
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _scheduledDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null && mounted) {
                                          setState(
                                              () => _scheduledDate = date);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDateTimePicker(
                                      context,
                                      icon: Icons.access_time_rounded,
                                      value: _scheduledTime.format(context),
                                      label: 'Time',
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _scheduledTime,
                                        );
                                        if (time != null && mounted) {
                                          setState(
                                              () => _scheduledTime = time);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.save_alt_rounded,
                          label: 'Save as Draft',
                          color: const Color(0xFF4CAF50),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved as draft')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.send_rounded,
                          label: 'Post Now',
                          color: const Color(0xFF2196F3),
                          onPressed: _isLoading ? null : _postNow,
                          isLoading: _isLoading && !_isScheduling,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context,
                      icon: Icons.schedule_rounded,
                      label: 'Schedule The Post',
                      color: const Color(0xFF0F2137),
                      onPressed: _isLoading ? null : _schedulePost,
                      isFullWidth: true,
                      isLoading: _isLoading && _isScheduling,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0F2137)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F2137),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Icon(icon, size: 20),
          if (!isLoading) const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
