import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/traveler/home.dart';
import 'package:untitled3/views/screens/traveler/favorites_page.dart';
import 'package:untitled3/views/screens/traveler/traveler_chat_list.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/services/auth_service.dart';

class TravelerNavbar extends StatefulWidget {
  const TravelerNavbar({super.key});

  @override
  State<TravelerNavbar> createState() => _TravelerNavbarState();
}

class _TravelerNavbarState extends State<TravelerNavbar> {
  int _selectedIndex = 0;
  
  // Pages
  final List<Widget> _pages = [
    HomeTraveler(),
    FavoritesPage(),
    TravelerChatList(),
    const Center(child: Text('Profile Page')), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'الرئيسية' // Home
              : _selectedIndex == 1
                  ? 'المفضلة' // Favorites
                  : _selectedIndex == 2
                      ? 'الرسائل' // Messages
                      : 'الصفحة الشخصية', // Profile
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.lightTheme.primaryColor),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  'القائمة', // Menu
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.home),
              title: Text(
                'الرئيسية',
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.heart),
              title: Text(
                'المفضلة',
                 style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                'تغيير اللغة', // Change Language
                 style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                // Navigator.pushNamed(context, '/change_language');
              },
            ),
             ListTile(
              leading: const Icon(Icons.support_agent),
              title: Text(
                'الدعم الفني', // Contact Support
                 style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                // Navigator.pushNamed(context, '/contact_support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'تسجيل الخروج', // Logout
                 style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () async {
                await Provider.of<AuthService>(context, listen: false).signOut(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: AppTheme.lightTheme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            rippleColor: Colors.white,
            color: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            tabs: [
              GButton(
                icon: _selectedIndex == 0 ? Iconsax.home5 : Iconsax.home,
                text: 'الرئيسية',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              GButton(
                icon: _selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
                text: 'المفضلة',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              GButton(
                icon: _selectedIndex == 2 ? Iconsax.message5 : Iconsax.message,
                text: 'الرسائل',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              GButton(
                 icon: _selectedIndex == 3 ? Iconsax.profile_circle5 : Iconsax.profile_circle,
                text: 'حسابي',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
