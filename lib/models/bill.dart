import 'billed_item.dart';

class Bill {
  final String id;
  final String customerPhone;
  final String customerName;
  final DateTime dateTime;
  final List<BilledItem> items;
  final int subtotalPaise;
  final int discountPaise;
  final int grandTotalPaise;

  Bill({
    required this.id,
    required this.customerPhone,
    required this.customerName,
    required this.dateTime,
    required this.items,
    required this.subtotalPaise,
    required this.discountPaise,
    required this.grandTotalPaise,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Bill.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((e) => BilledItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Bill(
      id: json['id']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      dateTime: DateTime.tryParse(json['dateTime']?.toString() ?? '') ?? DateTime.now(),
      items: items,
      subtotalPaise: (json['subtotalPaise'] as num?)?.toInt() ?? 0,
      discountPaise: (json['discountPaise'] as num?)?.toInt() ?? 0,
      grandTotalPaise: (json['grandTotalPaise'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerPhone': customerPhone,
      'customerName': customerName,
      'dateTime': dateTime.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotalPaise': subtotalPaise,
      'discountPaise': discountPaise,
      'grandTotalPaise': grandTotalPaise,
    };
  }
}
