import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  AppUser? _currentUser;
  bool _isRegistered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    setState(() {
      _currentUser = userData;
      _isRegistered = userData?.registeredEventIds.contains(widget.event.id) ?? false;
    });
  }

  Future<void> _handleRegistration() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      if (_isRegistered) {
        await _eventService.cancelRegistration(widget.event.id, _currentUser!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration cancelled')),
          );
        }
      } else {
        await _eventService.registerForEvent(widget.event.id, _currentUser!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully registered!')),
          );
        }
      }
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildDetails(),
                if (widget.event.speaker != null) _buildSpeakerInfo(),
                _buildDescription(),
                if (widget.event.requiresRegistration && widget.event.registrationFormUrl != null)
                  _buildExternalFormButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: !widget.event.isPast ? _buildBottomSheet() : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.event.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.event.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppTheme.borderColor),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.borderColor,
                  child: const Icon(Icons.event, size: 80),
                ),
              )
            : Container(
                color: AppTheme.borderColor,
                child: const Icon(Icons.event, size: 80),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCategoryChip(),
              const Spacer(),
              if (widget.event.isFeatured)
                const Icon(Icons.star, color: AppTheme.accentColor, size: 24),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            widget.event.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            DateFormat('EEEE, MMMM dd, yyyy').format(widget.event.startTime),
          ),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            '${DateFormat('hh:mm a').format(widget.event.startTime)} - ${DateFormat('hh:mm a').format(widget.event.endTime)}',
          ),
          _buildDetailRow(
            Icons.location_on,
            'Venue',
            widget.event.venue,
          ),
          if (widget.event.maxAttendees > 0)
            _buildDetailRow(
              Icons.people,
              'Capacity',
              '${widget.event.currentRegistrations}/${widget.event.maxAttendees}',
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerInfo() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing24),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          if (widget.event.speakerImage != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(widget.event.speakerImage!),
            )
          else
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryColor),
            ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speaker',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.event.speaker!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.event.speakerBio != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.event.speakerBio!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            widget.event.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalFormButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: OutlinedButton.icon(
        onPressed: () async {
          if (widget.event.registrationFormUrl != null) {
            final uri = Uri.parse(widget.event.registrationFormUrl!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Fill Registration Form'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading || widget.event.isFull && !_isRegistered
              ? null
              : _handleRegistration,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: _isRegistered ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isRegistered
                      ? 'Cancel Registration'
                      : widget.event.isFull
                          ? 'Event Full'
                          : 'Register Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        widget.event.category.toString().split('.').last.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
