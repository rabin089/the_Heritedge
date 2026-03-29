import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        leading: IconButton(onPressed:(){
          Navigator.pop(context);
        } , icon: Icon(Icons.arrow_back_outlined))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to the Admin Dashboard!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text("Manage Users"),
                subtitle: Text("View and assign roles to users."),
                onTap: () {
                  // Navigate to User Management
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text("Manage Heritage Sites"),
                subtitle: Text("Approve or reject heritage site submissions."),
                onTap: () {
                  // Navigate to Heritage Site Management
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text("App Analytics"),
                subtitle: Text("View app usage and reports."),
                onTap: () {
                  // Navigate to Analytics
                },
              ),
            ),
            // Add more sections here as needed
          ],
        ),
      ),
    );
  }
}
