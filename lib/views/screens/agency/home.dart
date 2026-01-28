import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/views/screens/agency/posts_listing.dart';
import 'package:untitled3/views/screens/agency/submit_documents.dart';
import 'package:untitled3/views/screens/agency/add_post.dart';
import 'package:untitled3/app_localizations.dart';

import '../../../theme/app_theme.dart';
import 'widgets/post_card.dart';

class HomeAgency extends StatefulWidget {
  HomeAgency({Key? key}) : super(key: key);
  @override
  _HomeAgencyState createState() => _HomeAgencyState();
}

class _HomeAgencyState extends State<HomeAgency>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool accountVerified = false;
  bool hasUpdated = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late Stream<DocumentSnapshot> _agencyStream;
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    // Initialize the stream once
    _agencyStream = FirebaseFirestore.instance
        .collection('agencies')
        .doc(user?.uid)
        .snapshots()
        .asBroadcastStream(); // Make it reusable
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthService>(context, listen: false);
    var user = authProvider.currentUser;

    FocusScope.of(context).unfocus();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          waterDropColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: StreamBuilder<DocumentSnapshot>(
          stream: _agencyStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("${user?.uid} WWWWWWWWWWW");

              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              print("${user?.uid} WWWWWWWWWWW");
              return Center(
                  child: Text(
                      AppLocalizations.of(context)!.translate('noDataFound')));
            }

            var agencyData = snapshot.data!.data() as Map<String, dynamic>;
            accountVerified = agencyData['accountVerified'] ?? false;
            bool emailVerified = agencyData['emailVerified'] ?? false;
            bool submittedDocuments = agencyData['submittedDocuments'] ?? false;
            bool documentsAccepted = agencyData['documentsAccepted'] ?? false;
            String profilePictureUrl = agencyData['profilePictureUrl'] ?? '';
            print(agencyData['accountVerified']);

            bool newAccountVerified = agencyData['accountVerified'] ?? false;

            // Only update if the value has changed and hasn't been updated yet
            if (newAccountVerified != accountVerified && !hasUpdated) {
              Future.microtask(() {
                Provider.of<AuthProvider>(context, listen: false)
                    .updateUserField('accountVerified', newAccountVerified)
                    .then((_) {
                  setState(() {
                    hasUpdated = true;
                    accountVerified = newAccountVerified;
                  });
                });
              });
            }

            if (accountVerified) {
              return PostsListing();
            } else {
              return Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Image.asset(
                      'assets/images/account_verify.png', // Make sure to add your logo to assets
                      height: MediaQuery.of(context).size.width * 0.6,
                    ),
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('completeStepsToVerifyAccount'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF313131).withAlpha(200),
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium?.fontFamily,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    !emailVerified
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: InkWell(
                              onTap: () async {
                                await Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .verifyEmail(context);
                              },
                              hoverColor: Colors.transparent,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate(
                                                  'sendVerificationLinkToEmail'),
                                          style: TextStyle(
                                            color: Color(0xFF313131)
                                                .withAlpha(200),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium
                                                ?.fontFamily,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                        ),
                                      ]),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Divider(
                                    color: Colors.black.withAlpha(300),
                                    height: 0,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: InkWell(
                        highlightColor: !emailVerified
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withAlpha(50)
                            : Colors.transparent,
                        onTap: () async {
                          if (!emailVerified) {
                            await Provider.of<AuthProvider>(context,
                                    listen: false)
                                .checkEmailVerification(context)
                                .then((_) async {
                              await Provider.of<AuthService>(context,
                                      listen: false)
                                  .verifyAgencyAccount(user?.uid ?? '');
                            });
                          }
                        },
                        hoverColor: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    !emailVerified
                                        ? AppLocalizations.of(context)!
                                            .translate('checkEmailVerification')
                                        : AppLocalizations.of(context)!
                                            .translate('emailVerified'),
                                    style: TextStyle(
                                      color: Color(0xFF313131).withAlpha(200),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium?.fontFamily,
                                    ),
                                  ),
                                  !emailVerified
                                      ? Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                        )
                                      : Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                ]),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black.withAlpha(300),
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: InkWell(
                        onTap: () async {
                          if (!submittedDocuments) {
                            Navigator.pushNamed(context, '/submit_documents');
                          }
                        },
                        hoverColor: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    !submittedDocuments
                                        ? AppLocalizations.of(context)!
                                            .translate(
                                                'submitRequiredDocuments')
                                        : AppLocalizations.of(context)!
                                            .translate('documentsSubmitted'),
                                    style: TextStyle(
                                      color: Color(0xFF313131).withAlpha(200),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium?.fontFamily,
                                    ),
                                  ),
                                  !submittedDocuments
                                      ? Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                        )
                                      : Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                ]),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black.withAlpha(300),
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: submittedDocuments ? 12 : 0,
                    ),
                    submittedDocuments
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        !documentsAccepted
                                            ? AppLocalizations.of(context)!
                                                .translate(
                                                    'waitingForDocumentVerification')
                                            : AppLocalizations.of(context)!
                                                .translate('documentsVerified'),
                                        style: TextStyle(
                                          color:
                                              Color(0xFF313131).withAlpha(200),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppTheme.lightTheme
                                              .textTheme.bodyMedium?.fontFamily,
                                        ),
                                      ),
                                      !documentsAccepted
                                          ? Icon(
                                              Icons.access_time,
                                              size: 20,
                                              color: Color(0xFF313131)
                                                  .withAlpha(200),
                                            )
                                          : Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                    ]),
                                SizedBox(
                                  height: 8,
                                ),
                                Divider(
                                  color: Colors.black.withAlpha(300),
                                  height: 0,
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: InkWell(
                        onTap: () async {
                          if (profilePictureUrl == '') {
                            await Provider.of<AuthProvider>(context,
                                    listen: false)
                                .uploadProfilePicture(context)
                                .then((_) async {
                              await Provider.of<AuthService>(context,
                                      listen: false)
                                  .verifyAgencyAccount(user?.uid ?? '');
                            });
                          }
                        },
                        hoverColor: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    profilePictureUrl == ""
                                        ? AppLocalizations.of(context)!
                                            .translate('addProfilePicture')
                                        : AppLocalizations.of(context)!
                                            .translate('profilePictureAdded'),
                                    style: TextStyle(
                                      color: Color(0xFF313131).withAlpha(200),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium?.fontFamily,
                                    ),
                                  ),
                                  profilePictureUrl == ''
                                      ? Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                        )
                                      : Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                ]),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black.withAlpha(300),
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: accountVerified
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPost()),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            )
          : null,
    );
  }
}
