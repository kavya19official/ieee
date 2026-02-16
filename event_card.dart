import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isPast;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: AppTheme.borderColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: AppTheme.borderColor,
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge and Status
                  Row(
                    children: [
                      _buildCategoryBadge(),
                      const Spacer(),
                      if (!isPast && event.isFull)
                        _buildStatusBadge('Full', AppTheme.errorColor),
                      if (event.isFeatured)
                        _buildStatusBadge('Featured', AppTheme.accentColor),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing12),
                  
                  // Event Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppTheme.spacing8),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(event.startTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing8),
                  
                  // Venue
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  if (event.speaker != null) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Expanded(
                          child: Text(
                            event.speaker!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (!isPast) ...[
                    const SizedBox(height: AppTheme.spacing16),
                    
                    // Registration Info
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: event.maxAttendees > 0
                                ? event.currentRegistrations / event.maxAttendees
                                : 0,
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              event.isFull ? AppTheme.errorColor : AppTheme.successColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Text(
                          '${event.currentRegistrations}/${event.maxAttendees}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (isPast) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          '${event.actualAttendance} attended',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Icon(
                          Icons.percent,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          '${event.attendanceRate.toStringAsFixed(1)}% attendance',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    Color badgeColor;
    switch (event.category) {
      case EventCategory.workshop:
        badgeColor = AppTheme.primaryColor;
        break;
      case EventCategory.seminar:
        badgeColor = AppTheme.secondaryColor;
        break;
      case EventCategory.networking:
        badgeColor = AppTheme.accentColor;
        break;
      case EventCategory.competition:
        badgeColor = AppTheme.warningColor;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        event.category.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
