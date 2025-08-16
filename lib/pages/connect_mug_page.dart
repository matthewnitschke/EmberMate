import 'package:ember_mate/providers/ember_discovery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/components/button.dart';
import 'package:ember_mate/components/gradient_background.dart';
import 'package:ember_mate/providers/ember_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectMugPage extends StatefulWidget {
  const ConnectMugPage({super.key});

  @override
  State<ConnectMugPage> createState() => _ConnectMugPageState();
}

class _ConnectMugPageState extends State<ConnectMugPage> {
  @override
  void initState() {
    super.initState();
    // Start scanning when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmberDiscoveryProvider>().startScanning();
    });
  }

  @override
  void dispose() {
    context.read<EmberDiscoveryProvider>().stopScanning();
    super.dispose();
  }

  void _connectToMug(BluetoothDevice device) async {    
    final service = await context.read<EmberDiscoveryProvider>().connect(device);
    if (service == null || !mounted) return;

    await context.read<EmberProvider>().connect(device, service);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      topColor: const Color(0xFFD4B08C),
      bottomColor: const Color(0xFF8B5A3C),
      child: Consumer<EmberDiscoveryProvider>(
        builder: (context, discoveryProvider, child) {
          return Column(
            children: [
              // Title
              const Text(
                'Connect a Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Horizontal scrollable device cards
              SizedBox(
                height: 90,
                child: discoveryProvider.discoveredMugs.isEmpty
                    ? const Center(
                        child: Text(
                          'No Ember mugs found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: discoveryProvider.discoveredMugs.length,
                        itemBuilder: (context, index) {
                          final device = discoveryProvider.discoveredMugs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Button(
                              width: 90,
                              height: 90,
                              onTap: () => _connectToMug(device),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Coffee mug icon
                                  const SFIcon(
                                    SFIcons.sf_cup_and_saucer_fill,
                                    color: Colors.white,
                                    fontSize: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  // Device name
                                  Text(
                                    device.platformName.isNotEmpty 
                                        ? device.platformName 
                                        : 'Ember Cup 2',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Refresh button
              Button(
                onTap: discoveryProvider.isScanning ? null : () => discoveryProvider.startScanning(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SFIcon(
                        discoveryProvider.isScanning ? SFIcons.sf_arrow_clockwise : SFIcons.sf_arrow_clockwise,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        discoveryProvider.isScanning ? 'Scanning...' : 'Refresh',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}