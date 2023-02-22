import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/utils/value_notifier_states.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location/location.dart';

class HomeStore extends ValueNotifier<BluetoothExplorerState> {
  HomeStore() : super(InitialBEState());

  late FlutterReactiveBle _flutterReactiveBle;

  StreamSubscription<DiscoveredDevice>? _subscription;

  StreamSubscription<ConnectionStateUpdate>? _connection;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  final Location _location = Location();

  bool? bleIsReady;

  List<DiscoveredDevice> devices = [];

  DiscoveredDevice? connectedDevice;

  void initiate() => value = InitialBEState();

  void loading(bool isLoading) => value = LoadingBEState(isLoading);

  void success({String? data}) => value = SuccessBEState(data);

  void error() => value = ErrorBEState();

  void scan() async {
    if (await _checkLocation()) {
      // loading(true);
      _flutterReactiveBle = FlutterReactiveBle();
      bleIsReady = _flutterReactiveBle.status == BleStatus.ready;
      if (bleIsReady!) {
        devices.clear();
        _subscription = _flutterReactiveBle.scanForDevices(
          withServices: [],
          scanMode: ScanMode.lowLatency,
          requireLocationServicesEnabled: true,
        ).listen((device) {
          loading(true);
          final index = devices.indexWhere((d) => d.id == device.id);
          if (index >= 0) {
            devices[index] = device;
          } else {
            log('${device.name} :: ${device.id}');
            devices.add(device);
          }
          loading(false);
        }, onError: (e) => debugPrint(e.toString()));
      }
    }
  }

  Future<void> cancelScan() async {
    await _subscription?.cancel();
    devices.clear();
    initiate();
  }

  Future<void> connect(DiscoveredDevice device) async {
    _connection = _flutterReactiveBle
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((update) async {
      connectedDevice = device;
      log('ConnectionState for device ${device.name} : ${update.connectionState}');
      _deviceConnectionController.add(update);
      if (update.connectionState == DeviceConnectionState.connected) {
        await _subscription?.cancel();
        devices.clear();

        success();
        log(device.toString());

        final services = await _flutterReactiveBle.discoverServices(device.id);

        for (var service in services) {
          for (var c in service.characteristics) {
            if (c.isReadable && c.isNotifiable && c.isIndicatable) {
              log(service.toString());
              final characteristic = QualifiedCharacteristic(
                  serviceId: c.serviceId,
                  characteristicId: c.characteristicId,
                  deviceId: device.id);

              _flutterReactiveBle
                  .subscribeToCharacteristic(characteristic)
                  .listen((data) {
                final readData = String.fromCharCodes(data);
                success(data: readData);
                log(readData);
                // log(data.toString());
              }, onError: (e) {
                debugPrint('Error on listening to device:');
                debugPrint(e.toString());
              });
              break;
            }
          }
        }
      }
    }, onError: (e) {
      error();
      debugPrint(e.toString());
    });
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      try {
        log('disconnecting to device: ${connectedDevice!.name} :: ${connectedDevice!.id}');
        await _connection?.cancel();
        initiate();
      } on Exception catch (e) {
        log('Error disconnecting from a device: $e');
      } finally {
        _deviceConnectionController.add(
          ConnectionStateUpdate(
            deviceId: connectedDevice!.id,
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        );
        log('Device: ${connectedDevice!.name} :: ${connectedDevice!.id}');
        connectedDevice = null;
      }
    }
  }

  Future<bool> _checkLocation() async {
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted == PermissionStatus.granted) {
        return _checkLocationIsEnabled();
      } else {
        return false;
      }
    } else {
      return _checkLocationIsEnabled();
    }
  }

  Future<bool> _checkLocationIsEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      return serviceEnabled;
    } else {
      return true;
    }
  }
}
