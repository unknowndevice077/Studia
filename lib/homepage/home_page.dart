import 'navbar/classes.dart';
import 'navbar/notes/notes.dart';
import 'navbar/events.dart';
import 'navbar/homecontent.dart';
// TODO: Update the import path below to the correct location of study.dart, or create the file if it doesn't exist.
import 'package:app/homepage/navbar/Study/study.dart';
import 'navbar/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/profile_picture_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/theme/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _userAvatarIndex = 0;
  String _customUsername = '';
  bool _isEditingNote = false;

  late PageController _pageController;
  List<AnimationController> _pageAnimationControllers = [];
  List<Animation<double>> _pageAnimations = [];
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    try {
      _pageAnimationControllers = List.generate(
        5,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        ),
      );
      _pageAnimations = _pageAnimationControllers.map((controller) {
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));
      }).toList();
      _animationsInitialized = true;
      _pageAnimationControllers[0].forward();
    } catch (e) {
      print('Error initializing animations: $e');
    }
  }

  @override
  void dispose() {
    try {
      for (var controller in _pageAnimationControllers) {
        controller.dispose();
      }
      _pageController.dispose();
    } catch (e) {
      print('Error disposing animations: $e');
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userUID = FirebaseAuth.instance.currentUser?.uid;

    if (userUID != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userUID)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _userAvatarIndex = userData['avatarIndex'] ?? 0;
              _customUsername = userData['username'] ?? '';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userAvatarIndex = prefs.getInt('user_avatar_index') ?? 0;
            _customUsername = prefs.getString('custom_username') ?? '';
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex || !_animationsInitialized) return;

    setState(() {
      if (_selectedIndex < _pageAnimationControllers.length) {
        _pageAnimationControllers[_selectedIndex].reset();
      }
      _selectedIndex = index;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _selectedIndex < _pageAnimationControllers.length) {
          _pageAnimationControllers[_selectedIndex].forward();
        }
      });
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _getAnimatedPage(int index, Widget page) {
    if (!_animationsInitialized || index >= _pageAnimations.length) {
      return page;
    }
    return FadeTransition(
      opacity: _pageAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _pageAnimationControllers[index],
          curve: Curves.easeOutCubic,
        )),
        child: page,
      ),
    );
  }

  Widget _buildHomePage() {
    return _getAnimatedPage(
      0,
      Homecontent(
        username: _customUsername.isNotEmpty ? _customUsername : null,
      ),
    );
  }

  Widget _buildNotesPage() {
    return _getAnimatedPage(
      1,
      NotesScreen(
        onNoteEditingChanged: (isEditing) {
          setState(() {
            _isEditingNote = isEditing;
          });
          print('📝 Note editing changed: $isEditing');
        },
      ),
    );
  }

  Widget _buildStudyPage() {
    return _getAnimatedPage(2, const Study());
  }

  Widget _buildEventsPage() {
    return _getAnimatedPage(3, const Events());
  }

  Widget _buildClassesPage() {
    return _getAnimatedPage(4, const Classes());
  }

  Widget _buildBottomNavbar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(12), // Reduced from 16
      padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 12
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(23), // Reduced from 25
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 15, // Reduced from 20
            offset: const Offset(0, 3), // Reduced from 5
          ),
        ],
      ),
      child: screenWidth > 350 // Lowered threshold from 400
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.note, 'Notes', 1),
                _buildNavItem(Icons.school, 'Study', 2),
                _buildNavItem(Icons.event, 'Events', 3),
                _buildNavItem(Icons.class_, 'Classes', 4),
              ],
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 12, // Reduced from 16
              runSpacing: 6, // Reduced from 8
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.note, 'Notes', 1),
                _buildNavItem(Icons.school, 'Study', 2),
                _buildNavItem(Icons.event, 'Events', 3),
                _buildNavItem(Icons.class_, 'Classes', 4),
              ],
            ),
    );
  }

  static const _navIcons = [Icons.home, Icons.note, Icons.school, Icons.event, Icons.class_];
  static const _navLabels = ['Home', 'Notes', 'Study', 'Events', 'Classes'];

  /// Desktop/wide layout: a persistent side rail instead of a bottom bar,
  /// so the nav doesn't stretch into a handful of icons scattered across a
  /// wide browser window.
  Widget _buildNavigationRail() {
    return NavigationRail(
      backgroundColor: context.scheme.surface,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      minWidth: 84,
      leading: const SizedBox(height: 12),
      selectedIconTheme: IconThemeData(color: context.scheme.primary),
      selectedLabelTextStyle: TextStyle(
        color: context.scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedIconTheme: IconThemeData(color: context.scheme.onSurfaceVariant),
      unselectedLabelTextStyle: TextStyle(color: context.scheme.onSurfaceVariant),
      destinations: [
        for (var i = 0; i < _navIcons.length; i++)
          NavigationRailDestination(
            icon: Icon(_navIcons[i]),
            selectedIcon: Icon(_navIcons[i]),
            label: Text(_navLabels[i]),
          ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final primaryColor = context.scheme.primary;
    final inactiveColor = context.scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced from 16, 8
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // Reduced from 15
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 20, // Reduced from 24
            ),
            const SizedBox(height: 2), // Reduced from 4
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : inactiveColor,
                fontSize: 10, // Reduced from 12
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final username = _customUsername.isNotEmpty
        ? _customUsername
        : (email.contains('@') ? email.split('@')[0] : email);

    return Drawer(
      backgroundColor: context.scheme.surface,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: context.scheme.surface,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfile(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.scheme.outlineVariant,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Consumer<ProfilePictureProvider>(
                        builder: (context, profileProvider, child) {
                          return profileProvider.getProfilePictureWidget(
                            radius: 35,
                            showEditIcon: false,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username or trimmed email
                  Text(
                    username,
                    style: TextStyle(
                      color: context.scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Always show full email below
                  Text(
                    email,
                    style: TextStyle(
                      color: context.scheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Items (only Profile remains)
          Expanded(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: context.scheme.onSurface,
                  ),
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      color: context.scheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfile(),
                      ),
                    );
                  },
                ),
                
                // Add more menu items here if needed in the future
                // ListTile(
                //   leading: Icon(Icons.settings),
                //   title: Text('Settings'),
                //   onTap: () {},
                // ),
              ],
            ),
          ),
          
          // Add some bottom padding for better spacing
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          if (_selectedIndex < _pageAnimationControllers.length) {
            _pageAnimationControllers[_selectedIndex].reset();
          }
          _selectedIndex = index;
          if (_selectedIndex < _pageAnimationControllers.length) {
            _isEditingNote = false;
            _pageAnimationControllers[_selectedIndex].forward();
          }
        });
      },
      children: [
        _buildHomePage(),
        _buildNotesPage(),
        _buildStudyPage(),
        _buildEventsPage(),
        _buildClassesPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Desktop/wide viewports get a persistent side rail instead of a bottom
    // bar — a bottom bar with 5 icons spaced across a 1400px+ window looks
    // sparse and stretched, a side rail reads as an intentional app shell.
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: context.scheme.surface,
        endDrawer: _buildDrawer(),
        body: SafeArea(
          child: Row(
            children: [
              _buildNavigationRail(),
              VerticalDivider(width: 1, color: context.scheme.outlineVariant),
              Expanded(child: _buildPageView()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scheme.surface,
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildPageView()),
            if (!_isEditingNote)
              ResponsiveContent(
                maxWidth: 640,
                child: _buildBottomNavbar(),
              ),
          ],
        ),
      ),
    );
  }
}