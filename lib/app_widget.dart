import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_case/modules/bluetooth_explorer/views/pages/home_page.dart';

// import 'modules/counter/pages/counter_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const CounterPage(),
      home: HomePage(),
      // home:,
    );
  }
}
