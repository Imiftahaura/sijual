import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;

  @JsonKey(name: 'full_name') 
  final String name; 

  final String email;

  @JsonKey(defaultValue: '')
  final String? username; 

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  
  final String? role;

  // --- TAMBAHKAN INI ---
  final String? token; 
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phoneNumber,
    this.role,
    this.token, 
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}