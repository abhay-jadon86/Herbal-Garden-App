import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class DailyHerbService {
  static Future<Map<String, String>> getTodayHerbData() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final todayString = "${now.year}-${now.month}-${now.day}";
    final savedDate = prefs.getString('herb_date');

    if (savedDate == todayString) {
      return {
        "name": prefs.getString('herb_name') ?? "Holy Basil",
        "desc": prefs.getString('herb_desc') ?? "The Queen of Herbs for stress relief.",
        "imageUrl": prefs.getString('herb_image') ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Ocimum_tenuiflorum_2.jpg/800px-Ocimum_tenuiflorum_2.jpg",
      };
    }

    String herbName = "Holy Basil";
    String herbDesc = "The Queen of Herbs for stress relief.";
    try {
      final geminiKey = dotenv.env['GEMINI_APIKEY'] ?? '';
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiKey);

      final prompt = '''
      You are an expert botanist. Pick a random, popular medicinal herb. 
      Respond ONLY with a valid JSON object containing exactly two keys: 
      "name" (the name of the herb) and "desc" (a short, 10-word catchy description of its main healing property).
      Do not include markdown formatting or any other text.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final cleanJson = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '{}';
      final aiData = json.decode(cleanJson);

      if (aiData['name'] != null) herbName = aiData['name'];
      if (aiData['desc'] != null) herbDesc = aiData['desc'];
    } catch (e) {
      print("Gemini API error: $e");
    }
    String imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Ocimum_tenuiflorum_2.jpg/800px-Ocimum_tenuiflorum_2.jpg';

    try {
      final formattedName = herbName.replaceAll(' ', '_');
      final wikiUrl = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$formattedName');

      final response = await http.get(wikiUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['thumbnail'] != null && data['thumbnail']['source'] != null) {
          imageUrl = data['thumbnail']['source'];
        }
      }
    } catch (e) {
      print("Wikipedia network error.");
    }
    await prefs.setString('herb_date', todayString);
    await prefs.setString('herb_name', herbName);
    await prefs.setString('herb_desc', herbDesc);
    await prefs.setString('herb_image', imageUrl);

    return {
      "name": herbName,
      "desc": herbDesc,
      "imageUrl": imageUrl,
    };
  }
}