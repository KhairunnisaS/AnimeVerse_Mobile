import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime.dart'; // Pastikan path ini benar menuju model Anime kamu

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method 1: Mengambil data favorites secara real-time
  Stream<List<Anime>> getFavoritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('added_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Mengubah data JSON dari Firestore kembali menjadi object Anime
        return Anime.fromJson(doc.data());
      }).toList();
    });
  }

  // Method 2: Menambahkan Anime ke favorites
  Future<void> addFavorite(String userId, Anime anime) async {
    try {
      // Kita perlu mengubah object Anime menjadi JSON (Map)
      // Pastikan model Anime kamu memiliki method .toJson()
      final animeData = anime.toJson();

      // Tambahkan timestamp server agar urutannya benar
      animeData['added_at'] = FieldValue.serverTimestamp();

      await _db
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(anime.malId.toString()) // Gunakan ID Anime sebagai ID dokumen
          .set(animeData);
    } catch (e) {
      throw Exception('Gagal menambahkan favorit: $e');
    }
  }

  // Method 3: Menghapus Anime dari favorites
  Future<void> removeFavorite(String userId, int malId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(malId.toString())
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus favorit: $e');
    }
  }
}