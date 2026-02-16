import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        mainAxisSpacing: AppTheme.spacing16,
        crossAxisSpacing: AppTheme.spacing16,
        children: [
          _buildAdminCard(
            context,
            'Create Event',
            Icons.add_circle,
            AppTheme.primaryColor,
            () {},
          ),
          _buildAdminCard(
            context,
            'Manage Events',
            Icons.event,
            AppTheme.secondaryColor,
            () {},
          ),
          _buildAdminCard(
            context,
            'QR Scanner',
            Icons.qr_code_scanner,
            AppTheme.accentColor,
            () {},
          ),
          _buildAdminCard(
            context,
            'Analytics',
            Icons.analytics,
            AppTheme.warningColor,
            () {},
          ),
          _buildAdminCard(
            context,
            'Registrations',
            Icons.how_to_reg,
            AppTheme.successColor,
            () {},
          ),
          _buildAdminCard(
            context,
            'Settings',
            Icons.settings,
            AppTheme.textSecondary,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
