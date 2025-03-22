import 'package:expense_tracker_cipherschool_assignment/styles/styles.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/user_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = userProvider.currentUser;
    final isLoading = userProvider.isLoading;

    void handleSignOut() async {
      try {
        await profileProvider.signOut();
        context.go('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }

    Future<void> pickAndUploadImage() async {
      try {
        final photoUrl = await profileProvider.pickAndUploadImage();

        if (photoUrl != null) {
          // Reload user data to get updated profile picture
          await userProvider.loadUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile picture')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Profile picture and edit button
                    Center(
                      child: Stack(
                        children: [
                          profileProvider.isUploading
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  child: CircularProgressIndicator(),
                                )
                              : user?.photoUrl != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          NetworkImage(user!.photoUrl!),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[700],
                                        size: 40,
                                      ),
                                    ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: pickAndUploadImage,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Username
                    Text(
                      'Username',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user?.name ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 40),

                    // Profile options
                    _buildProfileOption(
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.deepPurple,
                      iconBgColor: Color(0xFFF1ECFF),
                      title: 'Account',
                      onTap: () {},
                    ),

                    _buildProfileOption(
                      icon: Icons.settings,
                      iconColor: Colors.deepPurple,
                      iconBgColor: Color(0xFFF1ECFF),
                      title: 'Settings',
                      onTap: () {},
                    ),

                    _buildProfileOption(
                      icon: Icons.file_download_outlined,
                      iconColor: Colors.deepPurple,
                      iconBgColor: Color(0xFFF1ECFF),
                      title: 'Export Data',
                      onTap: () {},
                    ),

                    _buildProfileOption(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      iconBgColor: Color(0xFFFFECEC),
                      title: 'Logout',
                      onTap: handleSignOut,
                    ),

                    Spacer(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}