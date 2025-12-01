import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointments/time_slot_picker.dart';
import 'booking_confirmation_screen.dart';

class TimeSlotSelectionScreen extends StatefulWidget {

  const TimeSlotSelectionScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
  });
  final String doctorId;
  final String doctorName;
  final String specialty;

  @override
  _TimeSlotSelectionScreenState createState() => _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  String _selectedType = 'telehealth';
  String _reasonForVisit = '';
  String _chiefComplaint = '';
  bool _urgent = false;
  bool _isLoading = false;

  final List<Map<String, String>> _appointmentTypes = [
    {'value': 'telehealth', 'label': 'Telehealth'},
    {'value': 'in_person', 'label': 'In-Person'},
    {'value': 'phone', 'label': 'Phone Call'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchAvailableSlots(widget.doctorId, _selectedDate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading time slots: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
      _loadTimeSlots();
    }
  }

  void _proceedToConfirmation() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    if (_reasonForVisit.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for visit')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          specialty: widget.specialty,
          appointmentType: _selectedType,
          selectedDate: _selectedDate,
          selectedSlot: _selectedSlot!,
          reasonForVisit: _reasonForVisit,
          chiefComplaint: _chiefComplaint,
          urgent: _urgent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.doctorName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.specialty,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appointment Type Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _appointmentTypes.map((type) {
                      final isSelected = _selectedType == type['value'];
                      return ChoiceChip(
                        label: Text(type['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type['value']!);
                          }
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Time Slot Picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading) const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ) else Consumer<AppointmentProvider>(
                          builder: (context, provider, child) {
                            final slots = provider.availableSlots;
                            if (slots.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(32),
                                child: const Center(
                                  child: Text(
                                    'No available slots for this date',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return TimeSlotPicker(
                              slots: slots,
                              selectedSlot: _selectedSlot,
                              onSlotSelected: (slot) {
                                setState(() => _selectedSlot = slot);
                              },
                            );
                          },
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visit Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Reason for Visit *',
                      hintText: 'e.g., Annual checkup, Follow-up',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (value) => _reasonForVisit = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Chief Complaint (Optional)',
                      hintText: 'Describe your main symptoms or concerns',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _chiefComplaint = value,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Urgent appointment'),
                    subtitle: const Text('Check if this is an urgent matter'),
                    value: _urgent,
                    onChanged: (value) {
                      setState(() => _urgent = value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _proceedToConfirmation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue to Confirmation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
}
