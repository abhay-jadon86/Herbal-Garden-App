import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal_garden_app/theme_based/plantpage.dart';
import 'package:herbal_garden_app/functionality_based/collection_storage.dart';
import 'package:herbal_garden_app/functionality_based/herbal_item.dart';

class CollectionPage extends StatefulWidget{
  const CollectionPage({super.key});
  @override
  State<CollectionPage> createState() {
    return _CollectionPageState();
  }
}

class _CollectionPageState extends State<CollectionPage>{
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
    setState(() {
      _userCollection = savedPlants;
      _isLoading = false;
    });
  }

  List<HerbalItem> get _currentCollection {
    return _userCollection.isEmpty ? _defaultCollection : _userCollection;
  }

  bool get _isUserCollection {
    return _userCollection.isNotEmpty;
  }

  void _showDeleteConfirmation(HerbalItem plant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2c3e50),
        title: Text('Remove Herb', style: GoogleFonts.interTight(color: Colors.white)),
        content: Text('Remove ${plant.name} from your collection?', style: GoogleFonts.interTight(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await CollectionStorage.removePlant(plant.scientificName);
              _loadCollection();
              Navigator.of(ctx).pop();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _navigateToSearchPage(HerbalItem herb) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantPage(
          initialPlantName: herb.name,
          initialScientificName: herb.scientificName, //
          initialImageUrl: herb.imageUrl,
        ),
      ),
    );

    _loadCollection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF1D2428),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white)
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "My Herbal Collection",
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B0082), Color(0xFF008080), Color(0xFF20B2AA)],
                stops: [0.3, 0.8, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              if (_isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final collectionToDisplay = _currentCollection;

              if (collectionToDisplay.isEmpty) {
                return _buildEmptyState(screenWidth);
              }

              final int crossAxisCount = (screenWidth < 600) ? 2 : (screenWidth < 1200 ? 3 : 4);
              final double padding = screenWidth * 0.03;
              final double itemWidth = (screenWidth - (padding * (crossAxisCount + 1))) / crossAxisCount;
              final double itemHeight = itemWidth / 0.7;
              final double childAspectRatio = itemWidth / itemHeight;

              return GridView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: collectionToDisplay.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final herb = collectionToDisplay[index];
                  return HerbCard(
                    herb: herb,
                    onTap: () {
                      _navigateToSearchPage(herb);
                    },
                    onLongPress: () {
                      if (_isUserCollection) {
                        _showDeleteConfirmation(herb);
                      }
                    },
                  );
                },
              );
            },
          ),
        )
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    final fontSize = (screenWidth < 600) ? screenWidth * 0.045 : screenWidth * 0.025;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, color: Colors.white.withValues(alpha: 0.7), size: 100),
            const SizedBox(height: 20),
            Text(
              'Your collection is empty',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Identify tab to save a plant!',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                color: Colors.white70,
                fontSize: fontSize * 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HerbCard extends StatelessWidget {
  final HerbalItem herb;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const HerbCard({
    super.key,
    required this.herb,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned.fill(
              child: Image.network(
                herb.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey.shade800, child: const Icon(Icons.broken_image, color: Colors.grey));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    herb.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    herb.scientificName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}