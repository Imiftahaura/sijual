// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['full_name'] as String,
      email: json['email'] as String,
      username: json['username'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'full_name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'token': instance.token,
      'address': instance.address,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
    };
