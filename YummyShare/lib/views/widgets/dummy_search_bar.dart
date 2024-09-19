import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummyshare/views/utils/AppColor.dart';

class DummySearchBar extends StatelessWidget {
  final void Function() routeTo;
  DummySearchBar({required this.routeTo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: routeTo,
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - Search Box
            Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(right: 15),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.primarySoft,
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/search.svg',
                        color: Colors.white, height: 18, width: 18),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        'What do you want to eat?',
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
