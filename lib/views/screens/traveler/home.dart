import 'package:flutter/material.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/traveler/widgets/traveler_posts_listing.dart';

class HomeTraveler extends StatefulWidget {
  const HomeTraveler({super.key});

  @override
  State<HomeTraveler> createState() => _HomeTravelerState();
}

class _HomeTravelerState extends State<HomeTraveler> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Hardcoded destinations for demo purposes
  final List<String> _destinations = ['All', 'Tunisia', 'Turkey', 'Dubai', 'Saudi Arabia', 'Egypt', 'France', 'Spain'];
  String _selectedDestination = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Destination Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                final isSelected = _selectedDestination == dest;
                final displayDest = dest == 'All' ? 'الكل' : dest; // Simple translation for "All"

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(
                      displayDest,
                      style: TextStyle(
                        fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDestination = dest;
                        });
                      }
                    },
                    selectedColor: AppTheme.lightTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppTheme.lightTheme.primaryColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'الرحلات'), // Trips
                Tab(text: 'الخدمات'), // Services
              ],
              dividerColor: Colors.transparent, // Remove divider
            ),
          ),
          
          const SizedBox(height: 10),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Trips Tab
                TravelerPostsListing(
                  isTrip: true, 
                  destinationFilter: _selectedDestination,
                ),
                // Services Tab
                TravelerPostsListing(
                  isTrip: false, 
                  destinationFilter: _selectedDestination,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}