import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'provider/cryptoProvider.dart';
import 'EditCryptoScreen.dart';
import 'AddCryptoScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CryptoProvider()..initData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crypto Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const CryptoHomePage(),
      ),
    );
  }
}

class CryptoHomePage extends StatelessWidget {
  const CryptoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CryptoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crypto Manager',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await provider.fetchCryptoData();
            },
          ),
        ],
      ),
      body: Consumer<CryptoProvider>(
        builder: (context, provider, child) {
          if (provider.cryptos.isEmpty) {
            return const Center(
              child: Text(
                'No Cryptos Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.cryptos.length,
            itemBuilder: (context, index) {
              final crypto = provider.cryptos[index];

              return Dismissible(
                key: Key(crypto.keyID.toString()),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.blue,
                  child: const Icon(Icons.edit, color: Colors.white, size: 28),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCryptoScreen(crypto: crypto),
                      ),
                    );
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete ${crypto.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteCrypto(crypto);
                              Navigator.pop(context, true);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                  return false;
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      crypto.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Price: \$${crypto.price.toStringAsFixed(2)} | ${provider.convertToTHB(crypto.price).toStringAsFixed(2)} บาท',
                          style: const TextStyle(color: Colors.green, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        if (crypto.lastUpdated != null)
                          Text(
                            'Updated: ${DateFormat('dd/MM/yyyy เวลา HH:mm').format(crypto.lastUpdated!)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCryptoScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
