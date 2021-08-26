import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Controller extends GetxController with SingleGetTickerProviderMixin {
  final box = GetStorage();
  Locale get locale =>
      box.read('locale') == 'zh_CN' ? Locale('zh', 'CN') : Locale('en', 'US');

  ThemeData get theme =>
      box.read('isDarkMode') ?? false ? ThemeData.dark() : ThemeData.light();

  List get commands =>
      box.read('commands') ?? ['cmd1', 'cmd2', 'cmd3', 'cmd4', 'cmd5', 'cmd6'];

  final msgCon = ScrollController();
  final sendCon = TextEditingController();
  final hostCon = TextEditingController();
  final portCon = TextEditingController();
  final btnCon1 = TextEditingController();
  final btnCon2 = TextEditingController();
  final btnCon3 = TextEditingController();
  final btnCon4 = TextEditingController();
  final btnCon5 = TextEditingController();
  final btnCon6 = TextEditingController();

  final messages = <String>[].obs;
  final allBlueNameAry = <String>[].obs;
  final isWifiOn = false.obs;
  final isBlueOn = false.obs;
  final connecting = false.obs;
  final tcpConnected = false.obs;
  final bleConnected = false.obs;
  final unstopped = true.obs;
  final rabbit = [0.0, 0.0, 0.0].obs;

  var version = '';
  final flutterBlue = FlutterBlue.instance;
  var scanResults = Map<String, ScanResult>();
  var bleIndex = -1;

  TabController? tabController;
  Socket? socket;
  BluetoothDevice? device;
  BluetoothCharacteristic? txCharacteristic; // 蓝牙读
  BluetoothCharacteristic? rxCharacteristic; // 蓝牙写

  final _streamSubscriptions = <StreamSubscription>[];
  StreamSubscription? _subscription;

  @override
  void onInit() {
    tabController = TabController(vsync: this, length: 3);
    hostCon.text = box.read('host') ?? '10.10.10.1';
    portCon.text = box.read('port') ?? '8080';
    listenNetwork();
    _initPackageInfo();

    _streamSubscriptions.add(accelerometerEvents.listen((event) {
      rabbit[0] = event.x;
      rabbit[1] = event.y;
      rabbit[2] = event.z;
    }));
    super.onInit();
  }

  @override
  void onClose() {
    tabController?.dispose();
    socket?.destroy();
    device?.disconnect();
    allBlueNameAry.clear();
    isWifiOn.value = false;
    isBlueOn.value = false;
    connecting.value = false;
    tcpConnected.value = false;
    bleConnected.value = false;
    _subscription?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _initPackageInfo() async {
    final _packageInfo = await PackageInfo.fromPlatform();
    version = _packageInfo.version;
  }

  void launchURL() async {
    const url = 'https://github.com/umbraHare';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void listenNetwork() {
    _streamSubscriptions
        .add(Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.wifi) {
        isWifiOn.value = true;
      } else {
        isWifiOn.value = false;
        socket?.destroy();
        tcpConnected.value = false;
        connecting.value = false;
      }
    }));
    _streamSubscriptions.add(flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        isBlueOn.value = true;
      } else {
        isBlueOn.value = false;
        device?.disconnect();
        bleConnected.value = false;
        allBlueNameAry.clear();
        connecting.value = false;
      }
    }));
    _streamSubscriptions.add(flutterBlue.scanResults.listen((results) {
      for (final r in results) {
        scanResults[r.device.name] = r;
        if (r.device.name.isNotEmpty &&
            !allBlueNameAry.contains(r.device.name)) {
          allBlueNameAry.add(r.device.name);
        }
      }
    }));
  }

  void connectSocket() async {
    final _host = hostCon.text;
    final _port = int.parse(portCon.text);
    connecting.value = true;
    socket?.destroy();
    tcpConnected.value = false;
    await Socket.connect(_host, _port, timeout: Duration(seconds: 1))
        .then((sock) {
      socket = sock;
      socket!.listen((data) {
        final msg = utf8.decode(data);
        print(msg);
        if (unstopped.value) {
          messages.add('tcp << $msg');
        }
      }, onError: (error) {
        print(error);
        socket?.destroy();
        tcpConnected.value = false;
      }, onDone: () {
        socket?.destroy();
        tcpConnected.value = false;
      }, cancelOnError: false);
      tcpConnected.value = true;
      box.write('host', _host);
      box.write('port', _port.toString());
    }).catchError((e) {
      print("Unable to connect: $e");
      Get.snackbar('Notice'.tr, 'Tcp connection failed...'.tr);
    });
    connecting.value = false;
  }

  void scanBle() async {
    connecting.value = true;
    _subscription?.cancel();
    device?.disconnect();
    bleConnected.value = false;
    allBlueNameAry.clear();
    bleIndex = -1;
    await flutterBlue.startScan(timeout: Duration(seconds: 6)).catchError(
        (e) => Get.snackbar('Notice'.tr, 'Ble scanning failed...'.tr));
    connecting.value = false;
  }

  void connectBle(int chooseBle) async {
    flutterBlue.stopScan();
    connecting.value = false;
    _subscription?.cancel();
    device?.disconnect();
    bleConnected.value = false;
    device = scanResults[allBlueNameAry[chooseBle]]!.device;

    await Future.delayed(Duration(seconds: 1));
    bleIndex = chooseBle;
    allBlueNameAry.refresh();
    connecting.value = true;

    await device!
        .connect(autoConnect: false, timeout: Duration(seconds: 10))
        .catchError((e) => print(e));
    await device!.discoverServices().then((services) {
      services.forEach((service) {
        final value = service.uuid.toString().toUpperCase().substring(4, 8);
        if (value == 'CDD0') {
          final characteristics = service.characteristics;
          characteristics.forEach((characteristic) {
            final valuex =
                characteristic.uuid.toString().toUpperCase().substring(4, 8);
            if (valuex == 'CDD1') {
              txCharacteristic = characteristic;
              // 收到下位机返回蓝牙数据回调监听
              _bleDataCallback();
            } else if (valuex == 'CDD2') {
              rxCharacteristic = characteristic;
            }
          });
        }
      });
    });
    connecting.value = false;
  }

  void _bleDataCallback() async {
    connecting.value = false;
    bleConnected.value = true;
    await txCharacteristic?.setNotifyValue(true).catchError((e) {}); // 概率报错
    _subscription = txCharacteristic!.value.listen((value) {
      final msg = utf8.decode(value);
      print(msg);
      if (unstopped.value) {
        messages.add('ble << $msg');
      }
    }, onError: (error) {
      print(error);
      device?.disconnect();
      bleConnected.value = false;
    }, onDone: () {
      device?.disconnect();
      bleConnected.value = false;
    }, cancelOnError: false);
  }

  void sendCmd(String msg) async {
    var _flag = false;
    try {
      socket!.write(msg);
      _flag = true;
    } catch (e) {}
    try {
      await rxCharacteristic!.write(utf8.encode(msg));
      _flag = true;
    } catch (e) {}
    if (!_flag) {
      Get.defaultDialog(
        middleText: 'Failed to send!'.tr,
        textCancel: 'To connect the device'.tr,
        onCancel: () {
          tabController!.index = 0;
        },
      );
    }
  }

  void sendMsg(String msg) async {
    var _flag = false;
    try {
      socket!.write(msg);
      messages.add('tcp >> ${sendCon.text}');
      _flag = true;
      msgCon.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {}
    try {
      await rxCharacteristic!.write(utf8.encode(msg));
      messages.add('ble >> ${sendCon.text}');
      _flag = true;
      msgCon.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {}
    if (!_flag) {
      Get.defaultDialog(
        middleText: 'Failed to send!'.tr,
        textCancel: 'To connect the device'.tr,
        onCancel: () {
          tabController!.index = 0;
        },
      );
    }
  }
}
