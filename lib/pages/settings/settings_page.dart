import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/providers/ember_provider.dart';
import 'package:ember_mate/providers/app_state_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Since we're in a popover, we need to handle navigation differently
                        // We'll use a method channel to go back to the main view
                        const MethodChannel('ember_mate/menubar').invokeMethod('goBack');
                      },
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          'Temperature',
                          [
                            Consumer<EmberProvider>(
                              builder: (context, emberProvider, child) {
                                return SwitchListTile(
                                  title: const Text(
                                    'Use Fahrenheit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: const Text(
                                    'Display temperature in Fahrenheit instead of Celsius',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  value: emberProvider.temperatureUnit == TemperatureUnit.fahrenheit,
                                  onChanged: (value) {
                                    emberProvider.temperatureUnit = value 
                                        ? TemperatureUnit.fahrenheit 
                                        : TemperatureUnit.celsius;
                                  },
                                  activeColor: Colors.blue,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          'Connection',
                          [
                            Consumer<EmberProvider>(
                              builder: (context, emberProvider, child) {
                                final isConnected = emberProvider.targetTemp > 0;
                                return ListTile(
                                  title: const Text(
                                    'Connection Status',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    isConnected ? 'Connected to ${emberProvider.name}' : 'Not connected',
                                    style: TextStyle(
                                      color: isConnected ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                                    color: isConnected ? Colors.green : Colors.red,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          'About',
                          [
                            const ListTile(
                              title: Text(
                                'Version',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '1.0.0',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const ListTile(
                              title: Text(
                                'EmberMate',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Control your Ember mug from your menubar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800]!.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
