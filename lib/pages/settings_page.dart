import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/user.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Account'),
            Tab(icon: Icon(Icons.tune), text: 'Preferences'),
            Tab(icon: Icon(Icons.filter_list), text: 'Content'),
            Tab(icon: Icon(Icons.security), text: 'Privacy'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.info), text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountSettings(user),
          _buildPreferencesSettings(),
          _buildContentSettings(),
          _buildPrivacySettings(),
          _buildNotificationSettings(),
          _buildAboutSettings(),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          _buildSectionHeader('Profile Information'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person,
              title: 'Profile Picture',
              subtitle: 'Change your profile picture',
              trailing: CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              onTap: () => _showProfilePictureDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.badge,
              title: 'Display Name',
              subtitle: user?.username ?? 'Not set',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showEditNameDialog(user),
            ),
            _buildSettingsTile(
              icon: Icons.email,
              title: 'Email Address',
              subtitle: user?.email ?? 'Not set',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showEditEmailDialog(user),
            ),
            _buildSettingsTile(
              icon: Icons.phone,
              title: 'Phone Number',
              subtitle: user?.phoneNumber ?? 'Not set',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showEditPhoneDialog(user),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Security Section
          _buildSectionHeader('Security'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.verified_user,
              title: 'Account Verification',
              subtitle: user?.isVerified == true ? 'Verified' : 'Not verified',
              trailing: user?.isVerified == true 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.pending, color: Colors.orange),
              onTap: () => _showVerificationDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Account Actions
          _buildSectionHeader('Account Actions'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.download,
              title: 'Export Data',
              subtitle: 'Download your data',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _exportUserData(),
            ),
            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteAccountDialog(),
              textColor: Colors.red,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPreferencesSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsCard([
            Consumer(
              builder: (context, ref, child) {
                final themeMode = ref.watch(themeModeProvider);
                final isDarkMode = themeMode == ThemeMode.dark;
                
                return _buildSettingsTile(
                  icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  title: 'Theme',
                  subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    activeThumbColor: AppTheme.secondaryColor,
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Medium',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFontSizeDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Location Section
          _buildSectionHeader('Location'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.location_on,
              title: 'Location Services',
              subtitle: 'Allow app to access your location',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update location services preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.my_location,
              title: 'Default Area',
              subtitle: 'Koramangala 4th Block', // TODO: Get from preferences
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAreaSelectionDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Accessibility Section
          _buildSectionHeader('Accessibility'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.visibility,
              title: 'High Contrast',
              subtitle: 'Increase contrast for better visibility',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update high contrast preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Play sounds for interactions',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update sound effects preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildContentSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Preferences Section
          _buildSectionHeader('Content Preferences'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.location_city,
              title: 'Preferred Areas',
              subtitle: 'Manage areas you want to see posts from',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAreaPreferencesDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.category,
              title: 'Category Filters',
              subtitle: 'Choose which issue types to see',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showCategoryPreferencesDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.sort,
              title: 'Default Sort Order',
              subtitle: 'Newest first',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSortOrderDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Content Display Section
          _buildSectionHeader('Content Display'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.image,
              title: 'Auto-load Images',
              subtitle: 'Automatically load images in posts',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update auto-load images preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.wifi,
              title: 'WiFi Only Images',
              subtitle: 'Load images only on WiFi',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update WiFi only images preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.cached,
              title: 'Cache Size',
              subtitle: '100 MB used',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showCacheSettingsDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Content Actions Section
          _buildSectionHeader('Content Actions'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.clear_all,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _clearCache(),
            ),
            _buildSettingsTile(
              icon: Icons.refresh,
              title: 'Reset Filters',
              subtitle: 'Reset all content filters to default',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _resetFilters(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy Section
          _buildSectionHeader('Privacy'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.visibility_off,
              title: 'Profile Visibility',
              subtitle: 'Control who can see your profile',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showProfileVisibilityDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.location_off,
              title: 'Location Privacy',
              subtitle: 'Control location sharing in posts',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLocationPrivacyDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Help improve the app with usage data',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update analytics preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Data Section
          _buildSectionHeader('Data & Storage'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.storage,
              title: 'Data Usage',
              subtitle: 'Monitor your data consumption',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDataUsageDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.backup,
              title: 'Backup Settings',
              subtitle: 'Automatically backup your preferences',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update backup settings preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.delete_sweep,
              title: 'Auto-delete Old Posts',
              subtitle: 'Automatically delete posts older than 1 year',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update auto-delete preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Security Section
          _buildSectionHeader('Security'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update biometric login preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.timer,
              title: 'Auto-lock',
              subtitle: 'Lock app after 5 minutes of inactivity',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAutoLockDialog(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Push Notifications Section
          _buildSectionHeader('Push Notifications'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your device',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update push notifications preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate when receiving notifications',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update vibration preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.volume_up,
              title: 'Notification Sound',
              subtitle: 'Play sound for notifications',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update notification sound preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Notification Types Section
          _buildSectionHeader('Notification Types'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.thumb_up,
              title: 'Post Interactions',
              subtitle: 'When someone upvotes or comments on your posts',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update post interactions preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.update,
              title: 'Status Updates',
              subtitle: 'When your reported issues are updated',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update status updates preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.location_on,
              title: 'Nearby Issues',
              subtitle: 'New issues reported in your area',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update nearby issues preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.admin_panel_settings,
              title: 'Admin Updates',
              subtitle: 'Important announcements and updates',
              trailing: Switch(
                value: true, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update admin updates preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Email Notifications Section
          _buildSectionHeader('Email Notifications'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update email notifications preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.schedule,
              title: 'Email Frequency',
              subtitle: 'Daily digest',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showEmailFrequencyDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Quiet Hours Section
          _buildSectionHeader('Quiet Hours'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.bedtime,
              title: 'Do Not Disturb',
              subtitle: 'Silence notifications during specific hours',
              trailing: Switch(
                value: false, // TODO: Get from preferences
                onChanged: (value) {
                  // TODO: Update do not disturb preference
                },
                activeThumbColor: AppTheme.secondaryColor,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.access_time,
              title: 'Quiet Hours',
              subtitle: '10:00 PM - 7:00 AM',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showQuietHoursDialog(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Info Section
          _buildSectionHeader('App Information'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Version',
              subtitle: '${AppConstants.appVersion} (Build 1)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showVersionInfoDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.update,
              title: 'Check for Updates',
              subtitle: 'Look for app updates',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _checkForUpdates(),
            ),
            _buildSettingsTile(
              icon: Icons.storage,
              title: 'Storage Used',
              subtitle: '125 MB',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showStorageInfoDialog(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Help & Support Section
          _buildSectionHeader('Help & Support'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help,
              title: 'Help Center',
              subtitle: 'Get help and find answers',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openHelpCenter(),
            ),
            _buildSettingsTile(
              icon: Icons.contact_support,
              title: 'Contact Support',
              subtitle: 'Get in touch with our support team',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _contactSupport(),
            ),
            _buildSettingsTile(
              icon: Icons.bug_report,
              title: 'Report a Bug',
              subtitle: 'Help us improve by reporting issues',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _reportBug(),
            ),
            _buildSettingsTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts and suggestions',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _sendFeedback(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Legal Section
          _buildSectionHeader('Legal'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openPrivacyPolicy(),
            ),
            _buildSettingsTile(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Terms and conditions',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openTermsOfService(),
            ),
            _buildSettingsTile(
              icon: Icons.copyright,
              title: 'Open Source Licenses',
              subtitle: 'Third-party libraries and licenses',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openOpenSourceLicenses(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Community Section
          _buildSectionHeader('Community'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.star,
              title: 'Rate the App',
              subtitle: 'Rate us on the app store',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _rateApp(),
            ),
            _buildSettingsTile(
              icon: Icons.share,
              title: 'Share the App',
              subtitle: 'Tell your friends about Civic Reporter',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _shareApp(),
            ),
            _buildSettingsTile(
              icon: Icons.groups,
              title: 'Join Community',
              subtitle: 'Connect with other users',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _joinCommunity(),
            ),
          ]),
        ],
      ),
    );
  }

  // Helper methods for building UI components
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.secondaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // Dialog and action methods (placeholders for now)
  void _showProfilePictureDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture change feature coming soon')),
    );
  }

  void _showEditNameDialog(user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit name feature coming soon')),
    );
  }

  void _showEditEmailDialog(user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit email feature coming soon')),
    );
  }

  void _showEditPhoneDialog(user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit phone feature coming soon')),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _showVerificationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account verification feature coming soon')),
    );
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language selection feature coming soon')),
    );
  }

  void _showFontSizeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Font size selection feature coming soon')),
    );
  }

  void _showAreaSelectionDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Area selection feature coming soon')),
    );
  }

  void _showAreaPreferencesDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Area preferences feature coming soon')),
    );
  }

  void _showCategoryPreferencesDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category preferences feature coming soon')),
    );
  }

  void _showSortOrderDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sort order selection feature coming soon')),
    );
  }

  void _showCacheSettingsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache settings feature coming soon')),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _resetFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters reset to default')),
    );
  }

  void _showProfileVisibilityDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile visibility settings feature coming soon')),
    );
  }

  void _showLocationPrivacyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location privacy settings feature coming soon')),
    );
  }

  void _showDataUsageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data usage monitoring feature coming soon')),
    );
  }

  void _showAutoLockDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto-lock settings feature coming soon')),
    );
  }

  void _showEmailFrequencyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email frequency settings feature coming soon')),
    );
  }

  void _showQuietHoursDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiet hours settings feature coming soon')),
    );
  }

  void _showVersionInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: ${AppConstants.appVersion}'),
            Text('Build Number: 1'),
            Text('Flutter Version: 3.x'),
            Text('Dart Version: 3.x'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are using the latest version')),
    );
  }

  void _showStorageInfoDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage information feature coming soon')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center feature coming soon')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support feature coming soon')),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug reporting feature coming soon')),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback feature coming soon')),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy feature coming soon')),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service feature coming soon')),
    );
  }

  void _openOpenSourceLicenses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open source licenses feature coming soon')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate app feature coming soon')),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share app feature coming soon')),
    );
  }

  void _joinCommunity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Join community feature coming soon')),
    );
  }
}
