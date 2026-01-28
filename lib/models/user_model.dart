class UserModel {
  final String id;
  final String travelerFirstName;
  final String travelerLastName;
  final String email;
  final String phone;
  final String userType;
  final bool emailVerified;
  final bool phoneVerified;
  final bool submittedDocuments;
  final bool documentsAccepted;
  final String profilePictureUrl;
  final String profileCoverPictureUrl;
  final String agencyName;
  final String ownerName;
  final bool accountVerified;


  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.userType,
    required this.emailVerified,
    required this.phoneVerified,
    required this.submittedDocuments,
    required this.documentsAccepted,
    required this.profilePictureUrl,
    required this.profileCoverPictureUrl,
    required this.agencyName,
    required this.ownerName,
    required this.travelerFirstName,
    required this.travelerLastName,
    required this.accountVerified,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      phoneVerified: data['phoneVerified'] ?? false,
      submittedDocuments: data['submittedDocuments'] ?? false,
      documentsAccepted: data['documentsAccepted'] ?? false,
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      profileCoverPictureUrl: data['profileCoverPictureUrl'] ?? '',
      agencyName: data['agencyName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      travelerFirstName: data['travelerFirstName'] ?? '',
      travelerLastName: data['travelerLastName'] ?? '',
      accountVerified: data['accountVerified'] ?? false,
    );

  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'userType': userType,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'submittedDocuments': submittedDocuments,
      'documentsAccepted': documentsAccepted,
      'profilePictureUrl': profilePictureUrl,
      'profileCoverPictureUrl': profileCoverPictureUrl,
      'agencyName': agencyName,
      'ownerName': ownerName,
      'travelerFirstName': travelerFirstName,
      'travelerLastName': travelerLastName,
      'accountVerified': accountVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? userType,
    bool? emailVerified,
    bool? phoneVerified,
    bool? submittedDocuments,
    bool? documentsAccepted,
    String? profilePictureUrl,
    String? profileCoverPictureUrl,
    String? agencyName,
    String? ownerName,
    String? travelerFirstName,
    String? travelerLastName,
    bool? accountVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      submittedDocuments: submittedDocuments ?? this.submittedDocuments,
      documentsAccepted: documentsAccepted ?? this.documentsAccepted,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileCoverPictureUrl: profileCoverPictureUrl ?? this.profileCoverPictureUrl,
      agencyName: agencyName ?? this.agencyName,
      ownerName: ownerName ?? this.ownerName,
      travelerFirstName: travelerFirstName ?? this.travelerFirstName,
      travelerLastName: travelerLastName ?? this.travelerLastName,
      accountVerified: accountVerified ?? this.accountVerified,
    );
  }

  UserModel copyWithFromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? this.id,
      email: data['email'] ?? this.email,
      phone: data['phone'] ?? this.phone,
      userType: data['userType'] ?? this.userType,
      emailVerified: data['emailVerified'] ?? this.emailVerified,
      phoneVerified: data['phoneVerified'] ?? this.phoneVerified,
      submittedDocuments: data['submittedDocuments'] ?? this.submittedDocuments,
      documentsAccepted: data['documentsAccepted'] ?? this.documentsAccepted,
      profilePictureUrl: data['profilePictureUrl'] ?? this.profilePictureUrl,
      profileCoverPictureUrl: data['profileCoverPictureUrl'] ?? this.profileCoverPictureUrl,
      agencyName: data['agencyName'] ?? this.agencyName,
      ownerName: data['ownerName'] ?? this.ownerName,
      travelerFirstName: data['travelerFirstName'] ?? this.travelerFirstName,
      travelerLastName: data['travelerLastName'] ?? this.travelerLastName,
      accountVerified: data['accountVerified'] ?? this.accountVerified,
    );
  }
}