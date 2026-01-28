import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../app_localizations.dart';

class SubscriptionGuide extends StatelessWidget {
  const SubscriptionGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    periodGetter(String selectedPeriod) {
      switch (selectedPeriod) {
        case '0':
          return AppLocalizations.of(context)!.translate('month');
        case '1':
          return AppLocalizations.of(context)!.translate('sixMonths');
        case '2':
          return AppLocalizations.of(context)!.translate('year');
        default:
          return AppLocalizations.of(context)!.translate('month');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate('howToPay'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            data['selectedSubscriptionType'].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              color: data['selectedSubscriptionType'].toString() == 'golden'
                  ? Colors.yellow.shade600
                  : AppTheme.lightTheme.primaryColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                periodGetter(data['selectedPeriod'].toString()),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  color: Color(0xFF313131),
                ),
              ),
              SizedBox(width: 8),
              Text(
                data['price'].toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  color: Color(0xFF313131),
                ),
              ),
              SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.translate('dzd'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  color: Color(0xFF313131),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text(
              AppLocalizations.of(context)!.translate('paymentInstructions'),
              textAlign: TextAlign.justify,
              style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                color: Color(0xFF313131).withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            '3200251000518478889225',
            textAlign: TextAlign.justify,
            style: TextStyle(
              height: 1.3,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              color: Color(0xFF313131).withOpacity(0.9),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/submit_payment_confirmation',
                    arguments: data,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.sizeOf(context).width - 40,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('confirmPayment'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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
