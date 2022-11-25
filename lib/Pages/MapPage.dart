import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/mapview.dart';
import 'package:provider/provider.dart';

import '../providers/SearchProvider.dart';
import '../components/CalculateDistance.dart';
import '../components/listingcomponent.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  SearchProvider? _searchProvider;
  List<double> CurrentLocation = [28.6304, 77.2177];
  FocusNode focusNode = FocusNode();

  late HereMapController MapController;
  dynamic camera;

  CalculateDistance calc = CalculateDistance();

  String searched = "";
  bool firstsearched = true;
  String modeoftransfer = "Car";
  String medicalservice = "";
  bool ismedical = false;

  @override
  Widget build(BuildContext context) {
    dynamic placelist = context.watch<SearchProvider>().placelist;
    bool issearchend = context.watch<SearchProvider>().issearchend;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: HereMap(onMapCreated: _onMapCreated),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                child: Column(
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      elevation: 20.0,
                      shadowColor: Colors.black,
                      child: TextField(
                        // focusNode: focusNode,
                        autofocus: false,
                        onChanged: (x) {
                          searched = x;
                        },
                        onSubmitted: (x) {
                          firstsearched = false;
                          searched = x;
                          setState(() {
                            context
                                .read<SearchProvider>()
                                .clearplacelist(MapController);
                            context.read<SearchProvider>().searchToAddInMaps(
                                searched, MapController, camera);
                          });
                        },
                        decoration: InputDecoration(
                            focusColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            suffixIcon: (firstsearched == false &&
                                    placelist.isEmpty &&
                                    !issearchend)
                                ? Transform.scale(
                                    scale: 0.5,
                                    child: CircularProgressIndicator(),
                                  )
                                : Icon(
                                    Icons.location_pin,
                                    size: 30,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                            filled: true,
                            hintStyle: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                            hintText: "Looking for something ?",
                            prefixIcon: GestureDetector(
                                onTap: () {
                                  // _searchExample?.searchToAddInMaps(searched);
                                },
                                child: Icon(
                                  Icons.search_outlined,
                                  size: 30,
                                  color: Colors.black.withOpacity(0.7),
                                )),
                            fillColor: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !ismedical
                        ? Row(
                            children: [
                              modeoftravel(context, "Walk", 1000),
                              SizedBox(
                                width: 10,
                              ),
                              modeoftravel(context, "Bicycle", 5000),
                              SizedBox(
                                width: 10,
                              ),
                              modeoftravel(context, "Car", 8000),
                              // TextButton(onPressed: (){print(modeoftransfer);}, child: Text("hhhhhhhhhhh"))
                            ],
                          )
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                          child: Row(
                              children: [
                                emergencyServices(context, "Hospital"),
                                SizedBox(
                                  width: 10,
                                ),
                                emergencyServices(context, "Police"),
                                SizedBox(
                                  width: 10,
                                ),
                                emergencyServices(context, "Fire Station"),
                                // TextButton(onPressed: (){print(modeoftransfer);}, child: Text("hhhhhhhhhhh"))
                              ],
                            ),
                        )
                  ],
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 30),
                height: 130,
                child: Swiper(
                  loop: false,
                  onIndexChanged: (index) {
                    context.read<SearchProvider>().clearSelectedMap(MapController);
                    _searchProvider?.clearSelectedMap(MapController);
                    Metadata metadata = Metadata();
                    _searchProvider?.addPoiMapMarker(
                        GeoCoordinates(CurrentLocation[0], CurrentLocation[1]),
                        metadata,
                        MapController,
                        "currentposition.png",false);
                    _searchProvider?.addPoiMapMarker(
                        GeoCoordinates(
                            placelist[index][1][0], placelist[index][1][1]),
                        metadata,
                        MapController,
                        "selected_poi.png",false);
                    _flyTo(
                        GeoCoordinates(
                            placelist[index][1][0], placelist[index][1][1]),
                        MapController);
                  },
                  itemHeight: 130,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(30), // radius of 10
                            color: Colors.white // green as background color
                            ),
                        child: ListingComponent(
                          Title: placelist[index][0],
                          Dist: calc
                              .calculateDistance(
                                  placelist[index][1][0],
                                  placelist[index][1][1],
                                  CurrentLocation[0],
                                  CurrentLocation[1])
                              .toString(),
                          ishome: false,
                        ));
                  },
                  itemCount: placelist.length,
                  viewportFraction: 0.8,
                  scale: 0.9,
                  // pagination: new SwiperPagination(),
                  // control: new SwiperControl(),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 250,
              child: InkWell(
                onTap: () {

                },
                child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_border)),
              ),
            ),
            Positioned(
              right: 20,
              top: 300,
              child: InkWell(
                onTap: () {
                  _flyTo(GeoCoordinates(CurrentLocation[0], CurrentLocation[1]),
                      MapController);
                },
                child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.radio_button_checked)),
              ),
            ),
            Positioned(
              right: 20,
              top: 350,
              child: InkWell(
                onTap: () {
                  if(ismedical==true){
                    setState(() {
                      ismedical=false;
                    });
                  }
                  else{
                    setState(() {
                      ismedical=true;
                    });
                  }

                },
                child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: ismedical?Colors.red:Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medical_services)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InkWell modeoftravel(BuildContext context, mode, double dist) {
    return InkWell(
      onTap: () {
        setState(() {
          modeoftransfer = mode;
          double distanceToEarthInMeters = dist;
          MapMeasure mapMeasureZoom =
              MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
          MapController.camera.lookAtPointWithMeasure(
              GeoCoordinates(CurrentLocation[0], CurrentLocation[1]),
              mapMeasureZoom);
          context.read<SearchProvider>().clearplacelist(MapController);
          Future.delayed(Duration(milliseconds: 100), () {
            // Do something
            context.read<SearchProvider>().searchToAddInMaps(
                searched, MapController, MapController.camera);
          });
        });
      },
      child: Container(
        height: 40,
        width: 100,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mode == "Walk"
                    ? Icons.directions_walk
                    : mode == "Bicycle"
                        ? Icons.directions_bike
                        : Icons.directions_car,
                size: 21,
                color: modeoftransfer == mode ? Colors.blue : Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                mode,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 17,color: modeoftransfer==mode?Colors.blue:Colors.black.withOpacity(0.7)),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell emergencyServices(BuildContext context, mode) {
    return InkWell(
      onTap: () {
        medicalservice=mode;
        context.read<SearchProvider>().clearplacelist(MapController);
        Future.delayed(Duration(milliseconds: 100), () {
          // Do something
          context.read<SearchProvider>().searchToAddInMaps(
              mode, MapController, MapController.camera);
        });


      },
      child: Container(
        height: 40,
        width: 135,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mode == "Hospital"
                    ? Icons.medical_services_outlined
                    : mode == "Police"
                    ? Icons.local_police_outlined
                    : Icons.local_fire_department_outlined,
                size: 21,
                color: medicalservice == mode ? Colors.blue : Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                mode,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 17,color: medicalservice==mode?Colors.blue:Colors.black.withOpacity(0.7)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onMapCreated(HereMapController hereMapController) {
    MapController = hereMapController;
    camera = MapController.camera;
    _searchProvider = SearchProvider();
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.hybridDay,
        (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }
      print(modeoftransfer);
      double distanceToEarthInMeters = 8000;

      MapMeasure mapMeasureZoom =
          MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);

      // hereMapController.camera.flyTo(target)

      Metadata metadata = Metadata();
      _searchProvider?.addPoiMapMarker(
          GeoCoordinates(CurrentLocation[0], CurrentLocation[1]),
          metadata,
          MapController,
          "currentposition.png",false);

      camera.lookAtPointWithMeasure(
          GeoCoordinates(CurrentLocation[0], CurrentLocation[1]),
          mapMeasureZoom);
    });
  }

  void _flyTo(GeoCoordinates geoCoordinates, hereMapController) {
    GeoCoordinatesUpdate geoCoordinatesUpdate =
        GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    double bowFactor = 1;
    MapCameraAnimation animation = MapCameraAnimationFactory.flyTo(
        geoCoordinatesUpdate, bowFactor, Duration(seconds: 2));
    camera.startAnimation(animation);
  }

  @override
  void dispose() {
    SDKNativeEngine.sharedInstance?.dispose();
    SdkContext.release();
    super.dispose();
  }
}
