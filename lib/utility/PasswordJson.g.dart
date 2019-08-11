// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PasswordJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordJson _$PasswordJsonFromJson(Map<String, dynamic> json) {
  return PasswordJson(
      json['id'] as int,
      json['tipo'] as int,
      json['password'] as String);
}

Map<String, dynamic> _$PasswordJsonToJson(PasswordJson instance) =>
    <String, dynamic>{
      'password': instance.password,
      'tipo': instance.tipo,
      'id': instance.id
    };
