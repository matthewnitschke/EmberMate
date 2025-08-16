import 'package:ember_mate/providers/ember_discovery_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/mug_control_page.dart';
import 'package:ember_mate/connect_mug_page.dart';
import 'package:ember_mate/providers/ember_provider.dart';

void main() {
  runApp(const EmberMateApp());
}

class EmberMateApp extends StatelessWidget {
  const EmberMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmberProvider()),
        ChangeNotifierProvider(create: (_) => EmberDiscoveryProvider()),
      ],
      child: MaterialApp(
        title: 'EmberMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'SF Pro Display',
          textTheme: const TextTheme().apply(
            fontFamily: 'SF Pro Display',
          ),
        ),
        initialRoute: '/connect',
        routes: {
          '/': (context) => const MugControlPage(),
          '/connect': (context) => const ConnectMugPage(),
        },
      ),
    );
  }
}
