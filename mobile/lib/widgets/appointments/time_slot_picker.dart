import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final Function(TimeSlot) onSlotSelected;
  final int slotsPerRow;

  const TimeSlotPicker({
    Key? key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.slotsPerRow = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text(
            'No available slots',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Group slots by time period (morning, afternoon, evening)
    final groupedSlots = _groupSlotsByPeriod(slots);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSlots.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _getPeriodIcon(entry.key),
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            
            // Time Slots Grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((slot) {
                final isSelected = selectedSlot != null &&
                    selectedSlot!.start == slot.start &&
                    selectedSlot!.end == slot.end;
                final isAvailable = slot.available;
                final formattedTime = DateFormat('h:mm a').format(slot.start);

                return InkWell(
                  onTap: isAvailable ? () => onSlotSelected(slot) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48 - (slotsPerRow - 1) * 8) / slotsPerRow,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : isAvailable
                              ? Colors.white
                              : Colors.grey[200],
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : isAvailable
                                ? Colors.grey[300]!
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isAvailable
                                  ? Colors.black87
                                  : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Map<String, List<TimeSlot>> _groupSlotsByPeriod(List<TimeSlot> slots) {
    final Map<String, List<TimeSlot>> grouped = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (var slot in slots) {
      final hour = slot.start.hour;
      if (hour < 12) {
        grouped['Morning']!.add(slot);
      } else if (hour < 17) {
        grouped['Afternoon']!.add(slot);
      } else {
        grouped['Evening']!.add(slot);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.wb_sunny_outlined;
      case 'Evening':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
