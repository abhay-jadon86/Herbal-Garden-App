import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for theme matching
import 'package:herbal_garden_app/theme_based/plantpage.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> _plants = [];
  bool _isLoading = true;
  String _errorMessage = ''; // Added to handle and display errors

  @override
  void initState() {
    super.initState();
    _fetchCategoryPlants();
  }

  Future<void> _fetchCategoryPlants() async {
    final geminiKey = dotenv.env['GEMINI_APIKEY'] ?? '';

    if (geminiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "API Key is missing. Check your .env file.";
      });
      return;
    }

    final prompt = "List 10 popular plants for the '${widget.category}' category. "
        "Return ONLY a valid JSON array of objects with exactly two keys: 'name' and 'scientificName'.";

    // Matching the EXACT same endpoint that works on your PlantPage
    final geminiUrl = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$geminiKey");

    try {
      final response = await http.post(
        geminiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);

      // Safety check in case the API blocks the request or returns an empty candidate
      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception("No data returned. Raw response: ${response.body}");
      }

      String jsonString = data['candidates'][0]['content']['parts'][0]['text'];

      // Stripping markdown JUST in case the API ignores the JSON mode rule
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      setState(() {
        _plants = json.decode(jsonString);
        _isLoading = false;
      });

    } catch (e) {
      // PRINTING THE EXACT ERROR DIRECTLY TO THE SCREEN!
      setState(() {
        _isLoading = false;
        _errorMessage = "Detailed Error:\n$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1D2428), // Matches Home Page
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.category} Herbs",
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        // Matches Home Page Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFF008080), Color(0xFF20B2AA)],
            stops: [0.3, 0.8, 1],
            begin: AlignmentDirectional(1, 1),
            end: AlignmentDirectional(-1, -1),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage.isNotEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(color: Colors.white, fontSize: 16),
            ),
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: 16.0,
          ),
          itemCount: _plants.length,
          itemBuilder: (context, index) {
            final plant = _plants[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF16202A).withOpacity(0.6), // Glassmorphism card effect
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  plant['name'] ?? 'Unknown',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                subtitle: Text(
                  plant['scientificName'] ?? 'Unknown',
                  style: GoogleFonts.interTight(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantPage(
                        initialPlantName: plant['name'],
                        initialScientificName: plant['scientificName'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}