import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/providers/content_provider.dart';
import 'package:untitled3/providers/messaging_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/services/content_service.dart';
import 'package:untitled3/views/screens/agency/add_post.dart';
import 'package:untitled3/views/screens/agency/agency_edit_profile.dart';
import 'package:untitled3/views/screens/agency/agency_navbar.dart';
import 'package:untitled3/views/screens/agency/contact_support.dart';
import 'package:untitled3/views/screens/agency/home.dart';
import 'package:untitled3/views/screens/agency/submit_documents.dart';
import 'package:untitled3/views/screens/agency/submit_payment_confirmation.dart';
import 'package:untitled3/views/screens/agency/subscription_guide.dart';
import 'package:untitled3/views/screens/agency/subscriptions.dart';
import 'package:untitled3/views/screens/auth/forgot_password.dart';
import 'package:untitled3/views/screens/auth/login_traveler.dart';
import 'package:untitled3/views/screens/auth/login_agency.dart';
import 'package:untitled3/views/screens/auth/register_traveler.dart';
import 'package:untitled3/views/screens/auth/register_agency.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/views/screens/change_language.dart';
import 'package:untitled3/views/screens/splash_screen.dart';
import 'package:untitled3/views/screens/traveler/home.dart';
import 'firebase_options.dart';
import 'package:untitled3/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LocaleProvider localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  MyApp({required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ContentService()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => localeProvider),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            supportedLocales: [
              Locale('en', ''), // English
              Locale('fr', ''), // French
              Locale('ar', ''), // Arabic
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: localeProvider.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              return supportedLocales.contains(locale)
                  ? locale
                  : Locale('en', '');
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: '/splash_screen',
            routes: {
              '/login_traveler': (context) => LoginTraveler(),
              '/login_agency': (context) => LoginAgency(),
              '/register_traveler': (context) => RegisterTraveler(),
              '/register_agency': (context) => RegisterAgency(),
              '/forgot_password': (context) => ForgotPassword(),
              '/home_traveler': (context) => HomeTraveler(),
              '/home_agency': (context) => HomeAgency(),
              '/submit_documents': (context) => SubmitDocuments(),
              '/splash_screen': (context) => SplashScreen(),
              '/add_post': (context) => AddPost(),
              '/subscriptions': (context) => SubscribePage(),
              '/agency_edit_profile': (context) => AgencyEditProfile(),
              '/change_language': (context) => ChangeLanguage(),
              '/subscription_guide': (context) => SubscriptionGuide(),
              '/submit_payment_confirmation': (context) =>
                  SubmitPaymentConfirmation(),
              '/agency_navbar': (context) => AgencyNavbar(),
              '/contact_support': (context) => ContactSupport(),
            },
          );
        },
      ),
    );
  }
}
