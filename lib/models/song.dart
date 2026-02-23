import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String mood;
  final String note;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    required this.note,
    required this.createdAt,
  });

  /// Convert Song -> Map (berguna buat Firebase / local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'mood': mood,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      mood: map['mood'],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  factory Song.fromFirestore(Map<String, dynamic> data, String docId) {
    final createdAtData = data['createdAt'];

    DateTime createdAt;
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else {
      createdAt = DateTime.now();
    }

    return Song(
      id: docId,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      mood: data['mood'] ?? 'Happy',
      note: data['note'] ?? '',
      createdAt: createdAt,
    );
  }

  Song copyWith({String? title, String? artist, String? mood, String? note}) {
    return Song(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}
