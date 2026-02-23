import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/notification_service.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';

class SongProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  String? _userId;
  
  List<Song> _songs = [];
  String _selectedMood = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get selectedMood => _selectedMood;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get songCount => _songs.length;
  List<Song> get allSongs => List.from(_songs);

  void setUserId(String? userId) {
    _userId = userId;
    
    if (userId == null) {
      _songs.clear();
      notifyListeners();
    } else {
      loadSongsFromFirebase();
    }
  }

  List<Song> get songs {
    List<Song> filtered = List.from(_songs);

    if (_selectedMood != 'All') {
      filtered = filtered.where((song) => song.mood == _selectedMood).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((song) {
        return song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }


  Future<void> loadSongsFromFirebase() async {
    if (_userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _songs = await _firebaseService.getAllSongs(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load songs: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }


  void listenToSongs() {
    if (_userId == null) return;

    _firebaseService.getSongsStream(_userId!).listen(
      (songs) {
        _songs = songs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to listen to songs: $error';
        notifyListeners();
      },
    );
  }

 Future<void> addSong(Song song) async {
    if (_userId == null) throw Exception('User not logged in');

    try {
      await _firebaseService.addSong(song, _userId!);
      await loadSongsFromFirebase();

      if (_songs.isNotEmpty && _songs.length % 3 == 0) {
        NotificationService.showAchievementNotification(
          title: 'Mantap! 🎶',
          body: 'Kamu sudah menyelesaikan ${_songs.length} lagu! Teruskan semangatmu!',
        );
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          'last_song_added_timestamp', 
          DateTime.now().millisecondsSinceEpoch
        );
      } catch (e) {
        // Ignore error
      }
    } catch (e) {
      _errorMessage = 'Failed to add song: $e';
      notifyListeners();
      rethrow;
    }
  }

 

  Future<void> updateSong(String id, Song updatedSong) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _firebaseService.updateSong(id, updatedSong, _userId!);

      final index = _songs.indexWhere((song) => song.id == id);
      if (index != -1) {
        _songs[index] = updatedSong;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update song: $e';
      notifyListeners();
      rethrow;
    }
  }

 
  Future<void> deleteSong(String id) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _firebaseService.deleteSong(id, _userId!);
      _songs.removeWhere((song) => song.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete song: $e';
      notifyListeners();
      rethrow;
    }
  }



  void setMoodFilter(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedMood = 'All';
    _searchQuery = '';
    notifyListeners();
  }


  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> getSongCountByMood() {
    final moodCounts = <String, int>{};
    for (var song in _songs) {
      moodCounts[song.mood] = (moodCounts[song.mood] ?? 0) + 1;
    }
    return moodCounts;
  }

  Future<void> refreshSongs() async {
    await loadSongsFromFirebase();
  }

  void clearData() {
    _songs.clear();
    _selectedMood = 'All';
    _searchQuery = '';
    _userId = null;
    _errorMessage = null;
    notifyListeners();
  }
}