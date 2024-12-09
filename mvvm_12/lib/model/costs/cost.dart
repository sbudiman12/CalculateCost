import 'package:equatable/equatable.dart';

class Cost extends Equatable {
  final String? service;
  final String? description;
  final int? value;
  final String? etd;
  final String? note;

  const Cost({
    this.service,
    this.description,
    this.value,
    this.etd,
    this.note,
  });

  factory Cost.fromJson(Map<String, dynamic> json) {
    // Mengambil data biaya dari array cost di dalam JSON
    var costData = json['cost'] != null && json['cost'].isNotEmpty
        ? json['cost'][0] // Ambil elemen pertama dari array cost
        : null;

    return Cost(
      service: json['service'] as String?,
      description: json['description'] as String?,
      value: costData?['value'] as int?,
      etd: costData?['etd'] as String?,
      note: costData?['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'service': service,
        'description': description,
        'value': value,
        'etd': etd,
        'note': note,
      };

  @override
  List<Object?> get props => [service, description, value, etd, note];
}
