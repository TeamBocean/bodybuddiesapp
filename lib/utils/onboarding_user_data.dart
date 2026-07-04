Map<String, dynamic> buildOnboardingProfileFields({
  required String name,
  required int weight,
  String email = '',
}) {
  final trimmedEmail = email.trim();
  final profileData = <String, dynamic>{
    'name': name.trim(),
    'weight': weight,
    'profile_completed': true,
  };

  if (trimmedEmail.isNotEmpty) {
    profileData['email'] = trimmedEmail.toLowerCase();
  }

  return profileData;
}

Map<String, dynamic> buildNewUserAccountDefaults() {
  return {
    'credits': 0,
    'bookings': <dynamic>[],
    'subscriptions': <dynamic>[],
    'active': false,
    'credit_type': '',
  };
}

Map<String, dynamic> buildOnboardingUserData({
  required bool documentExists,
  required String name,
  required int weight,
  String email = '',
}) {
  final profileData = buildOnboardingProfileFields(
    name: name,
    weight: weight,
    email: email,
  );

  if (documentExists) {
    return profileData;
  }

  return {
    ...profileData,
    ...buildNewUserAccountDefaults(),
  };
}

bool isOnboardingWriteVerified(Map<String, dynamic>? data) {
  if (data == null) {
    return false;
  }

  return data['profile_completed'] == true &&
      ((data['name'] as String?)?.trim().length ?? 0) >= 2 &&
      _parseWeight(data['weight']) > 0;
}

int _parseWeight(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}
