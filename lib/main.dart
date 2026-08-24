import 'package:flutter/material.dart';
import 'package:practise_flutter_websockets_order_app/app/router/app_router.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  //Required to access rootBundle assets before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for config loading & Service registration
  await di.initServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Order websocket sample App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
