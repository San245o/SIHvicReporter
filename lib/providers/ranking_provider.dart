import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'posts_provider.dart';

/// Ranking state
class RankingState {
  final List<User> topUsers;
  final Map<String, List<User>> areaRankings;
  final bool isLoading;
  final String? error;
  
  const RankingState({
    this.topUsers = const [],
    this.areaRankings = const {},
    this.isLoading = false,
    this.error,
  });
  
  RankingState copyWith({
    List<User>? topUsers,
    Map<String, List<User>>? areaRankings,
    bool? isLoading,
    String? error,
  }) {
    return RankingState(
      topUsers: topUsers ?? this.topUsers,
      areaRankings: areaRankings ?? this.areaRankings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Ranking notifier
class RankingNotifier extends StateNotifier<RankingState> {
  final ApiService _apiService;
  
  RankingNotifier(this._apiService) : super(const RankingState());
  
  /// Fetch top users globally
  Future<void> fetchTopUsers({int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Replace with real API call
      final topUsers = _getMockTopUsers(limit);
      
      state = state.copyWith(
        topUsers: topUsers,
        isLoading: false,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Fetch rankings for a specific area
  Future<void> fetchAreaRankings(String area, {int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Replace with real API call
      final areaUsers = _getMockAreaUsers(area, limit);
      
      final updatedAreaRankings = Map<String, List<User>>.from(state.areaRankings);
      updatedAreaRankings[area] = areaUsers;
      
      state = state.copyWith(
        areaRankings: updatedAreaRankings,
        isLoading: false,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get user's rank in their area
  int getUserAreaRank(User user) {
    final areaUsers = state.areaRankings[user.area] ?? [];
    final sortedUsers = List<User>.from(areaUsers)
      ..sort((a, b) => b.reputation.compareTo(a.reputation));
    
    final userIndex = sortedUsers.indexWhere((u) => u.id == user.id);
    return userIndex >= 0 ? userIndex + 1 : areaUsers.length + 1;
  }
  
  /// Calculate user's points based on posts and reputation
  int calculateUserPoints(User user, int postsCount) {
    // Points calculation: base points + posts * 10 + reputation
    return (postsCount * 10) + user.reputation;
  }
  
  /// Get mock top users (replace with real API call)
  List<User> _getMockTopUsers(int limit) {
    return [
      User(
        id: '1',
        email: 'john@example.com',
        username: 'John Doe',
        role: 'user',
        area: 'Koramangala',
        reputation: 850,
        points: 1250,
        postsCount: 40,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isVerified: true,
      ),
      User(
        id: '2',
        email: 'jane@example.com',
        username: 'Jane Smith',
        role: 'user',
        area: 'Indiranagar',
        reputation: 720,
        points: 1020,
        postsCount: 30,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        isVerified: true,
      ),
      User(
        id: '3',
        email: 'mike@example.com',
        username: 'Mike Johnson',
        role: 'user',
        area: 'Whitefield',
        reputation: 680,
        points: 980,
        postsCount: 30,
        areaRank: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        isVerified: false,
      ),
      User(
        id: '4',
        email: 'sarah@example.com',
        username: 'Sarah Wilson',
        role: 'user',
        area: 'Koramangala',
        reputation: 650,
        points: 950,
        postsCount: 30,
        areaRank: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        isVerified: true,
      ),
      User(
        id: '5',
        email: 'david@example.com',
        username: 'David Brown',
        role: 'user',
        area: 'Marathahalli',
        reputation: 600,
        points: 900,
        postsCount: 30,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        isVerified: false,
      ),
    ].take(limit).toList();
  }
  
  /// Get mock users for a specific area (replace with real API call)
  List<User> _getMockAreaUsers(String area, int limit) {
    final allUsers = [
      User(
        id: '1',
        email: 'john@example.com',
        username: 'John Doe',
        role: 'user',
        area: 'Koramangala',
        reputation: 850,
        points: 1250,
        postsCount: 40,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isVerified: true,
      ),
      User(
        id: '2',
        email: 'jane@example.com',
        username: 'Jane Smith',
        role: 'user',
        area: 'Indiranagar',
        reputation: 720,
        points: 1020,
        postsCount: 30,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        isVerified: true,
      ),
      User(
        id: '3',
        email: 'mike@example.com',
        username: 'Mike Johnson',
        role: 'user',
        area: 'Whitefield',
        reputation: 680,
        points: 980,
        postsCount: 30,
        areaRank: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        isVerified: false,
      ),
      User(
        id: '4',
        email: 'sarah@example.com',
        username: 'Sarah Wilson',
        role: 'user',
        area: 'Koramangala',
        reputation: 650,
        points: 950,
        postsCount: 30,
        areaRank: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        isVerified: true,
      ),
      User(
        id: '5',
        email: 'david@example.com',
        username: 'David Brown',
        role: 'user',
        area: 'Marathahalli',
        reputation: 600,
        points: 900,
        postsCount: 30,
        areaRank: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        isVerified: false,
      ),
      User(
        id: '6',
        email: 'alex@example.com',
        username: 'Alex Kumar',
        role: 'user',
        area: area,
        reputation: 550,
        points: 850,
        postsCount: 30,
        areaRank: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        isVerified: false,
      ),
      User(
        id: '7',
        email: 'priya@example.com',
        username: 'Priya Sharma',
        role: 'user',
        area: area,
        reputation: 500,
        points: 800,
        postsCount: 30,
        areaRank: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        isVerified: true,
      ),
      User(
        id: '8',
        email: 'raj@example.com',
        username: 'Raj Patel',
        role: 'user',
        area: area,
        reputation: 450,
        points: 750,
        postsCount: 30,
        areaRank: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        isVerified: false,
      ),
    ];
    
    return allUsers
        .where((user) => user.area == area)
        .toList()
        ..sort((a, b) => b.reputation.compareTo(a.reputation))
        ..take(limit);
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Ranking provider
final rankingProvider = StateNotifierProvider<RankingNotifier, RankingState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RankingNotifier(apiService);
});

/// Top users provider
final topUsersProvider = Provider<List<User>>((ref) {
  final rankingState = ref.watch(rankingProvider);
  return rankingState.topUsers;
});

/// Area rankings provider
final areaRankingsProvider = Provider.family<List<User>, String>((ref, area) {
  final rankingState = ref.watch(rankingProvider);
  return rankingState.areaRankings[area] ?? [];
});

/// User area rank provider
final userAreaRankProvider = Provider.family<int, User>((ref, user) {
  final rankingNotifier = ref.watch(rankingProvider.notifier);
  return rankingNotifier.getUserAreaRank(user);
});

/// User points provider
final userPointsProvider = Provider.family<int, User>((ref, user) {
  final rankingNotifier = ref.watch(rankingProvider.notifier);
  // Get posts count from user posts provider
  final userPostsState = ref.watch(userPostsProvider(user.id));
  final postsCount = userPostsState.posts.length;
  return rankingNotifier.calculateUserPoints(user, postsCount);
});

/// Ranking loading state provider
final rankingLoadingProvider = Provider<bool>((ref) {
  final rankingState = ref.watch(rankingProvider);
  return rankingState.isLoading;
});

/// Ranking error provider
final rankingErrorProvider = Provider<String?>((ref) {
  final rankingState = ref.watch(rankingProvider);
  return rankingState.error;
});
