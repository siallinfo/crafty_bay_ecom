import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.city,
    required super.address,
    required super.email,
    required super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> response) {
    var data = _asStringMap(response['data']) ?? response;
    data = _asStringMap(data['user']) ?? _asStringMap(data['profile']) ?? data;

    String read(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    final name = read(['name', 'full_name', 'fullName']);
    final nameParts = name.split(RegExp(r'\s+'));
    final apiFirstName = read(['first_name', 'firstName']);
    final apiLastName = read(['last_name', 'lastName']);

    return UserProfileModel(
      firstName: apiFirstName.isNotEmpty ? apiFirstName : nameParts.first,
      lastName: apiLastName.isNotEmpty
          ? apiLastName
          : nameParts.length > 1
          ? nameParts.skip(1).join(' ')
          : '',
      phone: read(['phone', 'mobile', 'phone_number']),
      city: read(['city']),
      address: read(['address', 'shipping_address']),
      email: read(['email']),
      avatarUrl: switch (read(['avatar_url', 'avatar', 'photo'])) {
        '' => null,
        final url => url,
      },
    );
  }

  static Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
