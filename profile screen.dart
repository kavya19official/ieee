import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _currentUser;
  bool _isLoading = true;

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
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacing24),
            
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: _currentUser?.photoUrl != null
                  ? NetworkImage(_currentUser!.photoUrl!)
                  : null,
              child: _currentUser?.photoUrl == null
                  ? Text(
                      _currentUser?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            // User Name
            Text(
              _currentUser?.name ?? 'User',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing8),
            
            // User Email
            Text(
              _currentUser?.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Events Registered',
                      _currentUser?.registeredEventIds.length.toString() ?? '0',
                      Icons.event,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: _buildStatCard(
                      'Events Attended',
                      _currentUser?.attendedEventIds.length.toString() ?? '0',
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Sign Out',
              onTap: _handleSignOut,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
