import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dialog for assigning a driver to a shipment
class AssignDriverDialog extends StatefulWidget {
  final String shipmentId;
  final String? currentDriverId;

  const AssignDriverDialog({
    super.key,
    required this.shipmentId,
    this.currentDriverId,
  });

  @override
  State<AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<AssignDriverDialog> {
  List<Map<String, dynamic>> _drivers = [];
  String? _selectedDriverId;
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDriverId = widget.currentDriverId;
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      // Get all users with role_id = 3 (Driver)
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, phone, vehicle_type, vehicle_plate')
          .eq('role_id', 3)
          .eq('is_active', true)
          .order('full_name');

      setState(() {
        _drivers = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load drivers: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _assignDriver() async {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a driver')));
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      // Update shipment with driver_id and change status to 'assigned'
      await Supabase.instance.client
          .from('shipments')
          .update({
            'driver_id': _selectedDriverId,
            'status': 'assigned',
            'assigned_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.shipmentId);

      // Add timeline update
      await Supabase.instance.client.from('shipment_timeline').insert({
        'shipment_id': widget.shipmentId,
        'status': 'assigned',
        'message': 'Driver assigned to shipment',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      Navigator.of(context).pop(true); // Return true to indicate success

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Driver assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to assign driver: $e';
        _isAssigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Driver'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      _loadDrivers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : _drivers.isEmpty
            ? const Text('No available drivers found')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a driver to assign to this shipment:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(maxHeight: 300.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _drivers.length,
                      itemBuilder: (context, index) {
                        final driver = _drivers[index];
                        final isSelected = driver['id'] == _selectedDriverId;

                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          color: isSelected
                              ? Colors.green.shade50
                              : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                            title: Text(
                              driver['full_name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (driver['phone'] != null)
                                  Text('📞 ${driver['phone']}'),
                                if (driver['vehicle_type'] != null)
                                  Text(
                                    '🚚 ${driver['vehicle_type']} - ${driver['vehicle_plate'] ?? 'N/A'}',
                                  ),
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedDriverId = driver['id'];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isAssigning ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isAssigning || _selectedDriverId == null
              ? null
              : _assignDriver,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: _isAssigning
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Assign Driver'),
        ),
      ],
    );
  }
}
