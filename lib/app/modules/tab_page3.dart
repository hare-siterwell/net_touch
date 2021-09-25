import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller.dart';

var _right = 30.0.obs; // 距左边的偏移
var _bottom = 30.0.obs; // 距顶部的偏移
var _radius = 20.0.obs; // 半径

class TabPage3 extends GetView<Controller> {
  @override
  Widget build(context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 30,
                  shrinkWrap: true,
                  children: [
                    ElevatedButton(
                      child: Text('button1'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[0]);
                      },
                      onLongPress: () {
                        controller.btnCon[0].text = controller.commands[0];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[0],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[0] = controller.btnCon[0].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text('button2'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[1]);
                      },
                      onLongPress: () {
                        controller.btnCon[1].text = controller.commands[1];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[1],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[1] = controller.btnCon[1].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text('button3'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[2]);
                      },
                      onLongPress: () {
                        controller.btnCon[2].text = controller.commands[2];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[2],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[2] = controller.btnCon[2].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text('button4'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[3]);
                      },
                      onLongPress: () {
                        controller.btnCon[3].text = controller.commands[3];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[3],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[3] = controller.btnCon[3].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text('button5'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[4]);
                      },
                      onLongPress: () {
                        controller.btnCon[4].text = controller.commands[4];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[4],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[4] = controller.btnCon[4].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text('button6'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[5]);
                      },
                      onLongPress: () {
                        controller.btnCon[5].text = controller.commands[5];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon[5],
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[5] = controller.btnCon[5].text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    TextField(
                      controller: controller.motorId,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'motorId'),
                    ),
                    TextField(
                      controller: controller.subdivision,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'subdivision'),
                    ),
                    TextField(
                      controller: controller.reset,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'reset'),
                    ),
                    GestureDetector(
                      child: TextField(
                        controller: controller.totalStep,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'totalStep'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                r'^([1-9]\d{0,8}|1[1-9]\d{0,8}|2000000000)$'),
                          ),
                        ],
                      ),
                      onHorizontalDragStart: (e) {
                        if (controller.totalStep.text.isEmpty) {
                          controller.totalStep.text = '0';
                        }
                        controller.motor[0] =
                            int.parse(controller.totalStep.text);
                      },
                      onHorizontalDragUpdate: (e) {
                        e.delta.dx > 0
                            ? controller.motor[0] += pow(e.delta.dx, 5).round()
                            : controller.motor[0] -=
                                pow(-e.delta.dx, 8).round();
                        if (controller.motor[0] < 0) {
                          controller.motor[0] = 0;
                        } else if (controller.motor[0] > 2000000000) {
                          controller.motor[0] = 2000000000;
                        }
                        controller.totalStep.text =
                            controller.motor[0].toString();
                      },
                    ),
                    GestureDetector(
                      child: TextField(
                        controller: controller.speedMax,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'speedMax'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                r'^([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$'),
                          ),
                        ],
                      ),
                      onHorizontalDragStart: (e) {
                        if (controller.speedMax.text.isEmpty) {
                          controller.speedMax.text = '0';
                        }
                        controller.motor[1] =
                            int.parse(controller.speedMax.text);
                      },
                      onHorizontalDragUpdate: (e) {
                        e.delta.dx > 0
                            ? controller.motor[1] += pow(e.delta.dx, 5).round()
                            : controller.motor[1] -=
                                pow(-e.delta.dx, 5).round();
                        if (controller.motor[1] < 0) {
                          controller.motor[1] = 0;
                        } else if (controller.motor[1] > 65535) {
                          controller.motor[1] = 65535;
                        }
                        controller.speedMax.text =
                            controller.motor[1].toString();
                      },
                    ),
                    GestureDetector(
                      child: TextField(
                        controller: controller.actionThreshold,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: 'actionThreshold'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                r'^([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$'),
                          ),
                        ],
                      ),
                      onHorizontalDragStart: (e) {
                        if (controller.actionThreshold.text.isEmpty) {
                          controller.actionThreshold.text = '0';
                        }
                        controller.motor[2] =
                            int.parse(controller.actionThreshold.text);
                      },
                      onHorizontalDragUpdate: (e) {
                        e.delta.dx > 0
                            ? controller.motor[2] += pow(e.delta.dx, 8).round()
                            : controller.motor[2] -=
                                pow(-e.delta.dx, 5).round();
                        if (controller.motor[2] < 0) {
                          controller.motor[2] = 0;
                        } else if (controller.motor[2] > 65535) {
                          controller.motor[2] = 65535;
                        }
                        controller.actionThreshold.text =
                            controller.motor[2].toString();
                      },
                    ),
                    SizedBox(),
                    IconButton(
                        onPressed: () {
                          controller.sendMotor(
                            controller.motorId.text,
                            controller.subdivision.text,
                            controller.reset.text,
                            controller.totalStep.text,
                            controller.speedMax.text,
                            controller.actionThreshold.text,
                          );
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          size: 60,
                        )),
                  ],
                ),
              ),
              Obx(
                () => Positioned(
                  right: _right.value + controller.rabbit[0] * 10,
                  bottom: _bottom.value - controller.rabbit[1] * 10,
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: _radius.value + controller.rabbit[2],
                      backgroundColor: Color(0),
                      child: Image.asset('assets/images/rabbit.png'),
                    ),
                    onPanUpdate: (e) {
                      _right.value -= e.delta.dx;
                      _bottom.value -= e.delta.dy;
                      _radius.value = 50;
                    },
                    onPanEnd: (e) {
                      _radius.value = 30;
                    },
                    onDoubleTap: () {
                      Get.toNamed('/test');
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
