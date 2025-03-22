import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker_cipherschool_assignment/styles/styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Text(
                      'About Me',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 40), 
                  ],
                ),
                SizedBox(height: 24),
                
                // Profile section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Vedant Shrivastava',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Software Developer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.email,
                            onPressed: () => _launchURL('mailto:vedantshrivastava286@gmail.com'),
                          ),
                          SizedBox(width: 16),
                          _buildSocialButton(
                            icon: Icons.link,
                            onPressed: () => _launchURL('https://www.linkedin.com/in/vedant-shrivastava-275a731ba/'),
                          ),
                          SizedBox(width: 16),
                          _buildSocialButton(
                            icon: Icons.code,
                            onPressed: () => _launchURL('https://github.com/VedantS28'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // About Me section
                Text(
                  'About Me',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'I am a third-year B.Tech student at IIIT Nagpur, specializing in IoT, with expertise in Flutter, backend, and full-stack development. I’ve built scalable apps during my internships at Street Buddy and MegSoft, optimizing performance and enhancing security. With 300+ LeetCode problems solved and projects like Pixel Forge and Serene, I thrive in solving complex technical challenges.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Experience section
                Text(
                  'Experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildExperienceCard(
                  title: 'Flutter Developer Intern',
                  company: 'Street Buddy',
                  duration: 'Oct 2024 - Present',
                  points: [
                    'Engineered a full-stack mobile application using Flutter framework with Provider',
                    'Integrated Google AdMob for in-app monetization',
                    'Implemented Supabase with Row-Level Security (RLS)',
                  ],
                ),
                SizedBox(height: 12),
                _buildExperienceCard(
                  title: 'Flutter Developer Intern',
                  company: 'MegSoft',
                  duration: 'Jun 2024 - Aug 2024',
                  points: [
                    'Reduced data fetch latency by 70% through optimization',
                    'Architected cross-platform offline functionality using Hive and SQFlite',
                    'Achieved 99% UI compatibility across mobile and Windows platforms',
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Skills section
                Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSkillChip('Flutter'),
                      _buildSkillChip('Dart'),
                      _buildSkillChip('Firebase'),
                      _buildSkillChip('Provider'),
                      _buildSkillChip('Firestore'),
                      _buildSkillChip('REST API'),
                      _buildSkillChip('Supabase'),
                      _buildSkillChip('Hive'),
                      _buildSkillChip('SQFlite'),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Contact button
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Thank you for considering my application!'),
                  ),
                ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.deepPurple,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExperienceCard({
    required String title,
    required String company,
    required String duration,
    required List<String> points,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}