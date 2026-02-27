import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'herbal_item.dart';

class CollectionStorage {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static CollectionReference? get _userCollectionRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('saved_plants');
  }

  static Future<List<HerbalItem>> getSavedPlants() async {
    final ref = _userCollectionRef;
    if (ref == null) return [];

    try {
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) {
        return HerbalItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePlant(HerbalItem plant) async {
    final ref = _userCollectionRef;
    if (ref == null) return;

    try {
      final docId = plant.scientificName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      await ref.doc(docId).set(plant.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removePlant(String scientificName) async {
    final ref = _userCollectionRef;
    if (ref == null) return;

    try {
      final docId = scientificName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      await ref.doc(docId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> isPlantSaved(String scientificName) async {
    final ref = _userCollectionRef;
    if (ref == null) return false;

    try {
      final docId = scientificName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final docSnapshot = await ref.doc(docId).get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }
}