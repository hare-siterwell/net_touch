import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'tab_page1.dart';
import 'tab_page2.dart';
import 'tab_page3.dart';

class Home extends GetView<Controller> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NetTouch'),
        centerTitle: true,
        bottom: TabBar(
          controller: controller.tabController,
          tabs: [
            Tab(text: 'Device'.tr),
            Tab(text: 'Dialog'.tr),
            Tab(text: 'Control'.tr),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'About'.tr,
                middleText: '${controller.version}\nCopyleft@ 2021 umbraHare.',
                content: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '${controller.version}\nCopyleft@ 2021 '),
                      TextSpan(
                        text: 'umbraHare',
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => controller.launchURL(),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Text('Language'.tr),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Get.isDarkMode
                      ? Text('Light Mode'.tr)
                      : Text('Dark Mode'.tr),
                ),
              ];
            },
            onSelected: (object) {
              switch (object) {
                case 1:
                  if (Get.locale == Locale('en', 'US')) {
                    Get.updateLocale(Locale('zh', 'CN'));
                    controller.box.write('locale', 'zh_CN');
                  } else {
                    Get.updateLocale(Locale('en', 'US'));
                    controller.box.write('locale', 'en_US');
                  }
                  break;
                case 2:
                  if (Get.isDarkMode) {
                    Get.changeTheme(ThemeData.light());
                    controller.box.write('isDarkMode', false);
                  } else {
                    Get.changeTheme(ThemeData.dark());
                    controller.box.write('isDarkMode', true);
                  }
                  break;
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onPanDown: (e) {
            // 键盘弹出时，点击空白处使TextField失去焦点
            if (context.mediaQueryViewInsets.bottom > 0) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
          child: TabBarView(
            controller: controller.tabController,
            children: [
              TabPage1(),
              TabPage2(),
              TabPage3(),
            ],
          ),
        ),
      ),
    );
  }
}
