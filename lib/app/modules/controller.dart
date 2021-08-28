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
  final msgCon = ScrollController(); // 接收框
  final hostCon = TextEditingController(); // host输入框
  final portCon = TextEditingController(); // port输入框
  final sendCon = TextEditingController(); // 发送框
  final btnCon = List.generate(6, (i) => TextEditingController()); // 按钮组

  var uuidList = Map<String, String>();
  var uuidServer = <String>[];
  var uuidChara = <String>[];
  final uuidItem = ['', '', ''].obs; // 选中的uuid

  /// 获取存储语言
  Locale get locale =>
      box.read('locale') == 'zh_CN' ? Locale('zh', 'CN') : Locale('en', 'US');

  /// 获取存储主题
  ThemeData get theme =>
      box.read('isDarkMode') ?? false ? ThemeData.dark() : ThemeData.light();

  /// 获取存储命令
  List get commands =>
      box.read('commands') ?? ['cmd1', 'cmd2', 'cmd3', 'cmd4', 'cmd5', 'cmd6'];

  /// 获取服务UUID
  // List get uuid =>
  //     box.read('uuid') ??
  //     [
  //       '9ECADC24-0EE5-A9E0-93F3-A3B50100406E',
  //       '9ECADC24-0EE5-A9E0-93F3-A3B50100406E',
  //       '9ECADC24-0EE5-A9E0-93F3-A3B50100406E'
  //     ];

  final messages = <String>[].obs; // 接收信息
  final allBlueNameAry = <String>[].obs; // 搜索到的蓝牙列表
  final tcpState = 0.obs; // 0,已关闭;1,连接中;2,未连接;3,已连接
  final bleState = 0.obs; // 0,已关闭;1,连接中;2,未连接;3,已连接
  final unstopped = true.obs; // 是否暂停接收信息
  final rabbit = [0.0, 0.0, 0.0].obs;

  final _streamSubscriptions = <StreamSubscription>[];
  final flutterBlue = FlutterBlue.instance;
  var scanResults = Map<String, ScanResult>();
  var version = ''; // 版本号
  var bleIndex = -1; // 蓝牙列表中已选中的

  TabController? tabController;
  Socket? socket;
  BluetoothDevice? device;
  BluetoothCharacteristic? txCharacteristic; // 蓝牙读
  BluetoothCharacteristic? rxCharacteristic; // 蓝牙写
  StreamSubscription? _subscriptionTx; // 蓝牙读监听

  @override
  void onInit() {
    tabController = TabController(vsync: this, length: 3);
    hostCon.text = box.read('host') ?? '10.10.10.1';
    portCon.text = box.read('port') ?? '8080';
    _initPackageInfo();
    _streamSub();
    super.onInit();
  }

  @override
  void onClose() {
    tabController?.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    initTcp(0);
    initBle(0);
    super.onClose();
  }

  /// 获取版本号
  void _initPackageInfo() async {
    final _packageInfo = await PackageInfo.fromPlatform();
    version = _packageInfo.version;
  }

  /// 订阅流
  void _streamSub() {
    _streamSubscriptions
        .add(Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.wifi) {
        tcpState.value = 2;
      } else {
        initTcp(0);
      }
    }));
    _streamSubscriptions.add(flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        bleState.value = 2;
      } else {
        initBle(0);
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
    _streamSubscriptions.add(accelerometerEvents.listen((event) {
      rabbit[0] = event.x;
      rabbit[1] = event.y;
      rabbit[2] = event.z;
    }));
  }

  /// 网页跳转
  void launchURL() async {
    const url = 'https://github.com/umbraHare';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// TCP初始化 state:0,已关闭;1,连接中;2,未连接;3,已连接
  void initTcp(int state) {
    tcpState.value = state;
    socket?.destroy();
  }

  /// BLE初始化 state:0,已关闭;1,连接中;2,未连接;3,已连接
  void initBle(int state) {
    bleState.value = state;
    _subscriptionTx?.cancel();
    txCharacteristic = null;
    rxCharacteristic = null;
    device?.disconnect();
  }

  void connectSocket() async {
    final _host = hostCon.text;
    final _port = int.parse(portCon.text);
    initTcp(1);

    await Socket.connect(_host, _port, timeout: Duration(seconds: 1))
        .then((sock) {
      socket = sock;
      socket!.listen((data) {
        final msg = utf8.decode(data);
        if (unstopped.value) {
          messages.add('tcp << $msg');
          msgCon
              .animateTo(0,
                  duration: Duration(milliseconds: 300), curve: Curves.easeOut)
              .catchError((e) => print(e));
        }
      }, onError: (error) {
        print(error);
        initTcp(2);
      }, onDone: () {
        initTcp(2);
      }, cancelOnError: false);
      tcpState.value = 3; // 连接成功
      box.write('host', _host);
      box.write('port', _port.toString());
    }).catchError((e) {
      tcpState.value = 2;
      print("Unable to connect: $e");
      Get.snackbar('Notice'.tr, 'Tcp connection failed...'.tr);
    });
  }

  void scanBle() async {
    initBle(1);
    allBlueNameAry.clear();
    uuidList.clear();
    uuidServer.clear();
    uuidChara.clear();
    bleIndex = -1;
    uuidItem.value = ['', '', ''];
    await flutterBlue.startScan(timeout: Duration(seconds: 20)).catchError(
        (e) => Get.snackbar('Notice'.tr, 'Ble scanning failed...'.tr));
    bleState.value = 2;
  }

  void connectBle(int chooseBle) async {
    flutterBlue.stopScan();
    bleIndex = chooseBle;
    allBlueNameAry.refresh();
    await Future.delayed(Duration(seconds: 1));
    initBle(1);
    device = scanResults[allBlueNameAry[bleIndex]]!.device;
    try {
      await device!.connect(autoConnect: false, timeout: Duration(seconds: 10));
      var _flag = false, _flagTx = false, _flagRx = false;
      await device!.discoverServices().then((services) {
        services.forEach((service) {
          final value = service.uuid.toString();
          final characteristics = service.characteristics;

          characteristics.forEach((characteristic) {
            final valuex = characteristic.uuid.toString();
            uuidList[valuex] = value;
            _flag = true;
            if (value == uuidItem[0]) {
              if (!_flagTx && valuex == uuidItem[1]) {
                txCharacteristic = characteristic;
                _bleDataCallback();
                _flagTx = true;
              } else if (!_flagRx && valuex == uuidItem[2]) {
                rxCharacteristic = characteristic;
                _flagRx = true;
              }
            }
          });
        });
      });

      if (_flag && (!_flagTx || !_flagRx)) {
        uuidServer = uuidList.values.toSet().toList();
        uuidServer.sort();

        uuidChara = uuidList.keys
            .where((element) => uuidList[element] == uuidServer[0])
            .toList();
        uuidChara.sort();

        uuidItem.value = [uuidServer[0], uuidChara[0], uuidChara[0]];
        Get.snackbar('Notice'.tr, 'Please select UUID'.tr);
      }
      if (bleState.value != 3) {
        bleState.value = 2;
      }
    } catch (e) {
      Get.snackbar('Notice'.tr, 'error');
    }
  }

  void _bleDataCallback() async {
    await txCharacteristic!.setNotifyValue(true).catchError((e) {}); // 概率报错
    _subscriptionTx = txCharacteristic!.value.listen((value) {
      final msg = utf8.decode(value);
      if (unstopped.value) {
        messages.add('ble << $msg');
        msgCon
            .animateTo(0,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut)
            .catchError((e) => print(e));
      }
      bleState.value = 3;
    }, onError: (error) {
      print(error);
      initBle(2);
    }, onDone: () {
      initBle(2);
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
