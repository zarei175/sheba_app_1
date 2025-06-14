class CardInfo {
  final String cardNumber;
  final String sheba;
  final String ownerName;
  final String bankName;

  CardInfo({
    required this.cardNumber,
    required this.sheba,
    required this.ownerName,
    required this.bankName,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      cardNumber: json['card'] ?? '',
      sheba: json['iban'] ?? '',
      ownerName: json['owner'] ?? '',
      bankName: json['bank'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'sheba': sheba,
      'ownerName': ownerName,
      'bankName': bankName,
    };
  }
}
