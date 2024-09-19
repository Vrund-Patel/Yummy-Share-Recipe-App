import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/views/screens/recipe_detail_page.dart';

class RecommendationRecipeCard extends StatelessWidget {
  final Recipe data;
  RecommendationRecipeCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RecipeDetailPage(data: data)));
      },
      child: Container(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Photo
            Container(
              height: 120,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: Image.memory(
                    base64.decode(data.photo),
                    fit: BoxFit.cover,
                  ).image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Recipe title
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 8),
              padding: EdgeInsets.only(left: 4),
              child: Text(
                data.title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Recipe calories and time
            Container(
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/person.svg',
                    color: Colors.black,
                    width: 12,
                    height: 12,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      data.servings.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.alarm,
                    size: 12,
                    color: Colors.black,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      data.time,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
