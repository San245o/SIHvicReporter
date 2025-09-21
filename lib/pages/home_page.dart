import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/animated_bottom_nav.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  String _selectedSort = 'newest';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).fetchPosts(refresh: true);
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts when near bottom
      ref.read(postsProvider.notifier).loadMorePosts();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final postsState = ref.watch(postsProvider);
    final postsNotifier = ref.read(postsProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Reporter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authState.user),
      body: RefreshIndicator(
        onRefresh: () => postsNotifier.refreshPosts(),
        child: Column(
          children: [
            // Sort and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: const Border(
                  bottom: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sort Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSort,
                      dropdownColor: AppTheme.cardColor,
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      decoration: InputDecoration(
                        labelText: 'Sort by',
                        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest', 
                          child: Text(
                            'Newest',
                            style: TextStyle(color: AppTheme.textPrimaryColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'oldest', 
                          child: Text(
                            'Oldest',
                            style: TextStyle(color: AppTheme.textPrimaryColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'most_voted', 
                          child: Text(
                            'Most Voted',
                            style: TextStyle(color: AppTheme.textPrimaryColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'near_me', 
                          child: Text(
                            'Near Me',
                            style: TextStyle(color: AppTheme.textPrimaryColor),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSort = value);
                          postsNotifier.sortPosts(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppTheme.textPrimaryColor,
                      ),
                      onPressed: () => _showFilterBottomSheet(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Posts List
            Expanded(
              child: _buildPostsList(postsState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CivicBottomNavBar(currentIndex: 0),
    );
  }
  
  Widget _buildDrawer(BuildContext context, user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.area ?? 'Unknown Area',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Communities Section
          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Communities'),
            subtitle: Text('Select your area'),
          ),
          ...AppConstants.areas.take(5).map((area) => ListTile(
            leading: const Icon(Icons.circle, size: 8),
            title: Text(area),
            onTap: () {
              Navigator.pop(context);
              ref.read(postsProvider.notifier).filterByArea(area);
            },
          )),
          
          const Divider(),
          
          // Categories Section
          const ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            subtitle: Text('Filter by issue type'),
          ),
          ...AppConstants.categories.take(5).map((category) => ListTile(
            leading: const Icon(Icons.circle, size: 8),
            title: Text(category),
            onTap: () {
              Navigator.pop(context);
              ref.read(postsProvider.notifier).filterByCategory(category);
            },
          )),
          
          const Divider(),
          
          // Profile and Settings
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          
          // Theme Toggle
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              final isDarkMode = themeMode == ThemeMode.dark;
              
              return ListTile(
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.amber : Colors.orange,
                ),
                title: Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  activeThumbColor: AppTheme.secondaryColor,
                  inactiveThumbColor: AppTheme.textSecondaryColor,
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          
          // Admin Panel (only for admins)
          if (user?.isAdmin == true) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin-dashboard');
              },
            ),
          ],
          
          const Divider(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostsList(PostsState postsState) {
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (postsState.error != null && postsState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              postsState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(postsProvider.notifier).refreshPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (postsState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to report an issue in your area',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: postsState.posts.length + (postsState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == postsState.posts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final post = postsState.posts[index];
        return PostCard(
          post: post,
          onTap: () => context.push('/post/${post.id}'),
          onUpvote: () => ref.read(postsProvider.notifier).upvotePost(post.id),
          onDownvote: () => ref.read(postsProvider.notifier).downvotePost(post.id),
        );
      },
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(context),
    );
  }
  
  Widget _buildFilterBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Filter Posts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Area Filter
          DropdownButtonFormField<String>(
            dropdownColor: AppTheme.cardColor,
            style: const TextStyle(color: AppTheme.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Area',
              labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
            ),
            items: [
              const DropdownMenuItem(
                value: null, 
                child: Text(
                  'All Areas',
                  style: TextStyle(color: AppTheme.textPrimaryColor),
                ),
              ),
              ...AppConstants.areas.map((area) => DropdownMenuItem(
                value: area,
                child: Text(
                  area,
                  style: const TextStyle(color: AppTheme.textPrimaryColor),
                ),
              )),
            ],
            onChanged: (value) {
              ref.read(postsProvider.notifier).filterByArea(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Category Filter
          DropdownButtonFormField<String>(
            dropdownColor: AppTheme.cardColor,
            style: const TextStyle(color: AppTheme.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
            ),
            items: [
              const DropdownMenuItem(
                value: null, 
                child: Text(
                  'All Categories',
                  style: TextStyle(color: AppTheme.textPrimaryColor),
                ),
              ),
              ...AppConstants.categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(color: AppTheme.textPrimaryColor),
                ),
              )),
            ],
            onChanged: (value) {
              ref.read(postsProvider.notifier).filterByCategory(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Status Filter
          DropdownButtonFormField<String>(
            dropdownColor: AppTheme.cardColor,
            style: const TextStyle(color: AppTheme.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Status',
              labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
            ),
            items: [
              const DropdownMenuItem(
                value: null, 
                child: Text(
                  'All Statuses',
                  style: TextStyle(color: AppTheme.textPrimaryColor),
                ),
              ),
              ...AppConstants.postStatuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(
                  status,
                  style: const TextStyle(color: AppTheme.textPrimaryColor),
                ),
              )),
            ],
            onChanged: (value) {
              ref.read(postsProvider.notifier).filterByStatus(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Severity Filter
          DropdownButtonFormField<String>(
            dropdownColor: AppTheme.cardColor,
            style: const TextStyle(color: AppTheme.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Severity',
              labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
            ),
            items: [
              const DropdownMenuItem(
                value: null, 
                child: Text(
                  'All Severities',
                  style: TextStyle(color: AppTheme.textPrimaryColor),
                ),
              ),
              ...AppConstants.severityLevels.map((severity) => DropdownMenuItem(
                value: severity,
                child: Text(
                  severity,
                  style: const TextStyle(color: AppTheme.textPrimaryColor),
                ),
              )),
            ],
            onChanged: (value) {
              ref.read(postsProvider.notifier).filterBySeverity(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                    side: const BorderSide(color: AppTheme.secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ref.read(postsProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
