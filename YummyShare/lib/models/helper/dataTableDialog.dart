import 'package:flutter/material.dart';

class RecipeTableInfo {
  String title;
  int saveCount;
  RecipeTableInfo(this.title, this.saveCount);
}

class RecipeDialog {
  // Static method to show a dialog containing a table of recipes
  static void showRecipeTableDialog(
      BuildContext context, List<RecipeTableInfo> recipes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Recipe Table',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      // DataTable columns definition
                      columns: [
                        DataColumn(label: Text('Recipe')),
                        DataColumn(label: Text('Save Count')),
                      ],

                      // DataTable rows populated with recipe information
                      rows: recipes.map((recipe) {
                        return DataRow(
                          cells: [
                            DataCell(Text(recipe.title)),
                            DataCell(
                              Text(
                                recipe.saveCount.toString(),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
