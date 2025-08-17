import 'package:ember_mate/pages/connect/connect_page.dart';
import 'package:ember_mate/pages/control/control_page.dart';
import 'package:ember_mate/widgets/settings_widget.dart';
import 'package:ember_mate/providers/ember_discovery_provider.dart';
import 'package:ember_mate/providers/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp(
        title: 'EmberMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'SF Pro Display',
          textTheme: const TextTheme().apply(
            fontFamily: 'SF Pro Display',
            bodyColor: Colors.white,
            displayColor: Colors.white,
            decorationColor: Colors.white,
          ),
          primaryTextTheme: const TextTheme().apply(
            fontFamily: 'SF Pro Display',
            bodyColor: Colors.white,
            displayColor: Colors.white,
            decorationColor: Colors.white,
          ),
        ),
        home: const EmberMateHome(),
        onGenerateRoute: (settings) {
          if (settings.name == '/settings') {
            return MaterialPageRoute(builder: (context) => const SettingsWidget());
          }
          return MaterialPageRoute(builder: (context) => const EmberMateHome());
        },
      ),
    );
  }
}

class EmberMateHome extends StatefulWidget {
  const EmberMateHome({super.key});

  @override
  State<EmberMateHome> createState() => _EmberMateHomeState();
}

class _EmberMateHomeState extends State<EmberMateHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmberProvider>(
      builder: (context, emberProvider, child) {
        // Check if we have a connection by looking for the target temp characteristic
        final isConnected = emberProvider.targetTemp > 0;
        
        if (isConnected) {
          return const MugControlPage();
        } else {
          return const ConnectMugPage();
        }
      },
    );
  }
}
