/*
 * Copyright (C) 2019-2022 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';


import '../SearchResultMetadata.dart';

// A callback to notify the hosting widget.
typedef ShowDialogFunction = void Function(String title, String message);


class SearchProvider with ChangeNotifier {

  List<MapMarker> _mapMarkerList = [];
  List<MapMarker> _selectedMarkerList = [];
  SearchEngine _searchEngine=SearchEngine();
  MapImage? _poiMapImage;
  String? _poiImage;


  List<String> _titlevicinity=[];
  List<String> get titlevicinity => _titlevicinity;


  dynamic _placelist=[];
  dynamic get placelist => _placelist;

  bool _issearchend=false;
  dynamic get issearchend => _issearchend;


  Map<String, List> _dataMapping = new HashMap();
  Map<String, List> get dataMapping =>  _dataMapping;

  late bool _entertainmentLoading=true;
  bool get entertainmentLoading => _entertainmentLoading;

  late bool _emergencyLoading=true;
  bool get emergencyLoading => _emergencyLoading;



  void clearplacelist(_hereMapController){
    _placelist=[];
    notifyListeners();
    _clearMap(_hereMapController);
    notifyListeners();
    clearSelectedMap(_hereMapController);
    notifyListeners();

  }

  Future searchInViewport(String queryString,
      _hereMapController, camera) async {
    _clearMap(_hereMapController);

    GeoBox viewportGeoBox = _getMapViewGeoBox(camera);
    TextQueryArea queryArea = TextQueryArea.withBox(viewportGeoBox);
    TextQuery query = TextQuery.withArea(queryString, queryArea);

    SearchOptions searchOptions = SearchOptions.withDefaults();
    searchOptions.languageCode = LanguageCode.enUs;
    searchOptions.maxItems = 30;

    await _searchEngine.searchByText(
        query, searchOptions, (SearchError? searchError,
        List<Place>? list) async {
      if (searchError != null) {

        return null;
      }
      var templist=[];
      int listLength = list!.length;
      for (Place searchResult in list) {

        templist.add([
          searchResult.title,
          [
            searchResult.geoCoordinates?.latitude,
            searchResult.geoCoordinates?.longitude
          ]
        ]);
      }
      _dataMapping[queryString]=templist;
      notifyListeners();
    });
  }

  GeoBox _getMapViewGeoBox(camera) {
    GeoBox? geoBox = camera.boundingBox;
    if (geoBox == null) {
      print(
          "GeoBox creation failed, corners are null. This can happen when the map is tilted. Falling back to a fixed box.");
      GeoCoordinates southWestCorner = GeoCoordinates(
          camera.state.targetCoordinates.latitude - 0.05,
          camera.state.targetCoordinates.longitude - 0.05);
      GeoCoordinates northEastCorner = GeoCoordinates(
          camera.state.targetCoordinates.latitude + 0.05,
          camera.state.targetCoordinates.longitude + 0.05);
      geoBox = GeoBox(southWestCorner, northEastCorner);
    }
    notifyListeners();
    return geoBox;
  }

  void _clearMap(_hereMapController) {
    _mapMarkerList.forEach((mapMarker) {
      _hereMapController.mapScene.removeMapMarker(mapMarker);
    });

    _mapMarkerList.clear();
    notifyListeners();
  }

  void clearSelectedMap(_hereMapController) {
    print("heee");
    print(_selectedMarkerList);
    _selectedMarkerList.forEach((mapMarker) {
      _hereMapController.mapScene.removeMapMarker(mapMarker);
    });

    _selectedMarkerList.clear();
    notifyListeners();
  }


  Future<dynamic> searchToAddInMaps(String queryString,_hereMapController,camera)  async {
    _issearchend=false;
    _clearMap(_hereMapController);
    GeoBox viewportGeoBox = _getMapViewGeoBox(_hereMapController.camera);
    TextQueryArea queryArea = TextQueryArea.withBox(viewportGeoBox);
    TextQuery query = TextQuery.withArea(queryString, queryArea);

    SearchOptions searchOptions = SearchOptions.withDefaults();
    searchOptions.languageCode = LanguageCode.enUs;
    searchOptions.maxItems = 30;
    _searchEngine.searchByText(query, searchOptions, (SearchError? searchError, List<Place>? list) async{
      if (searchError != null) {
        _issearchend=true;
        notifyListeners();
      }
      if (list==null){
        _issearchend=true;
        notifyListeners();
        return;
      }
      int listLength = list!.length;


      for(int i=0;i<list.length;i++){
        var searchResult=list[i];
        Metadata metadata = Metadata();
        metadata.setCustomValue("key_search_result", SearchResultMetadata(searchResult));
        _placelist.add([searchResult.title,[searchResult.geoCoordinates?.latitude,searchResult.geoCoordinates?.longitude]]);
        addPoiMapMarker(searchResult.geoCoordinates!, metadata,_hereMapController,"",true);

      }
      Metadata metadata = Metadata();
      addPoiMapMarker(list[0].geoCoordinates!, metadata,_hereMapController,"selected_poi.png",false);

      _issearchend=true;
      print(list);
      notifyListeners();
      _setTapGestureHandler(_hereMapController);

    });
    notifyListeners();

  }

  Future<void> addPoiMapMarker(GeoCoordinates geoCoordinates, Metadata metadata,_hereMapController,String selectedpoi,noselectedpoi) async {
    if (selectedpoi!="" ){
      _poiImage=selectedpoi;
    }
    if (noselectedpoi==true){
      _poiImage=null;
    }


    MapMarker mapMarker = await _addPoiMapMarker(geoCoordinates,_hereMapController);
    mapMarker.metadata = metadata;
    notifyListeners();
  }

  Future<MapMarker> _addPoiMapMarker(GeoCoordinates geoCoordinates,_hereMapController) async {
    print(_poiImage);
    if (_poiImage == null) {
      Uint8List imagePixelData = await _loadFileAsUint8List('poi.png');
      _poiMapImage = MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
      MapMarker mapMarker = MapMarker(geoCoordinates, _poiMapImage!);
      _hereMapController.mapScene.addMapMarker(mapMarker);
      _mapMarkerList.add(mapMarker);
      notifyListeners();
      return mapMarker;

    }
    else{
      Uint8List imagePixelData = await _loadFileAsUint8List(_poiImage!);
      _poiMapImage = MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
      MapMarker mapMarker = MapMarker(geoCoordinates, _poiMapImage!);
      _hereMapController.mapScene.addMapMarker(mapMarker);
      _selectedMarkerList.add(mapMarker);
      notifyListeners();
      return mapMarker;
    }


  }

  Future<Uint8List> _loadFileAsUint8List(String fileName) async {
    ByteData fileData = await rootBundle.load('assets/' + fileName);
    notifyListeners();
    return Uint8List.view(fileData.buffer);
  }


  void _setTapGestureHandler(_hereMapController) {
    _hereMapController.gestures.tapListener = TapListener((Point2D touchPoint) {
      _pickMapMarker(touchPoint,_hereMapController);
    });
    notifyListeners();
  }

  void _pickMapMarker(Point2D touchPoint,_hereMapController) {
    double radiusInPixel = 2;
    _hereMapController.pickMapItems(
        touchPoint, radiusInPixel, (pickMapItemsResult) {
      if (pickMapItemsResult == null) {
        return;
      }
      List<MapMarker> mapMarkerList = pickMapItemsResult.markers;
      if (mapMarkerList.length == 0) {
        print("No map markers found.");
        return;
      }

      MapMarker topmostMapMarker = mapMarkerList.first;
      Metadata? metadata = topmostMapMarker.metadata;
      if (metadata != null) {
        CustomMetadataValue? customMetadataValue = metadata.getCustomValue(
            "key_search_result");
        if (customMetadataValue != null) {
          SearchResultMetadata searchResultMetadata = customMetadataValue as SearchResultMetadata;
          String title = searchResultMetadata.searchResult.title;
          String vicinity = searchResultMetadata.searchResult.address
              .addressText;
          _titlevicinity=[title,vicinity];
          notifyListeners();
        }
      }
    });
    notifyListeners();
  }
}

