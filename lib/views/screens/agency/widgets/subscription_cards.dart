import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/theme/app_theme.dart';

List<Widget> buildSubscriptionCards({
  required String? selectedSubscriptionType,
  required Function(String) onSubscriptionSelect,
  required Function(String, String) priceGetter,
  required int selectedPeriod,
  required BuildContext context,
}) {
  return [
    Transform.scale(
      scale: 0.9,
      child: GestureDetector(
        onTap: () {
          onSubscriptionSelect('starter');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: selectedSubscriptionType != 'starter'
                ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                : Border.all(
                    color:
                        AppTheme.lightTheme.colorScheme.primary.withAlpha(200),
                    width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(2, 3),
              )
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "STARTER",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    color: AppTheme.lightTheme.colorScheme.primary),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('myAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "10",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('adsRenewal'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "05",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('agencyProfile'),
                      // textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('inAppChat'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('accountVerification'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('noInAppAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  color: Color(0xFF313131).withOpacity(0.1),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.translate('price').toString() +
                    " " +
                    priceGetter(selectedPeriod.toString(), 'starter')
                        .toString() +
                    AppLocalizations.of(context)!.translate('dzd').toString(),
                // "${newPrices["starter"] == Null ? prices["starter"] : newPrices["starter"]} السعر دج",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF313131).withAlpha(250),
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Transform.scale(
      scale: 0.9,
      child: GestureDetector(
        onTap: () {
          onSubscriptionSelect('basic');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: selectedSubscriptionType != 'basic'
                ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                : Border.all(
                    color:
                        AppTheme.lightTheme.colorScheme.primary.withAlpha(200),
                    width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(2, 3),
              )
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "BASIC",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    color: AppTheme.lightTheme.colorScheme.primary),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('myAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "20",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('adsRenewal'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "10",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('agencyProfile'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('inAppChat'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('accountVerification'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('inAppAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  color: Color(0xFF313131).withOpacity(0.1),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.translate('price') +
                    " " +
                    priceGetter(selectedPeriod.toString(), 'basic').toString() +
                    AppLocalizations.of(context)!.translate('dzd'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF313131).withAlpha(250),
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Transform.scale(
      scale: 0.9,
      child: GestureDetector(
        onTap: () {
          onSubscriptionSelect('silver');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: selectedSubscriptionType != 'silver'
                ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                : Border.all(
                    color:
                        AppTheme.lightTheme.colorScheme.primary.withAlpha(200),
                    width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(2, 3),
              )
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "SILVER",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    color: AppTheme.lightTheme.colorScheme.primary),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('myAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "10",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('adsRenewal'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "05",
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('agencyProfile'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('inAppChat'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('accountVerification'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('inAppAds'),
                      style: TextStyle(
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF313131).withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Iconsax.close_circle5,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  color: Color(0xFF313131).withOpacity(0.1),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.translate('price') +
                    " " +
                    priceGetter(selectedPeriod.toString(), 'silver')
                        .toString() +
                    AppLocalizations.of(context)!.translate('dzd'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF313131).withAlpha(250),
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Transform.scale(
      scale: 0.9,
      child: GestureDetector(
        onTap: () {
          onSubscriptionSelect('golden');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: selectedSubscriptionType != 'golden'
                ? Border.all(color: Colors.yellow.withOpacity(0.12))
                : Border.all(color: Colors.yellow.withOpacity(0.8), width: 3),
            boxShadow: [
              BoxShadow(
                color: selectedSubscriptionType != 'golden'
                    ? Colors.yellow.shade800.withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 1,
                offset: Offset(2, 3),
              )
            ],
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Container(
                width: 600,
                height: 700,
                // color: Colors.red,
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.yellowAccent.withOpacity(0.1),
                  child: Container(
                    // width: 20,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "GOLDEN",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                        color: Colors.yellow.shade600),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('myAds'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "10",
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w900,
                            color: Colors.yellow.shade500,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('adsRenewal'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "05",
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w900,
                            color: Colors.yellow.shade500,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .translate('agencyProfile'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('inAppChat'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .translate('accountVerification'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('inAppAds'),
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF313131).withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      color: Color(0xFF313131).withOpacity(0.1),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('price') +
                        " " +
                        priceGetter(selectedPeriod.toString(), 'golden')
                            .toString() +
                        AppLocalizations.of(context)!.translate('dzd'),
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.yellow,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}
