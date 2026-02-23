import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import '../models/song.dart';

class AddEditSongPage extends StatefulWidget {
  final Song? songToEdit;
  
  const AddEditSongPage({super.key, this.songToEdit});

  @override
  State<AddEditSongPage> createState() => _AddEditSongPageState();
}

class _AddEditSongPageState extends State<AddEditSongPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _noteController = TextEditingController();
  String selectedMood = 'Happy';

  @override
  void initState() {
    super.initState();
    if (widget.songToEdit != null) {
      _titleController.text = widget.songToEdit!.title;
      _artistController.text = widget.songToEdit!.artist;
      _noteController.text = widget.songToEdit!.note;
      selectedMood = widget.songToEdit!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.amber;
      case 'Sad':
        return Colors.blue;
      case 'Chill':
        return Colors.purple;
      case 'Focus':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _saveSong() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SongProvider>(context, listen: false);

      if (widget.songToEdit == null) {
        final newSong = Song(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          mood: selectedMood,
          note: _noteController.text.trim(),
          createdAt: DateTime.now(),
        );

        provider.addSong(newSong);


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newSong.title} added!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {

        final updatedSong = widget.songToEdit!.copyWith(
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          mood: selectedMood,
          note: _noteController.text.trim(),
        );

        provider.updateSong(widget.songToEdit!.id, updatedSong);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedSong.title} updated!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.songToEdit == null ? 'Add Song' : 'Edit Song',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSong,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 50,
                        color: getMoodColor(selectedMood),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.songToEdit == null
                          ? 'Capture Your Music Moment'
                          : 'Update Your Music Moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Song Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter song title',
                          prefixIcon: const Icon(Icons.library_music_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a song title';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Artist Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _artistController,
                        decoration: InputDecoration(
                          hintText: 'Enter artist name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an artist name';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'How does it make you feel?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildMoodChip('Happy', Colors.amber),
                          _buildMoodChip('Sad', Colors.blue),
                          _buildMoodChip('Chill', Colors.purple),
                          _buildMoodChip('Focus', Colors.green),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Your Thoughts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              'Write about this song...\n\nWhat memories does it bring? How does it make you feel? When do you listen to it?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write your thoughts about this song';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveSong,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor:
                              const Color(0xFF667eea).withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              widget.songToEdit == null
                                  ? 'Save Song'
                                  : 'Update Song',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String mood, Color color) {
    return ChoiceChip(
      label: Text(mood),
      selected: selectedMood == mood,
      onSelected: (selected) {
        setState(() {
          selectedMood = mood;
        });
      },
      selectedColor: color,
      avatar: selectedMood == mood
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
      labelStyle: TextStyle(
        color: selectedMood == mood ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}