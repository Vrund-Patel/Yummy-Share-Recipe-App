import 'package:flutter/material.dart';
import 'package:yummyshare/views/screens/bookmarks_page.dart';
import 'package:yummyshare/views/screens/home_page.dart';
import 'package:yummyshare/views/widgets/custom_bottom_navigation_bar.dart';
import 'package:yummyshare/views/screens/profile_page.dart';
import 'package:yummyshare/views/screens/notification_page.dart';
import 'package:yummyshare/views/screens/add_recipe_page.dart';

class PageSwitcher extends StatefulWidget {
  @override
  _PageSwitcherState createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher> {
  int _selectedIndex = 0;

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          [
            HomePage(),
            BookmarksPage(),
            AddRecipe(),
            NotificationListPage(),
            ProfilePage(),
          ][_selectedIndex],
          BottomGradientWidget(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
          onItemTapped: _onItemTapped, selectedIndex: _selectedIndex),
    );
  }
}

class BottomGradientWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
      ),
    );
  }
}
