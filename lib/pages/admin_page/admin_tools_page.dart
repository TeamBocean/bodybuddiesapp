import 'package:flutter/material.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';

import 'booking_migration_page.dart';

/// Admin tools hub for maintenance tasks
class AdminToolsPage extends StatelessWidget {
  const AdminToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tools'),
        backgroundColor: background,
      ),
      body: Container(
        color: background,
        padding: EdgeInsets.all(Dimensions.width15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediumTextWidget(
              text: 'Maintenance Tools',
              fontSize: Dimensions.fontSize22,
            ),
            SizedBox(height: Dimensions.height20),
            _buildToolCard(
              context,
              icon: Icons.calendar_today,
              title: 'Booking Migration',
              description: 'Fix legacy bookings that are missing the year in their date format.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingMigrationPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.height15),
            _buildToolCard(
              context,
              icon: Icons.analytics,
              title: 'Data Analytics',
              description: 'View booking statistics and user metrics.',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: darkGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width10),
              decoration: BoxDecoration(
                color: darkGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: darkGreen,
                size: Dimensions.iconSize20,
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: title,
                    fontSize: Dimensions.fontSize16,
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSize12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: Dimensions.iconSize16,
            ),
          ],
        ),
      ),
    );
  }
}
