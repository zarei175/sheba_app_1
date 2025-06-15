class HistoryItem {
  final int? id;
  final String cardNumber;
  final String sheba;
  final String ownerName;
  final String bankName;
  final DateTime timestamp;

  HistoryItem({
    this.id,
    required this.cardNumber,
    required this.sheba,
    required this.ownerName,
    required this.bankName,
    required this.timestamp,
  });

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      cardNumber: map['cardNumber'],
      sheba: map['sheba'],
      ownerName: map['ownerName'],
      bankName: map['bankName'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'sheba': sheba,
      'ownerName': ownerName,
      'bankName': bankName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
