import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app_proyecto/screens/signin_screen.dart';

import '../utils/color_utils.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  //LocationData? _lastLocation; //alamacena ultima ubicación
  Timer? _locationTimer; // Timer para actualizar la ubicación cada 5 segundos
  
// Función para actualizar la ubicación
  void _updateLocation() {
    _location?.getLocation().then((location) {
      setState(() {
        _currentLocation = location;
      });
      moveToPosition(LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
      // Guarda la ubicación en Firebase
      guardarUbicacion(_currentLocation);
      // Actualiza la última ubicación solo si ha cambiado
      /*if (_lastLocation == null ||
          _lastLocation!.latitude != _currentLocation!.latitude ||
          _lastLocation!.longitude != _currentLocation!.longitude) {
        _lastLocation = _currentLocation;

        // Guarda la ubicación en Firebase solo si ha cambiado
        guardarUbicacion(_currentLocation);
      }*/
    });
  }

 // Función para guardar la ubicación en Firebase
  void guardarUbicacion(LocationData? locationData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && locationData != null) {
        CollectionReference ubicacionesCollection = FirebaseFirestore.instance.collection('ubicaciones');
        //DateTime horaActual = DateTime.now();

        QuerySnapshot ubicacionesQuery = await ubicacionesCollection
        .where('usuarioId', isEqualTo: user.uid).get();

        if(ubicacionesQuery.docs.isNotEmpty){
          DocumentSnapshot registroUsuario = ubicacionesQuery.docs[0];
          Map<String, dynamic> data = registroUsuario.data() as Map<String, dynamic>;

          print('si existe el documento');
          double latitud = data['latitud'].toDouble();
          print("Latitud $latitud");
          double longitud = data['longitud'].toDouble();
          print("Longitud $longitud");
          DateTime hora = data['hora'].toDate();
          print('Hora: $hora');

          
        }else{
          print('no existe ningun registro');

          ubicacionesCollection.add({
        //   'usuarioId': user.uid,
        //   'latitud': locationData.latitude,
        //   'longitud': locationData.longitude,
        //   'hora': horaActual,
         });
        }

        

        // print('Ubicación guardada con éxito');
      } else {
        print('No hay usuario autenticado o datos de ubicación nulos');
      }
    } catch (error) {
      print('Error al guardar la ubicación: $error');
    }
  }



  @override
  void initState() {
    _init();
    super.initState();
    _locationTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _updateLocation();
    });
  }

  @override
  void dispose() {
    // Cancela el timer cuando el widget se desmonta
    _locationTimer?.cancel();
    super.dispose();
  }

  _init() async {
    _location = Location();
    _cameraPosition = CameraPosition(
      target: LatLng(-0.204742, -78.485126),
      zoom: 18
    );
    _initLocation();
  }

  //función para saber cuando nos movemos o cambia la ubicación
  _initLocation(){
    _location?.getLocation().then((location){
      _currentLocation = location;
    });
    _location?.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;
      moveToPosition(LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
     });
  }
  
  //Funcion que mueve el mapa a una nueva posición y centra en él
  Future<LocationData?> getCurrentLocation() async{
    //    Location().getLocation().then((value) async{
      var currentLocation = await _location?.getLocation();
      return currentLocation; //?? null;
  }

  moveToPosition (LatLng latLng) async{
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 18
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("A91079"),
        title: Text("Geolocalización"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SingInScreen()),
                );
              });
            },
          ),
        ],
      ),
      body: _buildAppBody(),
    );
  }

  Widget _buildAppBody(){
    return _getMap();
  }

  Widget _getMark(){
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0,3),
            spreadRadius: 4,
            blurRadius: 6
          )
        ]
      ),
    );
  }

  Widget _getMap(){
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller){
            if(!_googleMapController.isCompleted){
              _googleMapController.complete(controller);
            }
          },
        ),

        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child:_getMark()
          )
        )
      ],
    );
    
  }
}