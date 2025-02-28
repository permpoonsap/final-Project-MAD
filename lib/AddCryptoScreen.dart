import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/model/cryptoCurrency.dart';
import 'package:account/provider/cryptoProvider.dart';

class AddCryptoScreen extends StatefulWidget {
  const AddCryptoScreen({super.key});

  @override
  State<AddCryptoScreen> createState() => _AddCryptoScreenState();
}

class _AddCryptoScreenState extends State<AddCryptoScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Cryptocurrency',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter Crypto Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Crypto Name Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Crypto Name',
                        prefixIcon: const Icon(Icons.currency_bitcoin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      controller: nameController,
                      validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Price Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price (USD)',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: priceController,
                      validator: (value) {
                        try {
                          if (double.parse(value!) <= 0) {
                            return 'Enter a valid price';
                          }
                        } catch (_) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Add Crypto Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            var provider = Provider.of<CryptoProvider>(context, listen: false);
                            CryptoCurrency item = CryptoCurrency(
                              name: nameController.text,
                              price: double.parse(priceController.text),
                              lastUpdated: DateTime.now(),
                            );
                            provider.addCrypto(item);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Add Cryptocurrency'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
