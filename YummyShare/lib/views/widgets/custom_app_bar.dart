import 'package:flutter/material.dart';
import 'package:yummyshare/views/utils/AppColor.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  CustomAppBar({
    required this.title,
  });

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      title: title,
      elevation: 0,
    );
  }
}
