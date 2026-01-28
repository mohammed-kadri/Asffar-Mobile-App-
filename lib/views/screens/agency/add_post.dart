import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/models/trip_model.dart';
import 'package:untitled3/models/service_model.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/providers/content_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../../theme/app_theme.dart';

class DestinationsData {
  static final Map<String, List<String>> destinationCities = {
    'turkey': ['istanbul', 'antalya', 'cappadocia', 'trabzon', 'izmir'],
    'tunisia': ['tunis', 'carthage', 'sidi_bou_said', 'sousse', 'hammamet', 'nabeul', 'sfax'],
    'egypt': ['cairo', 'alexandria', 'saeid_misr', 'sharm_el_sheikh', 'sinai'],
    'thailand': ['bangkok', 'ko_phi_phi', 'koh_samui_island', 'chiang_mai'],
    'tanzania': ['zanzibar', 'stone_town', 'fascinating_beaches', 'jozani_forest'],
    'malaysia': ['kuala_lumpur', 'cameron_highlands', 'redang_island', 'penang_linkway'],
    'russia': ['moscow', 'sochi', 'kazan', 'saint_petersburg'],
    'azerbaijan': ['baku', 'fire_mountain', 'ateshgah', 'gobustan', 'quba'],
    'indonesia': ['bali', 'jakarta', 'lombok_island', 'mount_bromo'],
    'uae': ['burj_khalifa', 'dubai_mall', 'dubai_marina', 'desert_safari', 'museum_of_future'],
    'kenya': ['maasai_mara', 'nairobi', 'lake_nakuru', 'mombasa_beach', 'lamu_island'],
    'algeria': ['oran', 'tlemcen', 'ain_temouchent', 'annaba', 'dellys', 'tindouf', 'bejaia', 'jijel']
  };
}

class AddPost extends StatefulWidget {
  final String? postId;  // null = create mode, non-null = edit mode
  final bool? isTrip;    // Required when editing
  
  const AddPost({
    super.key,
    this.postId,
    this.isTrip,
  });

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool _isLoading = false;
  bool isTrip = true;
  String? _selectedCity;

  // Edit mode helpers
  bool get isEditMode => widget.postId != null;
  String? _existingMainImageUrl;
  List<String> _existingSecondaryImageUrls = [];

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _tripPriceController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _departDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _availablePlacesController =
      TextEditingController();
  final TextEditingController _serviceTextFieldController =
      TextEditingController();
  List<String> _texts = [];
  List<File> _images = [];
  File? _mainImage;
  String? _destinations;
  String? _familiale;
  String? _serviceDropdown1;
  String? _serviceDropdown2;
  String? _serviceDropdown3;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      isTrip = widget.isTrip!;
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    try {
      setState(() => _isLoading = true);
      
      final collection = widget.isTrip! ? 'trips' : 'services';
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.postId)
          .get();
      
      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post not found')),
          );
          Navigator.of(context).pop();
        }
        return;
      }
      
      final data = doc.data()!;
      
      setState(() {
        // Common fields
        _descriptionController.text = data['description'] ?? '';
        
        if (widget.isTrip!) {
          // Trip-specific fields
          _tripPriceController.text = data['price'].toString();
          _periodController.text = data['period'].toString();
          _destinations = data['destination'];
          
          if (data['departDate'] != null) {
            final departDate = (data['departDate'] as Timestamp).toDate();
            _departDateController.text = DateFormat('yyyy-MM-dd').format(departDate);
          }
          
          if (data['returnDate'] != null) {
            final returnDate = (data['returnDate'] as Timestamp).toDate();
            _returnDateController.text = DateFormat('yyyy-MM-dd').format(returnDate);
          }
          
          _hotelNameController.text = data['hotelName'] ?? '';
          _familiale = data['family'] == true 
              ? AppLocalizations.of(context)!.translate('yes')
              : AppLocalizations.of(context)!.translate('no');
          
          if (data['places'] != null) {
            _texts = List<String>.from(data['places']);
          }
        } else {
          // Service-specific fields
          _servicePriceController.text = data['price'].toString();
          // Note: Need to reverse localization for dropdowns
          // For now, store the keys directly
          _serviceDropdown1 = data['type'];
          _serviceDropdown2 = data['country'];
          _serviceDropdown3 = data['visaType'];
        }
        
        // Store existing image URLs
        _existingMainImageUrl = data['mainImageUrl'];
        _existingSecondaryImageUrls = data['secondaryImageUrls'] != null
            ? List<String>.from(data['secondaryImageUrls'])
            : [];
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading post data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading post data: $e')),
        );
      }
    }
  }

  Future<String> getLocalizationKeyFromValue(
      String value, String locale) async {
    // Load the correct l10n file based on locale
    String jsonString = await rootBundle.loadString('l10n/$locale.json');
    Map<String, dynamic> map = json.decode(jsonString);

    for (final entry in map.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return 'function works';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<Map<String, dynamic>> checkUserShares(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {
          'error': true,
          'message': 'User not found',
          'premiumShares': 0,
          'freeShares': 0
        };
      }

      return {
        'error': false,
        'premiumShares': doc.data()?['premiumShares'] ?? 0,
        'freeShares': doc.data()?['freeShares'] ?? 0
      };
    } catch (e) {
      return {
        'error': true,
        'message': 'Error checking shares: $e',
        'premiumShares': 0,
        'freeShares': 0
      };
    }
  }

  Future<void> _submitTrip() async {
    final locale = Localizations.localeOf(context).languageCode;
    print(_destinations);
    print(locale);
    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseSelectMainImage'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final departDate =
          DateFormat('yyyy-MM-dd').parse(_departDateController.text);
      final returnDate =
          DateFormat('yyyy-MM-dd').parse(_returnDateController.text);
      if (departDate.isAfter(returnDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('departBeforeReturn'),
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    } catch (e) {
      // If parsing fails, show error and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('departBeforeReturn'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to post',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final shares = await checkUserShares(user.uid);

    if (shares['error']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shares['message'],
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (shares['premiumShares'] == 0 && shares['freeShares'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have used all your available shares',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_tripPriceController.text.isEmpty ||
        _periodController.text.isEmpty ||
        _departDateController.text.isEmpty ||
        _returnDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseCompleteAllFields'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate numeric inputs
    int price = 0;
    int period = 0;
    try {
      int.parse(_tripPriceController.text.trim());
      int.parse(_periodController.text.trim());
      // int.parse(_availablePlacesController.text.trim());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseEnterValidNumbers'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    print('nie ma PROBLEMU');
    // Validate dates
    try {
      final departDate =
          DateFormat('yyyy-MM-dd').parse(_departDateController.text);
      final returnDate =
          DateFormat('yyyy-MM-dd').parse(_returnDateController.text);

      if (departDate.isAfter(returnDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('departBeforeReturn'),
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('invalidDateFormat'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Continue with the rest of your submission code

    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);

    try {
      String mainImageUrl;
      List<String> secondaryImageUrls;
      String postId;

      if (isEditMode) {
        // EDIT MODE - update existing post
        postId = widget.postId!;
        
        // Upload new main image if changed, otherwise use existing
        if (_mainImage != null) {
          mainImageUrl = await contentProvider.uploadImage(postId, _mainImage!, isMain: true);
        } else {
          mainImageUrl = _existingMainImageUrl!;
        }

        // Upload new secondary images if changed, otherwise use existing
        if (_images.isNotEmpty) {
          secondaryImageUrls = await Future.wait(
              _images.map((image) => contentProvider.uploadImage(postId, image)));
        } else {
          secondaryImageUrls = _existingSecondaryImageUrls;
        }

        // Update existing trip
        await FirebaseFirestore.instance.collection('trips').doc(postId).update({
          'destination': _destinations ?? '',
          'period': int.parse(_periodController.text.trim()),
          'price': int.parse(_tripPriceController.text.trim()),
          'departDate': DateFormat('yyyy-MM-dd').parse(_departDateController.text),
          'returnDate': DateFormat('yyyy-MM-dd').parse(_returnDateController.text),
          'family': _familiale == AppLocalizations.of(context)!.translate('yes'),
          'places': _texts,
          'description': _descriptionController.text,
          'mainImageUrl': mainImageUrl,
          'secondaryImageUrls': secondaryImageUrls,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post updated successfully',
              style: TextStyle(
                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // CREATE MODE - create new post
        postId = contentProvider.generateId();
        
        mainImageUrl = await contentProvider.uploadImage(postId, _mainImage!, isMain: true);

        secondaryImageUrls = await Future.wait(
            _images.map((image) => contentProvider.uploadImage(postId, image)));

        final trip = Trip(
          id: postId,
          agencyId: user.uid,
          destination: _destinations ?? '',
          period: int.parse(_periodController.text.trim()),
          price: int.parse(_tripPriceController.text.trim()),
          departDate: DateFormat('yyyy-MM-dd')
              .parse(_departDateController.text), // Parse depart date
          returnDate: DateFormat('yyyy-MM-dd')
              .parse(_returnDateController.text), // Parse return date
          family: _familiale == AppLocalizations.of(context)!.translate('yes'),
          hotelName: '',
          places: _texts,
          description: _descriptionController.text,
          postedDate: DateTime.now(),
          mainImageUrl: mainImageUrl,
          secondaryImageUrls: secondaryImageUrls,
          availablePlaces: 0,
        );

        await contentProvider.addTrip(trip);

        // Deduct shares only when creating new post
        if (shares['premiumShares'] > 0) {
          await FirebaseFirestore.instance
              .collection('subscriptions')
              .doc(user.uid)
              .set({'premiumShares': FieldValue.increment(-1)},
                  SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance
              .collection('subscriptions')
              .doc(user.uid)
              .set({'freeShares': FieldValue.increment(-1)},
                  SetOptions(merge: true));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post created successfully',
              style: TextStyle(
                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error ${isEditMode ? 'updating' : 'creating'} post: $e',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickMainImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickSecondaryImages() async {
    const int maxImages = 5;
    final remainingImages = maxImages - _images.length;

    if (_images.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only upload a maximum of $maxImages images.',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      if (pickedFiles.length > remainingImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select up to $remainingImages more images.',
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _submitService() async {
    final locale = Localizations.localeOf(context).languageCode;

    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseSelectMainImage'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to post',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final shares = await checkUserShares(user.uid);

    if (shares['error']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shares['message'],
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (shares['premiumShares'] == 0 && shares['freeShares'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have used all your available shares',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final postId = contentProvider.generateId();

    try {
      final mainImageUrl =
          await contentProvider.uploadImage(postId, _mainImage!, isMain: true);

      final secondaryImageUrls = await Future.wait(
          _images.map((image) => contentProvider.uploadImage(postId, image)));

      final service = Service(
        id: postId,
        agencyId: user.uid,
        type:
            await getLocalizationKeyFromValue(_serviceDropdown1 ?? '', locale),
        country:
            await getLocalizationKeyFromValue(_serviceDropdown2 ?? '', locale),
        visaType:
            await getLocalizationKeyFromValue(_serviceDropdown3 ?? '', locale),
        price: int.parse(_servicePriceController.text.trim()),
        postedDate: DateTime.now(),
        description: _descriptionController.text,
        mainImageUrl: mainImageUrl,
        secondaryImageUrls: secondaryImageUrls,
      );

      await contentProvider.addService(service);

      if (shares['premiumShares'] > 0) {
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(user.uid)
            .set(
                {'premiumShares': FieldValue.increment(-1)},
                SetOptions(
                  merge: true,
                ));
      } else {
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(user.uid)
            .set({'freeShares': FieldValue.increment(-1)},
                SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Service posted successfully',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
      var test = await FirebaseFirestore.instance
          .collection("subscriptions")
          .where("agencyId", isEqualTo: user.uid)
          .get();
      print(user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error creating service: $e',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = true;
      });
    }
  }

  void _resetAllFields() {
    _images = [];
    _mainImage = null;
    _serviceTextFieldController.clear();
    _destinationController.clear();
    _destinations = null;
    _periodController.clear();
    _tripPriceController.clear();
    _servicePriceController.clear();
    _departDateController.clear();
    _returnDateController.clear();
    _availablePlacesController.clear();
    _hotelNameController.clear();
    _texts = [];
    _serviceDropdown1 = null;
    _serviceDropdown2 = null;
    _serviceDropdown3 = null;
    _familiale = null;
    _textController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

//final serviceTypeKey = await getLocalizationKeyFromValue(_serviceDropdown1 ?? '', locale);
//final countryKey = await getLocalizationKeyFromValue(_serviceDropdown2 ?? '', locale);
//final typeKey = await getLocalizationKeyFromValue(_serviceDropdown3 ?? '', locale);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Color(0xFF313131).withOpacity(0.1),
              height: 1,
            )),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate('addPost'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          splashRadius: 24,
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: isEditMode
                            ? null
                            : () {
                                setState(() {
                                  if (!isTrip) {
                                    _resetAllFields();
                                  }
                                  isTrip = true;
                                });
                              },
                        child: Container(
                          width: (screenWidth - 50 - 10) / 2,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: !isTrip
                                  ? Color(0xFF313131).withOpacity(0.25)
                                  : AppTheme.lightTheme.colorScheme.primary,
                              width: !isTrip ? 1 : 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.routing_2,
                                size: 75,
                                color: !isTrip
                                    ? Color(0xFF313131).withOpacity(0.25)
                                    : AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                AppLocalizations.of(context)!.translate('trip'),
                                style: TextStyle(
                                    fontSize: 19,
                                    color: !isTrip
                                        ? Color(0xFF313131).withOpacity(0.25)
                                        : AppTheme
                                            .lightTheme.colorScheme.primary,
                                    fontWeight: !isTrip
                                        ? FontWeight.w600
                                        : FontWeight.w900,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: isEditMode
                            ? null
                            : () {
                                setState(() {
                                  if (isTrip) {
                                    _resetAllFields();
                                  }
                                  isTrip = false;
                                });
                              },
                        child: Container(
                          width: (screenWidth - 50 - 10) / 2,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isTrip
                                  ? Color(0xFF313131).withOpacity(0.25)
                                  : AppTheme.lightTheme.colorScheme.primary,
                              width: isTrip ? 1 : 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.briefcase,
                                size: 70,
                                color: isTrip
                                    ? Color(0xFF313131).withOpacity(0.25)
                                    : AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('service'),
                                style: TextStyle(
                                    fontSize: 19,
                                    color: isTrip
                                        ? Color(0xFF313131).withOpacity(0.25)
                                        : AppTheme
                                            .lightTheme.colorScheme.primary,
                                    fontWeight: isTrip
                                        ? FontWeight.w600
                                        : FontWeight.w900,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (isTrip) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _destinations,
                      onChanged: (value) {
                        setState(() {
                          _texts = [];
                          _selectedCity = null;
                          _destinations = value;
                        });
                      },
                      items: DestinationsData.destinationCities.keys
                          .map((destination) => DropdownMenuItem(
                                value: destination, // Show translated text
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .translate(destination),
                                      style: TextStyle(
                                          fontFamily: AppTheme.lightTheme
                                              .textTheme.bodyMedium!.fontFamily,
                                          color:
                                              Color(0xFF313131).withAlpha(100),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        label: Text(
                          AppLocalizations.of(context)!
                              .translate('destination'),
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(100),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                      ),
                      icon: SizedBox.shrink(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tripPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('priceDa'),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF313131).withAlpha(100),
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF313131).withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _periodController,
                            decoration: InputDecoration(
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('duration'),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF313131).withAlpha(100),
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF313131).withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _departDateController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Iconsax.calendar,
                                color: Color(0xFF313131).withOpacity(0.3),
                              ),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('departureDate'),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF313131).withAlpha(100),
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF313131).withOpacity(0.1),
                                ),
                              ),
                            ),
                            onTap: () => _pickDate(_departDateController),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _returnDateController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Iconsax.calendar,
                                color: Color(0xFF313131).withOpacity(0.3),
                              ),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('returnDate'),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF313131).withAlpha(100),
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF313131).withOpacity(0.1),
                                ),
                              ),
                            ),
                            onTap: () => _pickDate(_returnDateController),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCity,
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },
                            items: _destinations != null &&
                                    DestinationsData.destinationCities
                                        .containsKey(_destinations)
                                ? DestinationsData
                                    .destinationCities[_destinations]!
                                    .map((city) => DropdownMenuItem(
                                          value: city,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .translate(city),
                                            style: TextStyle(
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                              color: Color(0xFF313131)
                                                  .withAlpha(100),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ))
                                    .toList()
                                : [],
                            decoration: InputDecoration(
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('placesToVisit'),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF313131).withAlpha(200)),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (_selectedCity != null &&
                                !_texts.contains(_selectedCity)) {
                              setState(() {
                                _texts.add(_selectedCity!);
                                _selectedCity =
                                    null; // Reset selection after adding
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: _texts
                          .map((text) => Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .translate(text),
                                          style: TextStyle(
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                              color: Color(0xFF313131)
                                                  .withAlpha(100),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16))),
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        _texts.remove(text);
                                      });
                                    },
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        label: Text(
                          AppLocalizations.of(context)!
                              .translate('description'),
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(100),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    if (!isEditMode) ...[
                      SizedBox(height: 15),
                      Row(
                        children: [
                          InkWell(
                              onTap: _pickMainImage,
                              child: Container(
                                width: (screenWidth * 0.55) - 25,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: AppTheme.lightTheme.colorScheme!.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('mainImage'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppTheme.lightTheme.textTheme
                                            .bodyMedium!.fontFamily,
                                        color: AppTheme
                                            .lightTheme.colorScheme!.primary,
                                        backgroundColor: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                              onTap: _pickSecondaryImages,
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('additionalImages'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppTheme.lightTheme.textTheme
                                            .bodyMedium!.fontFamily,
                                        color: Color(0xFF313131).withOpacity(0.5),
                                        backgroundColor: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                width: (screenWidth * 0.45) - 25,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: Color(0xFF313131).withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                    SizedBox(height: 15),
                    if (_mainImage != null) ...[
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .translate('mainImage'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF313131).withAlpha(200),
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_mainImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _mainImage = null;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.translate('delete'),
                              style: TextStyle(
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                    _images.length != 0
                        ? Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('additionalImages'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF313131).withAlpha(200),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              )
                            ],
                          )
                        : SizedBox.shrink(),
                    Wrap(
                      children: _images
                          .map((image) => Column(
                                children: [
                                  Image.file(image, width: 100, height: 100),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _images.remove(image);
                                        });
                                      },
                                      child: Text(
                                        'حذف',
                                        style: TextStyle(
                                          fontFamily: AppTheme.lightTheme
                                              .textTheme.bodyMedium!.fontFamily,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )),
                                ],
                              ))
                          .toList(),
                    ),
                  ] else ...[
                    DropdownButtonFormField<String>(
                      icon: SizedBox(),
                      value: _serviceDropdown1,
                      onChanged: (value) {
                        setState(() {
                          _serviceDropdown1 = value;
                        });
                      },
                      items: [
                        AppLocalizations.of(context)!.translate('visas'),
                        AppLocalizations.of(context)!
                            .translate('visaAppointments'),
                        AppLocalizations.of(context)!
                            .translate('flightTickets'),
                      ]
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(
                                  option,
                                  style: TextStyle(
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Color(0xFF313131).withAlpha(100),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17),
                                ),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        label: Text(
                          AppLocalizations.of(context)!
                              .translate('serviceType'),
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(100),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      icon: SizedBox(),
                      value: _serviceDropdown2,
                      onChanged: (value) {
                        setState(() {
                          _serviceDropdown2 = value;
                        });
                      },
                      items: [
                        AppLocalizations.of(context)!.translate('france'),
                        AppLocalizations.of(context)!.translate('germany'),
                        AppLocalizations.of(context)!.translate('turkey'),
                        AppLocalizations.of(context)!.translate('dubai'),
                        AppLocalizations.of(context)!.translate('qatar'),
                        AppLocalizations.of(context)!.translate('egypt'),
                        AppLocalizations.of(context)!.translate('spain'),
                        AppLocalizations.of(context)!
                            .translate('unitedKingdom'),
                        AppLocalizations.of(context)!.translate('usa'),
                        AppLocalizations.of(context)!.translate('canada'),
                        AppLocalizations.of(context)!.translate('belgium'),
                        AppLocalizations.of(context)!.translate('poland'),
                        AppLocalizations.of(context)!.translate('portugal'),
                        AppLocalizations.of(context)!.translate('netherlands'),
                        AppLocalizations.of(context)!.translate('russia'),
                      ]
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(
                                  option,
                                  style: TextStyle(
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Color(0xFF313131).withAlpha(100),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17),
                                ),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        label: Text(
                          AppLocalizations.of(context)!.translate('country'),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(100),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _servicePriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('priceDa'),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF313131).withAlpha(100),
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF313131).withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        _serviceDropdown1 ==
                                AppLocalizations.of(context)!
                                    .translate('flightTickets')
                            ? SizedBox.shrink()
                            : Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _serviceDropdown3,
                                  icon: SizedBox(),
                                  onChanged: (value) {
                                    setState(() {
                                      _serviceDropdown3 = value;
                                    });
                                  },
                                  items: [
                                    AppLocalizations.of(context)!
                                        .translate('study'),
                                    AppLocalizations.of(context)!
                                        .translate('work'),
                                    AppLocalizations.of(context)!
                                        .translate('tourist'),
                                    AppLocalizations.of(context)!
                                        .translate('business'),
                                    AppLocalizations.of(context)!
                                        .translate('medical'),
                                  ]
                                      .map((option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(
                                              option,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontFamily: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .fontFamily,
                                                  color: Color(0xFF313131)
                                                      .withAlpha(100),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17),
                                            ),
                                          ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    label: Text(
                                      AppLocalizations.of(context)!
                                          .translate('type'),
                                      // textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color:
                                              Color(0xFF313131).withAlpha(100),
                                          fontFamily: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodyMedium!
                                              .fontFamily),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color(0xFF313131).withAlpha(200)),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        label: Text(
                          AppLocalizations.of(context)!
                              .translate('description'),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(100),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        InkWell(
                            onTap: _pickMainImage,
                            child: Container(
                              width: (screenWidth * 0.55) - 25,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme!.primary,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('mainImage'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: AppTheme
                                          .lightTheme.colorScheme!.primary,
                                      backgroundColor: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: _pickSecondaryImages,
                            child: Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('additionalImages'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Color(0xFF313131).withOpacity(0.5),
                                      backgroundColor: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              width: (screenWidth * 0.45) - 25,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: Color(0xFF313131).withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(height: 15),
                    if (_mainImage != null) ...[
                      Text(
                        AppLocalizations.of(context)!.translate('mainImage'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF313131).withAlpha(200),
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_mainImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _mainImage = null;
                              });
                            },
                            child: Text(
                              'حذف',
                              style: TextStyle(
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                    _images.length != 0
                        ? Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('additionalImages'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF313131).withAlpha(200),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              )
                            ],
                          )
                        : SizedBox.shrink(),
                    Wrap(
                      children: _images
                          .map((image) => Column(
                                children: [
                                  Image.file(image, width: 100, height: 100),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _images.remove(image);
                                        });
                                      },
                                      child: Text(
                                        'حذف',
                                        style: TextStyle(
                                          fontFamily: AppTheme.lightTheme
                                              .textTheme.bodyMedium!.fontFamily,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )),
                                ],
                              ))
                          .toList(),
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            if (isTrip) {
                              _submitTrip();
                              print(_tripPriceController.text +
                                  "  " +
                                  _periodController.text);
                            } else {
                              _submitService();
                            }
                          },
                          child: Container(
                            width: screenWidth - 40,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme!.primary,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('publish'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: SpinKitChasingDots(
                  color: AppTheme.lightTheme.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
