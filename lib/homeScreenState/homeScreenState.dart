import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

import '../homePage.dart';
import '../homeScreen.dart';
import '../main.dart';
import '../photoHistoryPage.dart';
import '../searchPage.dart';
import 'cameraHelpers.dart';

class HomeScreenState extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<CameraDescription> _cameras;
  CompassEvent? _lastRead;
  double? latitude;
  double? longitude;
  Location location = Location();

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isCameraOpen = false;

  final List<PhotoInfo> _photoHistory = [];
  int _nextId = 1;

  final CameraHelper _cameraHelper = CameraHelper();

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

    _cameraHelper.getAvailableCameras().then((cameras) {
      _cameras = cameras;
    });

    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        _lastRead = event;
      });
    });
  }

  void _openCamera() {
    _cameraHelper.initializeCamera(_cameras).then((_) {
      if (mounted) {
        setState(() {
          _isCameraOpen = true;
        });
      }
    });
  }

  void _capturePhoto() async {
    try {
      final XFile file = await _cameraHelper.capturePhoto();

      double compassHeading = _lastRead!.heading?.toDouble() ?? 0.0;

      PhotoInfo photoInfo = PhotoInfo(
        id: _nextId,
        filePath: file.path,
        compassHeading: compassHeading,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
      );
      _nextId++;

      setState(() {
        _photoHistory.add(photoInfo);
      });

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
              MaterialPageRoute(builder: (context) => const SearchPage()),
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

  void _viewPhotoHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoHistoryPage(
          photos: _photoHistory,
          onRemove: _removePhoto,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraHelper.closeCamera();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ORBIS GEO',
          style: TextStyle(fontSize: 20),
        ),
        leading: _isCameraOpen
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _cameraHelper.closeCamera();
                  setState(() {
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

  Widget _buildCameraScreen() {
    return Stack(
      children: <Widget>[
        if (_cameraHelper.isCameraReady())
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(_cameraHelper.controller!),
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
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      'LOCALIZAÇÂO NAO ENCONTRADA!',
                      style: TextStyle(fontSize: 16),
                    ),
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
                      style: TextStyle(fontSize: 16),
                    ),
                    Text('Latitude: $latitude', style: TextStyle(fontSize: 16)),
                    Text('Longitude: $longitude', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _capturePhoto,
                    child: const Text('Capturar'),
                  ),
                  ElevatedButton(
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
