part of 'model.dart';

class City extends Equatable {
  final String? cityId;
  final String? provinceId;
  final String? province;
  final String? cityName;
  final String? type;
  final String? postalCode;

  const City({
    this.cityId,
    this.provinceId,
    this.province,
    this.cityName,
    this.type,
    this.postalCode,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        cityId: json['city_id'] as String?,
        provinceId: json['province_id'] as String?,
        province: json['province'] as String?,
        cityName: json['city_name'] as String?,
        type: json['type'] as String?,
        postalCode: json['postal_code'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'province_id': provinceId,
        'province': province,
        'city_name': cityName,
        'type': type,
        'postal_code': postalCode,
      };

  @override
  List<Object?> get props => [cityId, provinceId, province, cityName, type, postalCode];
}
