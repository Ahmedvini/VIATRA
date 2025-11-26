import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCard({
    Key? key,
    required this.doctor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Hero(
                tag: 'doctor_${doctor.id}',
                child: CircleAvatar(
                  radius: 30,
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
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and verification
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (doctor.isVerified)
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Specialty
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    if (doctor.yearsOfExperience != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${doctor.yearsOfExperience} years experience',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Info chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (doctor.consultationFee != null)
                          _buildChip(
                            context,
                            icon: Icons.attach_money,
                            label: doctor.formattedFee,
                            color: Colors.green,
                          ),
                        if (doctor.rating != null)
                          _buildChip(
                            context,
                            icon: Icons.star,
                            label: doctor.rating!.toStringAsFixed(1),
                            color: Colors.amber,
                          ),
                        if (doctor.isAcceptingPatients == true)
                          _buildChip(
                            context,
                            icon: Icons.check_circle,
                            label: 'Accepting',
                            color: Colors.green,
                          ),
                        if (doctor.telehealthEnabled == true)
                          _buildChip(
                            context,
                            icon: Icons.videocam,
                            label: 'Telehealth',
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    
                    if (doctor.officeCity != null || doctor.officeState != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${doctor.officeCity ?? ''}, ${doctor.officeState ?? ''}'.trim(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'D';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
