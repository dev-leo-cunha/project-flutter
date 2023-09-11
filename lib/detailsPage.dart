// Exibe os detalhes de cada registro

import 'dart:io';

import 'package:flutter/material.dart';

import 'main.dart';
import 'searchPage.dart';

class DetailsPage extends StatelessWidget {
  final PhotoInfo photoInfo;

  const DetailsPage({super.key, required this.photoInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: Stack(
        children: [
          Image.file(
            File(photoInfo.filePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 20, // Posiciona o botão 20 pixels acima da borda inferior
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: const Text('Buscar'),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bússola: ${photoInfo.compassHeading}',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 134, 37, 37)),
                  ),
                  Text(
                    'Latitude: ${photoInfo.latitude}, Longitude: ${photoInfo.longitude}',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 134, 37, 37)),
                  ),
                  Text(
                    'ID: ${photoInfo.id}',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 134, 37, 37)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
