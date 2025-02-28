import 'dart:io';
import 'package:account/model/cryptoCurrency.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class CryptoDB {
  String dbName;

  CryptoDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(CryptoCurrency item) async {
    var db = await openDatabase();

    var store = intMapStoreFactory.store('cryptos');

    Future<int> keyID = store.add(db, {
      'name': item.name,
      'price': item.price,
      'lastUpdated': item.lastUpdated?.toIso8601String()
    });
    db.close();
    return keyID;
  }

  Future<List<CryptoCurrency>> loadAllData() async {
    var db = await openDatabase();

    var store = intMapStoreFactory.store('cryptos');

    var snapshot = await store.find(db,
        finder: Finder(sortOrders: [SortOrder('lastUpdated', false)]));

    List<CryptoCurrency> cryptos = [];

    for (var record in snapshot) {
      CryptoCurrency item = CryptoCurrency(
          keyID: record.key,
          name: record['name'].toString(),
          price: double.parse(record['price'].toString()),
          lastUpdated: DateTime.parse(record['lastUpdated'].toString()));
      cryptos.add(item);
    }
    db.close();
    return cryptos;
  }

  deleteData(CryptoCurrency item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('cryptos');
    store.delete(db,
        finder: Finder(filter: Filter.equals(Field.key, item.keyID)));
    db.close();
  }

  updateData(CryptoCurrency item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('cryptos');

    store.update(
        db,
        {
          'name': item.name,
          'price': item.price,
          'lastUpdated': item.lastUpdated?.toIso8601String()
        },
        finder: Finder(filter: Filter.equals(Field.key, item.keyID))
    );

    db.close();
  }
}