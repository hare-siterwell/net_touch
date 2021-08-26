import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

var _validate = true.obs; // 输入校验

class TabPage2 extends GetView<Controller> {
  @override
  Widget build(context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                alignment: Alignment(-1, -1),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent, width: 1.0),
                  color: Color(0xAA042028),
                ),
                child: Obx(
                  () => ListView.builder(
                    controller: controller.msgCon,
                    itemCount: controller.messages.length,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Text(
                        '${controller.messages[controller.messages.length - index - 1]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF00FF40),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 30,
                top: 30,
                child: Column(
                  children: [
                    OutlinedButton(
                      child: Text('clear'.tr),
                      onPressed: controller.messages.clear,
                    ),
                    Obx(
                      () => Switch(
                        value: controller.unstopped.value,
                        onChanged: (value) {
                          controller.unstopped.value = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment(-1, -1),
          margin: EdgeInsets.only(left: 20, right: 16, bottom: 20),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Obx(
                  () => TextField(
                    controller: controller.sendCon,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 100,
                    onTap: () {
                      _validate.value = true;
                    },
                    decoration: InputDecoration(
                      labelText: _validate.value
                          ? 'Message'.tr
                          : 'Value can\'t be empty!'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 32,
                    ),
                    onPressed: () {
                      if (controller.sendCon.text.isEmpty) {
                        _validate.value = false;
                      } else {
                        _validate.value = true;
                        controller.sendMsg(controller.sendCon.text);
                      }
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
