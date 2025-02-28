import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:account/model/cryptoCurrency.dart';
import 'package:account/database/cryptoDB.dart';

class CryptoProvider with ChangeNotifier {
  List<CryptoCurrency> cryptos = [];
  double exchangeRate = 35.0; 

  Future<void> fetchCryptoData() async {
    try {
      
      final btcUrl = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT');
      final ethUrl = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT');
      final dogeUrl = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=DOGEUSDT');

      final btcResponse = await http.get(btcUrl);
      final ethResponse = await http.get(ethUrl);
      final dogeResponse = await http.get(dogeUrl);

      if (btcResponse.statusCode == 200 &&
          ethResponse.statusCode == 200 &&
          dogeResponse.statusCode == 200) {
        final btcData = json.decode(btcResponse.body);
        final ethData = json.decode(ethResponse.body);
        final dogeData = json.decode(dogeResponse.body);

        
        final usdtToThbUrl = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=USDTTHB');
        final usdtToThbResponse = await http.get(usdtToThbUrl);
        if (usdtToThbResponse.statusCode == 200) {
          final usdtData = json.decode(usdtToThbResponse.body);
          exchangeRate = double.parse(usdtData['price']); 
        }

        
        List<CryptoCurrency> updatedCryptos = [
          CryptoCurrency(
              keyID: 1,
              name: "Bitcoin",
              price: double.parse(btcData['price']) * exchangeRate,
              lastUpdated: DateTime.now()),
          CryptoCurrency(
              keyID: 2,
              name: "Ethereum",
              price: double.parse(ethData['price']) * exchangeRate,
              lastUpdated: DateTime.now()),
          CryptoCurrency(
              keyID: 3,
              name: "Dogecoin",
              price: double.parse(dogeData['price']) * exchangeRate,
              lastUpdated: DateTime.now()),
        ];

        await _saveToDatabase(updatedCryptos);
        cryptos = updatedCryptos;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching crypto data: $e');
    }
  }

  
  Future<void> initData() async {
    var db = CryptoDB(dbName: 'cryptos.db');
    cryptos = await db.loadAllData();
    if (cryptos.isEmpty) {
      await fetchCryptoData();
    } else {
      notifyListeners();
    }
  }

  
  void addCrypto(CryptoCurrency crypto) async {
    crypto.lastUpdated = DateTime.now();
    var db = CryptoDB(dbName: 'cryptos.db');
    await db.insertDatabase(crypto);
    cryptos = await db.loadAllData();
    notifyListeners();
  }

  
  void deleteCrypto(CryptoCurrency crypto) async {
    var db = CryptoDB(dbName: 'cryptos.db');
    await db.deleteData(crypto);
    cryptos = await db.loadAllData();
    notifyListeners();
  }

  
  void updateCrypto(CryptoCurrency crypto) async {
    crypto.lastUpdated = DateTime.now();
    var db = CryptoDB(dbName: 'cryptos.db');
    await db.updateData(crypto);
    cryptos = await db.loadAllData();
    notifyListeners();
  }


  Future<void> _saveToDatabase(List<CryptoCurrency> updatedCryptos) async {
    var db = CryptoDB(dbName: 'cryptos.db');
    for (var crypto in updatedCryptos) {
      await db.updateData(crypto);
    }
  }

 
  double convertToTHB(double usdPrice) {
    return usdPrice * exchangeRate;
  }
}
