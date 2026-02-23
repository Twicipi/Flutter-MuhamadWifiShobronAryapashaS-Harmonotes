import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../providers/song_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/mood_chip.dart';
import '../widgets/song_card.dart';
import '../services/notification_service.dart';
import 'song_detail_page.dart';
import 'add_edit_song_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkDailyAndInactivityNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    if (!mounted) return;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    if (!isAndroid) return;

    final status = await Permission.notification.status;
    if (!mounted) return;

    if (status.isDenied) {
      await Permission.notification.request();
    } else if (status.isPermanentlyDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aktifkan notifikasi untuk reminder inspirasi lagu!'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _checkDailyAndInactivityNotifications() async {
    await Future.delayed(const Duration(seconds: 1)); 
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = today.year * 10000 + today.month * 100 + today.day;

    final lastDaily = prefs.getInt('last_daily_notif') ?? 0;
    if (lastDaily < todayKey) {
      final status = await Permission.notification.status;
      if (status.isGranted || await Permission.notification.request().isGranted) {
        NotificationService.showAchievementNotification(
          title: 'Harmonotes 💫',
          body: _getRandomDailyMessage(),
        );
        await prefs.setInt('last_daily_notif', todayKey);
      }
    }

    final lastSongTime = prefs.getInt('last_song_added_timestamp');
    final lastInactivity = prefs.getInt('last_inactivity_notif') ?? 0;
    
    if (lastSongTime != null && 
        lastInactivity < todayKey &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastSongTime)) > const Duration(hours: 1)) {
      
      final status = await Permission.notification.status;
      if (status.isGranted || await Permission.notification.request().isGranted) {
        NotificationService.showAchievementNotification(
          title: 'Inspirasi datang lagi? ✨',
          body: 'Sudah lama sejak lagu terakhir. Ada ide baru yang ingin dicatat?',
        );
        await prefs.setInt('last_inactivity_notif', todayKey);
      }
    }
  }

  String _getRandomDailyMessage() {
    final messages = [
      'Hai! Ada ide lagu yang ingin diabadikan hari ini? 🎵',
      'Mood hari ini ceria? Coba tulis lagu dengan tempo cepat! ☀️',
      'Jangan biarkan inspirasi menguap. Catat sekarang di Harmonotes! ✨',
      'Setiap nada punya cerita. Apa cerita hari ini? 📖',
      'Hari ini, coba tulis lagu yang menggambarkan perasaanmu saat ini. 💭',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  void _navigateToAddSong() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditSongPage()),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    Provider.of<SongProvider>(context, listen: false).clearData();
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    
    if (!mounted) return;
    
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed out successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'HarmoNotes',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: user?.photoURL != null
                ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(user!.photoURL!))
                : const Icon(Icons.account_circle),
            onPressed: () {
              if (!mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (bottomSheetContext) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF667eea),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, size: 40, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        Consumer<SongProvider>(
                          builder: (context, songProvider, child) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat('Total Songs', '${songProvider.songCount}', Icons.music_note),
                                  _buildStat(
                                    'Member Since',
                                    _formatDate(user?.createdAt),
                                    Icons.calendar_today,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildNotificationInfo(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!mounted) return;
                              Navigator.of(bottomSheetContext).pop();
                              _handleLogout();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SongProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)));
          }

          if (provider.errorMessage != null) {
            return RefreshIndicator(
              onRefresh: provider.refreshSongs,
              color: const Color(0xFF667eea),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error loading songs', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.refreshSongs(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshSongs,
            color: const Color(0xFF667eea),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF667eea),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${getGreeting()} 👋',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.displayName ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(255, 255, 255, 0.9),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => provider.setSearchQuery(value),
                          decoration: InputDecoration(
                            hintText: 'Search songs, artists...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter by Mood',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MoodChip(
                                label: 'All',
                                isSelected: provider.selectedMood == 'All',
                                color: const Color(0xFF667eea),
                                onTap: () => provider.setMoodFilter('All'),
                              ),
                              const SizedBox(width: 8),
                              MoodChip(
                                label: 'Happy',
                                isSelected: provider.selectedMood == 'Happy',
                                color: Colors.amber,
                                onTap: () => provider.setMoodFilter('Happy'),
                              ),
                              const SizedBox(width: 8),
                              MoodChip(
                                label: 'Sad',
                                isSelected: provider.selectedMood == 'Sad',
                                color: Colors.blue,
                                onTap: () => provider.setMoodFilter('Sad'),
                              ),
                              const SizedBox(width: 8),
                              MoodChip(
                                label: 'Chill',
                                isSelected: provider.selectedMood == 'Chill',
                                color: Colors.purple,
                                onTap: () => provider.setMoodFilter('Chill'),
                              ),
                              const SizedBox(width: 8),
                              MoodChip(
                                label: 'Focus',
                                isSelected: provider.selectedMood == 'Focus',
                                color: Colors.green,
                                onTap: () => provider.setMoodFilter('Focus'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _buildSongList(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSong,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildNotificationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: Colors.blue[400], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aktifkan notifikasi untuk reminder harian inspirasi lagu & pencapaian kreatifmu! 🎵',
              style: TextStyle(fontSize: 13, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667eea)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.year}';
  }

  Widget _buildSongList(SongProvider provider) {
    final songs = provider.songs;

    if (songs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No songs found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text('Add your first song!', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = songs[index];
            return SongCard(
              song: song,
              onTap: () {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SongDetailPage(song: song)),
                );
              },
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}