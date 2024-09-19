// Importing necessary packages for making HTTP requests and working with JSON
import 'dart:convert';
import 'package:http/http.dart' as http;

// Class representing an API client for the Nutritionix API
class NutritionixApi {
  final String appId;
  final String appKey;

  // Constructor to initialize the Nutritionix API client with an app ID and app key
  NutritionixApi({required this.appId, required this.appKey});

  // Asynchronous method to fetch nutritional information for a given query
  Future<Map<String, dynamic>> fetchNutritionalInfo(String query) async {
    try {
      // URL for making a POST request to the Nutritionix API
      final String url = 'https://trackapi.nutritionix.com/v2/natural/nutrients';

      // Headers required for the API request
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-app-id': appId,
        'x-app-key': appKey,
      };

      // Request body containing the query
      Map<String, dynamic> body = {
        "query": query,
      };

      // Making a POST request to the Nutritionix API
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      // Checking the status code of the API response
      if (response.statusCode == 200) {
        // Parsing the response body as a JSON map
        final Map<String, dynamic> data = json.decode(response.body);

        // Checking if the response contains 'foods' and it is a non-empty list
        if (data.containsKey('foods') &&
            data['foods'] is List &&
            data['foods'].isNotEmpty) {
          // Extracting nutritional information from the first item in the 'foods' list
          Map<String, dynamic> nutritionalInfo = data['foods'][0];
          return nutritionalInfo;
        } else {
          // Throwing an exception if no nutritional information is found
          throw Exception('No nutritional information found');
        }
      } else {
        // Throwing an exception if the API request fails
        throw Exception('Failed to load nutritional information');
      }
    } catch (e) {
      // Handling and logging errors that occur during the API request
      print('Error fetching nutritional information: $e');
      throw Exception('Error fetching nutritional information: $e');
    }
  }
}
