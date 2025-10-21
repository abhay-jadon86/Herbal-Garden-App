import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:herbal_garden_app/functionality_based/collection_storage.dart';
import 'package:herbal_garden_app/functionality_based/herbal_item.dart';
import 'package:herbal_garden_app/functionality_based/plant_details_models.dart';

class PlantPage extends StatefulWidget {
  final String? initialPlantName;
  final String? initialScientificName;
  final String? initialImageUrl;

  const PlantPage({
    super.key,
    this.initialPlantName,
    this.initialScientificName,
    this.initialImageUrl,
  });

  @override
  State<PlantPage> createState() {
    return _PlantPageState();
  }
}

class _PlantPageState extends State<PlantPage> {
  bool _isLoading = false;
  String? _plantImageUrl;
  PlantDetails? _plantDetails;
  String _errorText = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isSaved = false;

  final String _plantIdApiKey = dotenv.env['PLANT_ID_APIKEY']!;
  final String _geminiApiKey = dotenv.env['GEMINI_APIKEY']!;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkIfSaved(String scientificName) async {
    final isSaved = await CollectionStorage.isPlantSaved(scientificName);
    setState(() {
      _isSaved = isSaved;
    });
  }

  Future<void> _pickAndIdentifyPlant(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    setState(() {
      _isLoading = true;
      _plantImageUrl = null;
      _plantDetails = null;
      _errorText = "";
    });

    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final plantIdResponse = await http.post(
        Uri.parse("https://api.plant.id/v2/identify"),
        headers: {'Content-Type': 'application/json', 'Api-Key': _plantIdApiKey},
        body: jsonEncode({
          'images': [base64Image],
          'modifiers': ["similar_images"],
          'plant_details': ["common_names", "scientific_name"],
        }),
      );

      if (plantIdResponse.statusCode != 200) {
        throw Exception("Plant.id API Error: ${plantIdResponse.body}");
      }

      final data = jsonDecode(plantIdResponse.body);
      final suggestions = data['suggestions'] as List;
      if (suggestions.isEmpty) {
        throw Exception("Could not identify the plant.");
      }

      final topSuggestion = suggestions.first;
      final commonNames = topSuggestion['plant_details']['common_names'] as List?;
      final scientificName = topSuggestion['plant_details']['scientific_name'] as String?;
      final identifiedName = (commonNames?.isNotEmpty ?? false) ? commonNames!.first : scientificName ?? 'Unknown Plant';
      final imageUrl = topSuggestion['similar_images'][0]['url'];

      setState(() {
        _plantImageUrl = imageUrl;
      });

      await _fetchInfoFromGemini(identifiedName, scientificName);

    } catch (e) {
      setState(() {
        _errorText = "An error occurred. Please try again.\nDetails: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    if (widget.initialPlantName != null) {
      _plantImageUrl = widget.initialImageUrl;
    }
    if (widget.initialPlantName != null) {
      _searchPlantByName(
        widget.initialPlantName!,
        widget.initialScientificName, // <-- Pass this
      );
    }

  }
  Future<void> _searchPlantByName(String plantName, String? scientificName) async {
    if (plantName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _plantDetails = null;
      _errorText = "";
    });

    try {
      await _fetchInfoFromGemini(plantName, scientificName);
    } catch (e) {
      setState(() {
        _errorText = "An error occurred. Please try again.\nDetails: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSource(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Photo Gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndIdentifyPlant(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndIdentifyPlant(ImageSource.camera);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSearchDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D2428),
          title: const Text('Search for a Plant', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'e.g., Rose, Turmeric...',
              hintStyle: TextStyle(color: Colors.white54),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            ),
            onSubmitted: (value) {
              final plantName = _searchController.text;
              _searchController.clear();
              Navigator.of(context).pop();
              _searchPlantByName(plantName, null);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                _searchController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search', style: TextStyle(color: Color(0xFF32CD32))),
              onPressed: () {
                final plantName = _searchController.text;
                _searchController.clear();
                Navigator.of(context).pop();
                _searchPlantByName(plantName, null);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchInfoFromGemini(String commonName, String? scientificName) async {
    final geminiUrl = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_geminiApiKey");

    final prompt = """
      You are a botanist and herbalist expert.
      For the plant named "$commonName" with the scientific name "${scientificName ?? 'Not available'}", provide a detailed breakdown.
      Return the information as a single, valid JSON object only, with no other text, comments, or markdown formatting before or after it.

      The JSON object must have this exact structure:
      {
        "commonName": "$commonName",
        "scientificName": "${scientificName ?? 'Not available'}",
        "about": "A brief, engaging paragraph about the plant, maximum 2-3 sentences.",
        "quickInfo": {
          "sunlight": "Full Sun | Partial Shade | Full Shade",
          "watering": "Frequent | Moderate | Low",
          "petSafety": "Pet Friendly | Toxic to Pets | Use with Caution",
          "growthEase": "Easy | Intermediate | Difficult"
        },
        "uses": {
          "medicinal": ["Benefit 1", "Benefit 2"],
          "culinary": ["Use 1", "Use 2"]
        },
        "growthGuide": {
          "climate": "Describe the ideal climate.",
          "soil": "Describe the best soil type.",
          "wateringSchedule": "Provide a detailed watering schedule."
        },
        "extras": {
          "warnings": "Provide any safety warnings or specify 'None'.",
          "funFact": "Provide one interesting fun fact."
        }
      }
      """;

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
      throw Exception("Gemini API Error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final jsonString = data['candidates'][0]['content']['parts'][0]['text'];
    final plantJson = jsonDecode(jsonString);

    setState(() {
      _plantDetails = PlantDetails.fromJson(plantJson);
    });
    await _checkIfSaved(_plantDetails!.scientificName);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final plantData = _plantDetails;

    return Scaffold(
      backgroundColor: const Color(0xFF1D2428),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          plantData?.commonName ?? "Identify a Plant",
          style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _isLoading ? null : _showSearchDialog,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B0082), Color(0xFF008080), Color(0xFF20B2AA)],
              stops: [0.3, 0.8, 1],
              begin: AlignmentDirectional(1, 1),
              end: AlignmentDirectional(-1, -1),
            )),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : _errorText.isNotEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorText, style: TextStyle(color: Colors.red[300]), textAlign: TextAlign.center)))
            : plantData == null
            ? buildInitialView()
            : buildPlantDetailsView(plantData, screenWidth),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _showImageSource(context),
        label: Text("Identify Plant", style: GoogleFonts.interTight(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.camera_alt),
        backgroundColor: const Color(0xFF32CD32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //

  Widget buildInitialView() {
    return const Center(
      child: Text(
        "Press the button below to identify a plant.",
        style: TextStyle(color: Colors.white70, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildPlantDetailsView(PlantDetails plantData, double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: screenWidth * 0.5,
              width: screenWidth * 0.5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white30),
                image: _plantImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(_plantImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _plantImageUrl == null ? Icon(Icons.image, color: Colors.white30, size: 40) : null,
            ),
          ),
          const SizedBox(height: 24),
          _QuickInfoRow(info: plantData.quickInfo),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plantData.commonName, style: GoogleFonts.interTight(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(plantData.scientificName, style: GoogleFonts.interTight(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                  color: _isSaved ? const Color(0xFF32CD32) : Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  final herbalItem = HerbalItem(
                    name: plantData.commonName,
                    scientificName: plantData.scientificName,
                    imageUrl: _plantImageUrl ?? plantData.imageUrl,
                  );

                  if (_isSaved) {
                    await CollectionStorage.removePlant(herbalItem.scientificName);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed ${herbalItem.name} from collection'))
                    );
                  } else {
                    await CollectionStorage.savePlant(herbalItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved ${herbalItem.name} to collection!'))
                    );
                  }

                  setState(() {
                    _isSaved = !_isSaved;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(title: "About", content: plantData.about),
          _InfoSection(title: "Medicinal Advantage", listContent: plantData.uses.medicinal),
          _InfoSection(title: "Culinary Use", listContent: plantData.uses.culinary),
          _InfoSection(title: "How to Grow?", isSubSection: true, children: [
            _SubInfoSection(title: "Ideal Climate", content: plantData.growthGuide.climate),
            _SubInfoSection(title: "Soil Type", content: plantData.growthGuide.soil),
            _SubInfoSection(title: "Watering Schedule", content: plantData.growthGuide.wateringSchedule),
          ]),
          _InfoSection(title: "Safety Info", content: plantData.extras.warnings),
          _InfoSection(title: "Fun Fact", content: plantData.extras.funFact),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}

//

class _QuickInfoRow extends StatelessWidget {
  final QuickInfo info;
  const _QuickInfoRow({required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoIcon(icon: Icons.wb_sunny_outlined, text: info.sunlight),
        _InfoIcon(icon: Icons.water_drop_outlined, text: info.watering),
        _InfoIcon(icon: Icons.pets_outlined, text: info.petSafety),
        _InfoIcon(icon: Icons.psychology_alt_outlined, text: info.growthEase),
      ],
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String? content;
  final List<String>? listContent;
  final List<Widget>? children;
  final bool isSubSection;

  const _InfoSection({
    required this.title,
    this.content,
    this.listContent,
    this.children,
    this.isSubSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.interTight(
              fontSize: isSubSection ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (content != null)
            Text(content!, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          if (listContent != null)
            ...listContent!.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(color: Colors.white70, fontSize: 15)),
                  Expanded(child: Text(item, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5))),
                ],
              ),
            )),
          if (children != null) ...children!,
        ],
      ),
    );
  }
}

class _SubInfoSection extends StatelessWidget {
  final String title;
  final String content;
  const _SubInfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}