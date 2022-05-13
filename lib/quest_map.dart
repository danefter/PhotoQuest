
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:photo_quest/quest_controller.dart';
import 'package:photo_quest/search_item.dart';
import 'dart:core';


void main() => runApp(const QuestMapPage());

class QuestMapPage extends StatelessWidget {
  const QuestMapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'searchPage',
      home: QuestMapScreen(),
    );
  }
}


class QuestMapScreen extends StatefulWidget {
  const QuestMapScreen({Key? key}) : super(key: key);

  @override
  _QuestMapScreenState createState() => _QuestMapScreenState();
}

class _QuestMapScreenState extends State<QuestMapScreen> {

  static const _mapType = MapType.normal;

  static const _initialCameraPosition = CameraPosition( //this position is Central Stockholm
    target: LatLng(59.329353, 18.068776), zoom: 12,);

  Set<Marker> _markers = {}; //markers of search items for google map

  GoogleMapController? mapController; //controller for Google map

  late LatLng currentCoordinates;

  late SearchItem _selectedItem; // when a marker is clicked on, it becomes the selected item

  late QuestController questController;

  void _resetQuestMarkers() { ///reset markers for specific quests
    _markers.clear();
    _addQuestMarkers();
  }

  void getLocation() async {///starts handler without loading markers
    var location = await questController.getLocation();
    setState(() {
      currentCoordinates = LatLng(location.latitude, location.longitude);
    });
  }

  void getItems() async {/// gets the items from handler and loads markers
    var location = await questController.getLocation();
    questController.getSearchItemsFromCoordinates(LatLng(location.latitude, location.longitude));
    setState(() {
      currentCoordinates = LatLng(location.latitude, location.longitude);
      _addQuestMarkers();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      questController = QuestController.DEFAULT_INSTANCE;
      getItems();/// only used for demo purposes
    });
  }

  void _addQuestMarkers() { ///add markers without resetting
    setState(() {
      _markers.addAll(
          questController.loadedItems.map((item) =>
              Marker(
                  icon: BitmapDescriptor.defaultMarker, //add first marker
                  markerId: MarkerId(item.itemID),
                  position: item.getCoordinates(), //position of marker
                  infoWindow: InfoWindow( //popup info
                      title: item.itemTitle,
                      onTap: () {
                        _selectedItem = item;
                        _showMyDialog();
                      }
                  )
              )
          )
      );
    });
  }

  ///DOESN'T WORK NEEDS TO SET MARKER GREEN
  void selectQuest(SearchItem item){
    questController.selectQuest(item);
    Marker greenMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), //add first marker
        markerId: MarkerId(item.itemID),
        position: item.getCoordinates(), //position of marker
        infoWindow: InfoWindow( //popup info
            title: item.itemTitle,
            onTap: () {
              _selectedItem = item;
              _showMyDialog();
            })
    );
    for (Marker marker in _markers){
      if (marker.markerId.value == item.itemID){
        setState(() {
          _markers.remove(marker);
          _markers.add(greenMarker);
        }
        );
        break;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(initialCameraPosition: _initialCameraPosition,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapType: _mapType,
        markers: _markers,
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
            questController.currentLocation.onLocationChanged.listen((LocationData loc) {
              setState(() {
                getItems();
              });
            });
          });
        },
        onTap: (coordinate) {
          questController.makeQuery("", "", "20");
          questController.getSearchItemsFromCoordinates(coordinate);
          setState(() {
            _addQuestMarkers();
          });
        },
      ),
    );
  }

  Future<void> _showMyDialog() async { ///text box thing that pops up when a marker is clicked on
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedItem.itemTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(_selectedItem.itemTitle),
                Text(_selectedItem.itemPlaceLabel),
                Text(_selectedItem.itemTimeLabel),
                Text(questController
                    .getDistance(
                    _selectedItem.getCoordinates(), currentCoordinates)
                    .toString()
                    .split(".")
                    .first + " m")
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('Save quest?'), ///not implemented
                onPressed: () {
                  selectQuest(_selectedItem);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12.0),
                    primary: Colors.black,
                    textStyle: const TextStyle(fontSize: 15),
                    backgroundColor: Colors.green
                )
            ),
            ElevatedButton(
                child: const Text('Cancel'), ///closes window
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12.0),
                    primary: Colors.black,
                    textStyle: const TextStyle(fontSize: 15),
                    backgroundColor: Colors.redAccent
                )
            ),
            ElevatedButton(
                child: const Text('Description'),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12.0),
                    primary: Colors.black,
                    textStyle: const TextStyle(fontSize: 15),
                    backgroundColor: Colors.blueAccent
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text(_selectedItem.itemTitle),
                          content: SingleChildScrollView(
                              child: Text(_selectedItem.itemDescription)
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(12.0),
                                    primary: Colors.black,
                                    textStyle: const TextStyle(fontSize: 15),
                                    backgroundColor: Colors.blueAccent
                                )
                            )]
                      );
                    },

                  );}
            )
          ],
        );
      },
    );
  }
}