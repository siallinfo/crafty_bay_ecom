class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.address,
    required this.email,
    required this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String city;
  final String address;
  final String email;
  final String? avatarUrl;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName.substring(0, 1) : '';
    final last = lastName.isNotEmpty ? lastName.substring(0, 1) : '';
    final result = '$first$last'.trim();
    if (result.isNotEmpty) return result.toUpperCase();
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? address,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
