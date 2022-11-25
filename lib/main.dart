import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:provider/provider.dart';
import 'package:search_app/Pages/MapPage.dart';

import 'providers/SearchProvider.dart';


void main() {
  _initializeHERESDK();
  runApp(ChangeNotifierProvider<SearchProvider>(
    child: MaterialApp(home: MapPage()),
    create: (_)=>SearchProvider(),
  )
  );
}

void _initializeHERESDK() async {
  SdkContext.init(IsolateOrigin.main);
  String accessKeyId = "uisHIEnEaseUIqMtKGyC1Q";
  String accessKeySecret = "bYu5v1zZ3zBzJFSPcwJIYrfzHgsfnFsEezdbEGSjcOIMgWP-zypBlsaRAicbdmAur0kWuBxKZM1FR9zQeH9GbA";
  SDKOptions sdkOptions = SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}


