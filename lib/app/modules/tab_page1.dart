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
                  onPressed:
                      controller.isWifiOn.value && !controller.connecting.value
                          ? controller.connectSocket
                          : null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: controller.isWifiOn.value
                        ? BorderSide(width: 2, color: Colors.green)
                        : null,
                  ),
                  child: Icon(Icons.wifi),
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
                    () => controller.connecting.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())
                        : controller.tcpConnected.value &&
                                controller.bleConnected.value
                            ? Text('tcp & ble connected'.tr)
                            : controller.tcpConnected.value
                                ? Text('tcp connected'.tr)
                                : controller.bleConnected.value
                                    ? Text('ble connected'.tr)
                                    : Text('unconnected'.tr),
                  ),
                  Spacer(),
                  Obx(
                    () => OutlinedButton(
                      onPressed: controller.isBlueOn.value &&
                              !controller.connecting.value
                          ? controller.scanBle
                          : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: controller.isBlueOn.value
                            ? BorderSide(width: 2, color: Colors.blue)
                            : null,
                      ),
                      child: Icon(Icons.bluetooth),
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
            ],
          ),
        ),
      ],
    );
  }
}
