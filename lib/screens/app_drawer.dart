import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Debug print to check user data
        print('🔍 AppDrawer - User data: $user');
        print('🔍 AppDrawer - User name: ${user?.name}');
        print('🔍 AppDrawer - User email: ${user?.email}');

        return Drawer(
          child: Column(
            children: [
              // Custom User Header - KEEPING YOUR EXISTING STYLING
              Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 40.0,
                  bottom: 20.0,
                  left: 16.0,
                  right: 16.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Avatar - KEEPING YOUR EXISTING STYLING
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.name?.isNotEmpty == true
                            ? _getUserInitials(user!.name!)
                            : 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Info - KEEPING YOUR EXISTING STYLING
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.name?.isNotEmpty == true
                                ? user!.name!
                                : 'Welcome User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Loading...',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Empty container to maintain spacing (icon removed)
                    const SizedBox(
                        width:
                            48), // Maintains the same spacing as the icon would
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // KEEPING ALL YOUR EXISTING MENU ITEMS
                    _buildDrawerItem(
                      context,
                      Icons.dashboard,
                      'Dashboard',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.work,
                      'Project Registred',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/projects');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.track_changes,
                      'Daily Track Report',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/daily-track');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.feedback,
                      'Feedback',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/feedback');
                      },
                    ),
                    const Divider(),
                    _buildDrawerItem(
                      context,
                      Icons.settings,
                      'Settings',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],
                ),
              ),
              // KEEPING YOUR EXISTING LOGOUT BUTTON
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    _showLogoutDialog(context, authProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // KEEPING YOUR EXISTING HELPER METHODS
  String _getUserInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name.length > 1
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
