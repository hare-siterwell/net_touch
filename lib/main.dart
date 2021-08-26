import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/languages/translations.dart';
import 'app/modules/controller.dart';
import 'app/modules/home.dart';

void main() async {
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(context) {
    final controller = Get.put(Controller());
    return GetMaterialApp(
      initialRoute: '/',
      theme: controller.theme,
      locale: controller.locale,
      translations: MyTranslations(),
      getPages: [
        GetPage(name: '/', page: () => Home()),
        GetPage(
          name: '/test',
          page: () => Image.asset('assets/images/rabbit.png'),
        ),
      ],
    );
  }
}
