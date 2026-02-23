import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getUserSongsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('songs');
  }

  Future<String> addSong(Song song, String userId) async {
    try {
      final docRef = await _getUserSongsCollection(userId).add(song.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add song: $e');
    }
  }

  Future<List<Song>> getAllSongs(String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Song.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get songs: $e');
    }
  }
  Stream<List<Song>> getSongsStream(String userId) {
    return _getUserSongsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Song.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  Future<Song?> getSongById(String songId, String userId) async {
    try {
      final doc = await _getUserSongsCollection(userId).doc(songId).get();
      
      if (doc.exists) {
        return Song.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get song: $e');
    }
  }

  Future<void> updateSong(String songId, Song song, String userId) async {
    try {
      await _getUserSongsCollection(userId).doc(songId).update(song.toMap());
    } catch (e) {
      throw Exception('Failed to update song: $e');
    }
  }

  Future<void> deleteSong(String songId, String userId) async {
    try {
      await _getUserSongsCollection(userId).doc(songId).delete();
    } catch (e) {
      throw Exception('Failed to delete song: $e');
    }
  }

  Future<void> deleteAllSongs(String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId).get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all songs: $e');
    }
  }

  Future<List<Song>> getSongsByMood(String mood, String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId)
          .where('mood', isEqualTo: mood)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Song.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get songs by mood: $e');
    }
  }

  Future<List<Song>> searchSongs(String query, String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId).get();

      final allSongs = snapshot.docs
          .map((doc) => Song.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      return allSongs.where((song) {
        final queryLower = query.toLowerCase();
        return song.title.toLowerCase().contains(queryLower) ||
            song.artist.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search songs: $e');
    }
  }

  Future<int> getSongCount(String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get song count: $e');
    }
  }

  Future<Map<String, int>> getSongCountByMood(String userId) async {
    try {
      final snapshot = await _getUserSongsCollection(userId).get();
      
      final moodCounts = <String, int>{};
      
      for (var doc in snapshot.docs) {
        final song = Song.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        moodCounts[song.mood] = (moodCounts[song.mood] ?? 0) + 1;
      }
      
      return moodCounts;
    } catch (e) {
      throw Exception('Failed to get mood stats: $e');
    }
  }
}