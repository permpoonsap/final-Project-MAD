class CryptoCurrency {
  int? keyID; 
  String name;
  double price;
  DateTime? lastUpdated;

  CryptoCurrency({this.keyID, required this.name, required this.price, this.lastUpdated});
}
