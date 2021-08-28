import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller.dart';

class TabPage1 extends GetView<Controller> {
  @override
  Widget build(context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.hostCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'host',
                    helperText: 'xxx.xxx.xxx.xxx',
                  ),
                  inputFormatters: [
                    // ipv4输入校验
                    FilteringTextInputFormatter.allow(
                      RegExp(
                          r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d))))$|^(\d{1,3}\.\d{1,3}\.(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.?)$|^(\d{1,3}\.(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.?)$|^((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.?)$'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: controller.portCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'port',
                    helperText: '1~65535',
                  ),
                  inputFormatters: [
                    // 端口号校验
                    FilteringTextInputFormatter.allow(
                      RegExp(
                          r'^([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Obx(
                () => OutlinedButton(
                  onPressed: controller.tcpState.value == 0
                      ? null
                      : () {
                          switch (controller.tcpState.value) {
                            case 1:
                              {}
                              break;
                            case 2:
                              controller.connectSocket();
                              break;
                            case 3:
                              controller.initTcp(2);
                              break;
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: controller.tcpState.value != 0
                        ? BorderSide(width: 2, color: Colors.green)
                        : null,
                  ),
                  child: controller.tcpState.value != 3
                      ? Icon(Icons.wifi)
                      : Icon(Icons.wifi_off),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  Text('Status:    '.tr),
                  Obx(
                    () => controller.tcpState.value == 1 ||
                            controller.bleState.value == 1
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())
                        : controller.tcpState.value == 3 &&
                                controller.bleState.value == 3
                            ? Text('tcp & ble connected'.tr)
                            : controller.tcpState.value == 3
                                ? Text('tcp connected'.tr)
                                : controller.bleState.value == 3
                                    ? Text('ble connected'.tr)
                                    : Text('unconnected'.tr),
                  ),
                  Spacer(),
                  Obx(
                    () => OutlinedButton(
                      onPressed: controller.bleState.value == 0
                          ? null
                          : () {
                              switch (controller.bleState.value) {
                                case 1:
                                  {
                                    controller.flutterBlue.stopScan();
                                    controller.initBle(2);
                                  }
                                  break;
                                case 2:
                                  controller.scanBle();
                                  break;
                                case 3:
                                  controller.initBle(2);
                                  break;
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: controller.bleState.value != 0
                            ? BorderSide(width: 2, color: Colors.blue)
                            : null,
                      ),
                      child: controller.bleState.value == 1 ||
                              controller.bleState.value == 3
                          ? Icon(Icons.bluetooth_disabled)
                          : Icon(Icons.bluetooth),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              Container(
                alignment: Alignment(-1, -1),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue),
                ),
                child: Obx(
                  () => ListView.builder(
                    itemCount: controller.allBlueNameAry.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${controller.allBlueNameAry[index]}',
                          style: index == controller.bleIndex
                              ? TextStyle(
                                  color: Colors.lightBlue,
                                )
                              : null,
                        ),
                        onTap: () {
                          controller.connectBle(index);
                        },
                      );
                    },
                  ),
                ),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Obx(
                      () => DropdownButton(
                        isExpanded: true,
                        hint: Text('UUID Server'),
                        items: controller.uuidServer
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          controller.uuidChara = controller.uuidList.keys
                              .where((element) =>
                                  controller.uuidList[element] ==
                                  value.toString())
                              .toList();
                          controller.uuidChara.sort();

                          controller.uuidItem.value = [
                            value.toString(),
                            controller.uuidChara[0],
                            controller.uuidChara[0]
                          ];
                        },
                        value: controller.uuidItem[0],
                      ),
                    ),
                    Obx(
                      () => DropdownButton(
                        isExpanded: true,
                        hint: Text('UUID Tx'),
                        items: controller.uuidChara
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            controller.uuidItem[1] = value.toString(),
                        value: controller.uuidItem[1],
                      ),
                    ),
                    Obx(
                      () => DropdownButton(
                        isExpanded: true,
                        hint: Text('UUID Rx'),
                        items: controller.uuidChara
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            controller.uuidItem[2] = value.toString(),
                        value: controller.uuidItem[2],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
