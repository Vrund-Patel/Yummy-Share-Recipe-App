import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummyshare/views/utils/AppColor.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  // The currently selected index of the bottom navigation bar
  int selectedIndex;

  // Callback function to be called when an item is tapped
  void Function(int) onItemTapped;

  // Constructor to initialize the selected index and the callback function
  CustomBottomNavigationBar(
      {required this.selectedIndex, required this.onItemTapped});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Set padding for the bottom navigation bar
      padding: EdgeInsets.only(left: 60, right: 60, bottom: 20),
      color: Colors.transparent, // Set background color to transparent
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Apply border radius
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: widget.selectedIndex, // Set the current index
            onTap: widget.onItemTapped, // Set the callback function
            showSelectedLabels: false, // Hide labels for selected items
            showUnselectedLabels: false, // Hide labels for unselected items
            elevation: 0, // No elevation for the bottom navigation bar
            items: [
              // Define the items for the bottom navigation bar
              (widget.selectedIndex == 0)
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/home-filled.svg',
                          color: AppColor.primary),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/home.svg',
                          color: Colors.grey[600]),
                      label: ''),
              (widget.selectedIndex == 1)
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bookmark-filled.svg',
                          color: AppColor.primary),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bookmark.svg',
                          color: Colors.grey[600]),
                      label: ''),
              (widget.selectedIndex == 2)
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/plus-icon.svg',
                          color: AppColor.primary),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/plus-icon.svg',
                          color: Color.fromARGB(255, 117, 117, 117),
                          height: 28,
                          width: 26),
                      label: ''),
              (widget.selectedIndex == 3)
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bell-icon.svg',
                          color: AppColor.primary, height: 28, width: 26),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bell-icon.svg',
                          color: Color.fromARGB(255, 117, 117, 117),
                          height: 28,
                          width: 26),
                      label: ''),
              (widget.selectedIndex == 4)
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/profile-icon.svg',
                          color: AppColor.primary, height: 28, width: 26),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/profile-icon.svg',
                          color: Color.fromARGB(255, 117, 117, 117),
                          height: 28,
                          width: 26),
                      label: ''),
            ],
          ),
        ),
      ),
    );
  }
}
