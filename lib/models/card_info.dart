class CardInfo {
  final String cardNumber;
  final String sheba;
  final String ownerName;
  final String bankName;
  final String? accountNumber; // Added accountNumber

  CardInfo({
    required this.cardNumber,
    required this.sheba,
    required this.ownerName,
    required this.bankName,
    this.accountNumber,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      cardNumber: json["card"] ?? 
      json["cardNumber"] ?? 
      "",
      sheba: json["iban"] ?? 
      json["sheba"] ?? 
      "",
      ownerName: json["owner"] ?? 
      json["ownerName"] ?? 
      "",
      bankName: json["bank"] ?? 
      json["bankName"] ?? 
      "",
      accountNumber: json["accountNumber"] ?? 
      json["account"] ?? 
      null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cardNumber": cardNumber,
      "sheba": sheba,
      "ownerName": ownerName,
      "bankName": bankName,
      "accountNumber": accountNumber,
    };
  }
}


