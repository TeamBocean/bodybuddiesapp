bool hasCompletedProfile(Map<String, dynamic>? data) {
  if (data == null) {
    return false;
  }

  if (data['profile_completed'] == true) {
    return true;
  }

  final name = (data['name'] as String?)?.trim() ?? '';
  final weight = parseProfileWeight(data['weight']);

  return name.length >= 2 && weight > 0;
}

int parseProfileWeight(dynamic value) {
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
