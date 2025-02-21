import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  RxList<ScanResult> scanResults = <ScanResult>[].obs;

  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      // Start scanning
      flutterBlue.startScan(timeout: Duration(seconds: 10));

      // Listen for results
      flutterBlue.scanResults.listen((results) {
        scanResults.assignAll(results); // Update observable list
      });

      // Stop scan after 10 seconds
      await Future.delayed(Duration(seconds: 10));
      flutterBlue.stopScan();
    }
  }

  Stream<List<ScanResult>> get scanResultsStream => flutterBlue.scanResults;
}
