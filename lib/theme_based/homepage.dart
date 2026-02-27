import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal_garden_app/functionality_based/uihelper.dart';
import 'package:herbal_garden_app/theme_based/plantpage.dart';
import 'collectionpage.dart';
import 'package:herbal_garden_app/functionality_based/collection_storage.dart';
import 'package:herbal_garden_app/functionality_based/herbal_item.dart';
import 'package:herbal_garden_app/functionality_based/hotdservice.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<HerbalItem> _userCollection = [];
  bool _isLoading = true;

  final List<HerbalItem> _defaultCollection = [
    HerbalItem(name: "Turmeric", scientificName: "Curcuma longa", imageUrl: 'https://images.unsplash.com/photo-1627394375537-c53de978b1a0?w=600'),
    HerbalItem(name: "Ginger", scientificName: "Zingiber officinale", imageUrl: 'https://images.unsplash.com/photo-1689193503093-6b7f049f711f?w=600'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    setState(() => _isLoading = true);
    final savedPlants = await CollectionStorage.getSavedPlants();
    if (mounted) {
      setState(() {
        _userCollection = savedPlants;
        _isLoading = false;
      });
    }
  }

  List<HerbalItem> get _collectionPreview {
    final listToShow = _userCollection.isEmpty ? _defaultCollection : _userCollection;
    return listToShow.take(2).toList();
  }

  void _navigateToSearchPage(HerbalItem herb) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantPage(
          initialPlantName: herb.name,
          initialScientificName: herb.scientificName,
          initialImageUrl: herb.imageUrl,
        ),
      ),
    );
    _loadCollection();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1D2428),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "🌿  My Herbal Garden",
          style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.055),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: screenWidth * 0.065,
          ),
        ),
        actions: [
          Row(
            children: [
              uiHelper()
                  .customIcomButton(Icons.search, () => print("Search Button Pressed")),
              uiHelper().customIcomButton(Icons.mic, () => print("Mic Button Pressed")),
            ],
          )
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                          colors: [Color(0x1AFFFFFF), Color(0x33FFFFFF)],
                          stops: [0, 1],
                          begin: AlignmentDirectional(0, -1),
                          end: AlignmentDirectional(0, 1))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04, vertical: screenHeight * 0.025),
                    child: Column(
                      children: [
                        Text(
                          "Hello Abhay! Ready to explore Nature's pharmacy?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.055),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          "Scan a plant or discover herbs by their healing power.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.interTight(
                              color: const Color(0xFF95A1AC),
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        uiHelper().customCardButton(
                            "🌱 Scan a Plant",
                                () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> PlantPage()));
                            },
                            screenHeight * 0.06,
                            screenWidth * 0.65,
                            const Color(0xFF32CD32),
                            screenWidth * 0.045),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Text(
              "Explore Categories",
              style: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                  color: Colors.white),
            ),
                SizedBox(height: screenHeight * 0.015),
                SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  uiHelper().customCardButton(
                      "🌡️ Medicinal",
                          () {},
                      screenHeight * 0.05,
                      screenWidth * 0.33,
                      const Color(0xFF20B2AA),
                      screenWidth * 0.035),
                  SizedBox(width: screenWidth * 0.04),
                  uiHelper().customCardButton(
                      "🔆 Seasonal",
                          () {},
                      screenHeight * 0.05,
                      screenWidth * 0.33,
                      const Color(0xFF9370DB),
                      screenWidth * 0.035),
                  SizedBox(width: screenWidth * 0.04),
                  uiHelper().customCardButton(
                      "🏠 Household",
                          () {},
                      screenHeight * 0.05,
                      screenWidth * 0.33,
                      const Color(0xFF228B22),
                      screenWidth * 0.035),
                  SizedBox(width: screenWidth * 0.04),
                  uiHelper().customCardButton(
                      "🤍 Immunity",
                          () {},
                      screenHeight * 0.05,
                      screenWidth * 0.33,
                      const Color(0xFFD6204E),
                      screenWidth * 0.035),
                  SizedBox(width: screenWidth * 0.04),
                  uiHelper().customCardButton(
                      "🧘 Ayurvedic",
                          () {},
                      screenHeight * 0.05,
                      screenWidth * 0.33,
                      const Color(0xFF4169E1),
                      screenWidth * 0.035),
                ],
              ),
            ) ,
                SizedBox(height: screenHeight * 0.015),
                Text(
                  "🌿 Herbal Collection",
                  style: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.065,
                      color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.015),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _collectionPreview.map((herb) {
                      return Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.03),
                        child: GestureDetector(
                          onTap: () => _navigateToSearchPage(herb),
                          onLongPress: () {},
                          child: Container(
                            width: screenWidth * 0.55,
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16202A).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    herb.imageUrl,
                                    width: screenWidth * 0.14,
                                    height: screenWidth * 0.14,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        herb.name,
                                        style: GoogleFonts.interTight(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.038,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        herb.scientificName,
                                        style: GoogleFonts.interTight(
                                          color: Colors.white60,
                                          fontStyle: FontStyle.italic,
                                          fontSize: screenWidth * 0.032,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CollectionPage()));
                  },
                  child: Text(
                    "See more...",
                    style: TextStyle(
                        color: Colors.grey, fontSize: screenWidth * 0.045),
                  ),
                ),
                const HerbOfTheDayWidget(),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class HerbOfTheDayWidget extends StatefulWidget {
  const HerbOfTheDayWidget({super.key});

  @override
  State<HerbOfTheDayWidget> createState() => _HerbOfTheDayWidgetState();
}

class _HerbOfTheDayWidgetState extends State<HerbOfTheDayWidget> {
  Map<String, String>? _dailyHerb;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyHerb();
  }

  Future<void> _fetchDailyHerb() async {
    final data = await DailyHerbService.getTodayHerbData();
    if (mounted) {
      setState(() {
        _dailyHerb = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Container(
        height: 180,
        width: double.infinity,
        margin: EdgeInsets.only(top: screenWidth * 0.05),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF32CD32)),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.05),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
          ],
          image: DecorationImage(
            image: NetworkImage(_dailyHerb!['imageUrl']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
            ),
          ),
          padding: EdgeInsets.all(screenWidth * 0.04),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "✨ Herb of the Day",
                style: GoogleFonts.interTight(
                  color: const Color(0xFF32CD32),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                _dailyHerb!['name']!,
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.055,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                _dailyHerb!['desc']!,
                style: GoogleFonts.interTight(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.035,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}