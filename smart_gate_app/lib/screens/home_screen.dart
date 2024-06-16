import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gate_provider.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Security Gate'),
      ),
      body: Consumer<GateProvider>(
        builder: (context, gateProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _gateWidget(gateProvider, 1),
                const SizedBox(height: 30),
                _gateWidget(gateProvider, 2),
                const SizedBox(height: 30),
                const Text(
                  'Gate Information',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Gate 1 Last opened: ${gateProvider.gateState.lastOpenedGate1}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Gate 2 Last opened: ${gateProvider.gateState.lastOpenedGate2}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/notifications');
          }
        },
      ),
    );
  }

  Widget _gateWidget(GateProvider gateProvider, int gateNumber) {
    bool isOpen = gateNumber == 1 ? gateProvider.gateState.isGate1Open : gateProvider.gateState.isGate2Open;
    String gateText = 'Gate $gateNumber';
    String statusText = isOpen ? 'Open' : 'Closed';
    String buttonText = isOpen ? 'Close Gate $gateNumber' : 'Open Gate $gateNumber';
    Color buttonColor = isOpen ? Colors.red : Colors.green;
    VoidCallback onPressed;

    if (isOpen) {
      onPressed = gateNumber == 1 ? gateProvider.closeGate1 : gateProvider.closeGate2;
    } else {
      onPressed = gateNumber == 1 ? gateProvider.openGate1 : gateProvider.openGate2;
    }

    return Column(
      children: [
        Text(
          gateText,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(
          'Status: $statusText',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        CustomButton(
          text: buttonText,
          color: buttonColor,
          onPressed: onPressed,
        ),
      ],
    );
  }
}