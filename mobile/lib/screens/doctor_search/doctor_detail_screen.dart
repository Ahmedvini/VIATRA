import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';
import '../appointments/time_slot_selection_screen.dart';

class DoctorDetailScreen extends StatefulWidget {

  const DoctorDetailScreen({
    super.key,
    required this.doctorId,
  });
  final String doctorId;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late DoctorService _doctorService;
  Doctor? _doctor;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _doctorService = DoctorService(context.read());
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _doctorService.getDoctorById(widget.doctorId);
      
      if (response.success && response.data != null) {
        setState(() {
          _doctor = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load doctor details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Doctor not found',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchDoctorDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final doctor = _doctor!;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.displayName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Hero(
                    tag: 'doctor_${doctor.id}',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: doctor.profileImage != null
                          ? NetworkImage(doctor.profileImage!)
                          : null,
                      child: doctor.profileImage == null
                          ? Text(
                              _getInitials(doctor.fullName),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        doctor.displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.specialty,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (doctor.subSpecialty != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.subSpecialty!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Rating and experience
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (doctor.rating != null) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating!.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium,
                        ),
                        if (doctor.totalReviews != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor.totalReviews} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(width: 16),
                      ],
                      if (doctor.yearsOfExperience != null) ...[
                        const Icon(Icons.work_outline, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.yearsOfExperience} years',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Consultation fee
                  if (doctor.consultationFee != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Consultation: ${doctor.formattedFee}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // About section
            if (doctor.bio != null)
              _buildSection(
                context,
                title: 'About',
                icon: Icons.person_outline,
                child: Text(doctor.bio!),
              ),
            
            // Education
            if (doctor.education != null)
              _buildSection(
                context,
                title: 'Education',
                icon: Icons.school_outlined,
                child: Text(doctor.education!),
              ),
            
            // Certifications
            if (doctor.certifications != null && doctor.certifications!.isNotEmpty)
              _buildSection(
                context,
                title: 'Certifications',
                icon: Icons.card_membership,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: doctor.certifications!
                      .map((cert) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(cert)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            
            // Languages
            if (doctor.languagesSpoken != null && doctor.languagesSpoken!.isNotEmpty)
              _buildSection(
                context,
                title: 'Languages Spoken',
                icon: Icons.language,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: doctor.languagesSpoken!
                      .map((lang) => Chip(
                            label: Text(lang),
                            backgroundColor:
                                theme.colorScheme.primaryContainer.withOpacity(0.3),
                          ))
                      .toList(),
                ),
              ),
            
            // Office Information
            _buildSection(
              context,
              title: 'Office Information',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (doctor.officeAddressLine1 != null) ...[
                    _buildInfoRow(Icons.home, doctor.officeAddressLine1!),
                    const SizedBox(height: 8),
                  ],
                  if (doctor.officeAddressLine2 != null) ...[
                    _buildInfoRow(Icons.home, doctor.officeAddressLine2!),
                    const SizedBox(height: 8),
                  ],
                  if (doctor.officeCity != null || doctor.officeState != null)
                    _buildInfoRow(
                      Icons.location_city,
                      '${doctor.officeCity ?? ''}, ${doctor.officeState ?? ''} ${doctor.officeZipCode ?? ''}'
                          .trim(),
                    ),
                  if (doctor.officePhone != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // TODO: Implement phone call
                      },
                      child: _buildInfoRow(
                        Icons.phone,
                        doctor.officePhone!,
                        actionIcon: Icons.call,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Working Hours
            if (doctor.workingHours != null)
              _buildSection(
                context,
                title: 'Working Hours',
                icon: Icons.access_time,
                child: Column(
                  children: _buildWorkingHours(doctor.workingHours!),
                ),
              ),
            
            // Availability badges
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (doctor.isAcceptingPatients == true)
                    _buildBadge(
                      'Accepting New Patients',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  if (doctor.telehealthEnabled == true)
                    _buildBadge(
                      'Telehealth Available',
                      Icons.videocam,
                      Colors.blue,
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: doctor.isAcceptingPatients == false
            ? null
            : () {
                // Navigate to time slot selection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeSlotSelectionScreen(
                      doctorId: doctor.id,
                      doctorName: doctor.displayName,
                      specialty: doctor.specialty,
                    ),
                  ),
                );
              },
        icon: const Icon(Icons.calendar_today),
        label: Text(
          doctor.isAcceptingPatients == false
              ? 'Not Accepting Patients'
              : 'Book Appointment',
        ),
        backgroundColor: doctor.isAcceptingPatients == false
            ? Colors.grey
            : null,
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {IconData? actionIcon}) => Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
        if (actionIcon != null)
          Icon(actionIcon, size: 16, color: Colors.grey.shade600),
      ],
    );

  List<Widget> _buildWorkingHours(Map<String, dynamic> workingHours) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayLabels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return List.generate(days.length, (index) {
      final day = days[index];
      final label = dayLabels[index];
      final hours = workingHours[day];
      
      var hoursText = 'Closed';
      if (hours != null && hours is Map && hours['open'] != null) {
        hoursText = '${hours['open']} - ${hours['close']}';
      }
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              hoursText,
              style: TextStyle(
                color: hoursText == 'Closed' ? Colors.grey : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadge(String label, IconData icon, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

  String _getInitials(String name) {
    if (name.isEmpty) return 'D';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
