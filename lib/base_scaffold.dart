import 'package:flutter/material.dart';
import 'pages/home_page.dart';        // Import the pages
import 'pages/report_issues_page.dart';

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({Key? key}) : super(key: key);

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  int _currentIndex = 0;

  // List of all the pages for the BottomNavigationBar tabs
  final List<Widget> _pages = [
    HomePage(),           // Home page widget from the pages folder
    ReportIssuesPage(),    // Report issues page widget from the pages folder
    Center(child: Text("Search Page Placeholder")),    // Placeholder for now
    Center(child: Text("Info Page Placeholder")),      // Placeholder for now
    Center(child: Text("Settings Page Placeholder")),  // Placeholder for now
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Adding the eco icon and EcoWaste text in a row for better alignment
        title: Row(
          children: const [
            Icon(Icons.eco, color: Colors.green),  // Eco icon
            SizedBox(width: 8),  // Spacing between the icon and the text
            Text(
              'EcoWaste',
              style: TextStyle(
                fontSize: 24,        // Bigger text for better readability
                fontWeight: FontWeight.bold, // Bold text
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),  // Dark background for better contrast
      ),
      body: IndexedStack(
        index: _currentIndex,          // Only the current tab's page is shown
        children: _pages,              // All pages are part of the IndexedStack
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,   // Keeps track of the selected tab
        onTap: _onTabTapped,           // Handles tab switching
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.green,  // Use green for selected items to match the eco theme
        unselectedItemColor: Colors.white, // White for unselected items for better contrast
        backgroundColor: Colors.black,     // Dark background for BottomNavigationBar
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
