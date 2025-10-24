import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.name ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name?.isNotEmpty == true
                    ? user!.name![0].toUpperCase()
                    : 'U',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
                  Icons.app_registration,
                  'Project Registration',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/project-registration');
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
                  'feedback',
                  () {
                    Navigator.pop(context);
                    // Add settings navigation
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  Icons.person,
                  'Profile',
                  () {
                    Navigator.pop(context);
                    // Add profile navigation
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings,
                  'Settings',
                  () {
                    Navigator.pop(context);
                    // Add settings navigation
                  },
                ),
              ],
            ),
          ),
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
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
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
}
