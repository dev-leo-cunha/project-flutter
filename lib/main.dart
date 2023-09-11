import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        },
      ),
    );
  }
}

class PhotoInfo {
  final int id;
  final String filePath;
  final double compassHeading;
  final double latitude;
  final double longitude;

  PhotoInfo({
    required this.id,
    required this.filePath,
    required this.compassHeading,
    required this.latitude,
    required this.longitude,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late List<CameraDescription> _cameras;
  CompassEvent? _lastRead;
  CameraController? _controller;
  double? latitude;
  double? longitude;
  Location location = Location();

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isCameraOpen = false;

  // Array das fotos

  final List<PhotoInfo> _photoHistory = [];
  int _nextId = 1;

  void _removePhoto(int id) {
    setState(() {
      _photoHistory.removeWhere((photo) => photo.id == id);
    });
  }

  @override
  void initState() {
    super.initState();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        latitude = currentLocation.latitude ?? 0.0;
        longitude = currentLocation.longitude ?? 0.0;
      });
    });

    availableCameras().then((cameras) {
      _cameras = cameras;
    });

    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        _lastRead = event;
      });
    });
  }

  // Abrir camera

  void _openCamera() {
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.max);
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isCameraOpen = true;
          });
        }
      });
    }
  }

  // Capturar foto

  void _capturePhoto() async {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        _lastRead != null) {
      try {
        final XFile file = await _controller!.takePicture();

        double compassHeading = _lastRead!.heading?.toDouble() ?? 0.0;

        PhotoInfo photoInfo = PhotoInfo(
          id: _nextId, // Atribui o próximo ID
          filePath: file.path,
          compassHeading: compassHeading,
          latitude: latitude ?? 0.0,
          longitude: longitude ?? 0.0,
        );
        _nextId++; // Incrementa o próximo ID

        setState(() {
          _photoHistory.add(photoInfo);
        });

        // Exibe a confirmação da captura

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Captura realizada com sucesso',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            onVisible: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Erro na captura: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro na captura foto: $e',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Monta o topico nos registros

  void _viewPhotoHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoHistoryPage(
          photos: _photoHistory,
          onRemove: _removePhoto, // Passa a função de remoção
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  // Header

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ORBIS GEO',
          style: CustomStyles.defaultHeaderStyle,
        ),
        leading: _isCameraOpen
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _controller?.dispose();
                  setState(() {
                    _controller = null;
                    _isCameraOpen = false;
                  });
                },
              )
            : null,
      ),
      body: Builder(builder: (context) {
        return _isCameraOpen
            ? _buildCameraScreen()
            : HomePage(
                onOpenCamera: _openCamera,
                onViewHistory: _viewPhotoHistory,
              );
      }),
    );
  }

  // Camera

  Widget _buildCameraScreen() {
    if (kDebugMode) {
      print('BUSSOLA: ${_lastRead!.heading}');
    }
    if (kDebugMode) {
      print('LOCALIZAÇÃO: $latitude, $longitude');
    }
    return Stack(
      children: <Widget>[
        if (_controller != null && _controller!.value.isInitialized)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(_controller!),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (latitude == null && longitude == null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Bússola: ${_lastRead!.heading}',
                      style: CustomStyles.defaultTextStyle,
                    ),
                    const Text('LOCALIZAÇÂO NAO ENCONTRADA!',
                        style: CustomStyles.defaultTextStyle),
                  ],
                ),
              ),
            if (_lastRead != null && latitude != null && longitude != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Bússola: ${_lastRead!.heading}',
                      style: CustomStyles.defaultTextStyle,
                    ),
                    Text('Latitude: $latitude',
                        style: CustomStyles.defaultTextStyle),
                    Text('Longitude: $longitude',
                        style: CustomStyles.defaultTextStyle),
                  ],
                ),
              ),
            Container(
              // Container para os botões
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                  bottom: 50.0), // Ajuste a quantidade conforme necessário
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    style: CustomStyles.defaultButtonStyle,
                    onPressed: _capturePhoto,
                    child: const Text('Capturar'),
                  ),
                  ElevatedButton(
                    style: CustomStyles.defaultButtonStyle,
                    onPressed: _viewPhotoHistory,
                    child: const Text('Registros'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Exibe detalhes de permissões ao abrir o app pela primeira vez

// Home Page

class HomePage extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final VoidCallback onViewHistory;

  HomePage({required this.onOpenCamera, required this.onViewHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bem-vindo ao Orbis Geo',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOpenCamera,
              style: CustomStyles.defaultButtonStyle,
              child: const Text('Abrir Câmera'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onViewHistory,
              style: CustomStyles.defaultButtonStyle,
              child: const Text('Registros'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pagina dos Registros

class PhotoHistoryPage extends StatelessWidget {
  final List<PhotoInfo> photos;
  final Function(int) onRemove; // Adicionado o callback de remoção

  const PhotoHistoryPage(
      {super.key, required this.photos, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros'),
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          PhotoInfo photoInfo = photos[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(photoInfo: photoInfo),
                ),
              );
            },
            child: Dismissible(
              key: Key(
                  photoInfo.id.toString()), // Chave única para o Dismissible
              onDismissed: (direction) {
                onRemove(photoInfo.id); // Chama a função de remoção
              },
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: Image.file(File(photoInfo.filePath)),
                title: Text('Bússola: ${photoInfo.compassHeading}'),
                subtitle: Text(
                  'ID: ${photoInfo.id}, Latitude: ${photoInfo.latitude}, Longitude: ${photoInfo.longitude}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Exibe os detalhes de cada registro

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
                    MaterialPageRoute(builder: (context) => SearchPage()),
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

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscando no Banco de Dados'),
      ),
      body: const Center(
        child:
            CircularProgressIndicator(), // Um indicador de carregamento (loading)
      ),
    );
  }
}
