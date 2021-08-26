import 'package:flutter/material.dart';
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
                  mainAxisSpacing: 50,
                  shrinkWrap: true,
                  children: [
                    ElevatedButton(
                      child: Text('button1'.tr),
                      onPressed: () {
                        controller.sendCmd(controller.commands[0]);
                      },
                      onLongPress: () {
                        controller.btnCon1.text = controller.commands[0];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon1,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[0] = controller.btnCon1.text;
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
                        controller.btnCon2.text = controller.commands[1];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon2,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[1] = controller.btnCon2.text;
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
                        controller.btnCon3.text = controller.commands[2];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon3,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[2] = controller.btnCon3.text;
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
                        controller.btnCon4.text = controller.commands[3];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon4,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[3] = controller.btnCon4.text;
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
                        controller.btnCon5.text = controller.commands[4];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon5,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[4] = controller.btnCon5.text;
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
                        controller.btnCon6.text = controller.commands[5];
                        Get.defaultDialog(
                          title: 'Modify'.tr,
                          content: TextField(
                            controller: controller.btnCon6,
                            decoration: InputDecoration(
                              labelText: 'Modify button commands here'.tr,
                            ),
                          ),
                          textCancel: 'ok'.tr,
                          onCancel: () {
                            controller.commands[5] = controller.btnCon6.text;
                            controller.box
                                .write('commands', controller.commands);
                          },
                        );
                      },
                    ),
                    SizedBox(),
                    ElevatedButton(
                      child: Text('up'.tr),
                      onPressed: () {
                        controller.sendCmd('up');
                      },
                    ),
                    SizedBox(),
                    ElevatedButton(
                      child: Text('left'.tr),
                      onPressed: () {
                        controller.sendCmd('left');
                      },
                    ),
                    ElevatedButton(
                      child: Text('ok'.tr),
                      onPressed: () {
                        controller.sendCmd('ok');
                      },
                    ),
                    ElevatedButton(
                      child: Text('right'.tr),
                      onPressed: () {
                        controller.sendCmd('right');
                      },
                    ),
                    SizedBox(),
                    ElevatedButton(
                      child: Text('down'.tr),
                      onPressed: () {
                        controller.sendCmd('down');
                      },
                    ),
                    SizedBox(),
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
