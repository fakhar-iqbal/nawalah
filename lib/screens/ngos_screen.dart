import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ngo_cache_provider.dart';

class NGOScreen extends StatelessWidget {
  const NGOScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFD11559),
                child: const Row(
                  children: [

                    SizedBox(width: 8),
                    Text(
                      'NGOs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<void>(
                  future: Provider.of<NGOCacheProvider>(context, listen: false).loadCachedNGOs().then((_) {
                    if (Provider.of<NGOCacheProvider>(context, listen: false).cachedNGOs == null) {
                      return Provider.of<NGOCacheProvider>(context, listen: false).fetchAndCacheNGOs();
                    }
                  }),
                  builder: (context, snapshot) {
                    final provider = Provider.of<NGOCacheProvider>(context);
                    if (snapshot.connectionState == ConnectionState.waiting && provider.cachedNGOs == null) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (provider.cachedNGOs == null || provider.cachedNGOs!.isEmpty) {
                      return const Center(child: Text('No NGOs found!'));
                    } else {
                      final ngos = provider.cachedNGOs!;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: ngos.length,
                        itemBuilder: (context, index) {
                          var ngo = ngos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(ngo['logoImage'] ?? ''),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ngo['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ngo['address'] ?? "not specified",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ngo['phone'] ?? '-',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
