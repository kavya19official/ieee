import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/event_model.dart';

class EventFilterChips extends StatelessWidget {
  final EventCategory? selectedCategory;
  final Function(EventCategory?) onCategorySelected;

  const EventFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          ...EventCategory.values.map((category) {
            return _buildFilterChip(
              label: _getCategoryLabel(category),
              isSelected: selectedCategory == category,
              onTap: () => onCategorySelected(category),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  String _getCategoryLabel(EventCategory category) {
    switch (category) {
      case EventCategory.workshop:
        return 'Workshops';
      case EventCategory.seminar:
        return 'Seminars';
      case EventCategory.networking:
        return 'Networking';
      case EventCategory.competition:
        return 'Competitions';
      case EventCategory.social:
        return 'Social';
      case EventCategory.recruitment:
        return 'Recruitment';
      case EventCategory.general:
        return 'General';
    }
  }
}
