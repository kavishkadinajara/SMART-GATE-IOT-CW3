import 'package:firebase_database/firebase_database.dart';
import '../models/gate_state.dart';

class GateService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('gates/main_gate');

  Future<void> updateGateState(GateState state) async {
    try {
      await _databaseReference.update({
        'isGate1Open': state.isGate1Open,
        'lastOpenedGate1': state.lastOpenedGate1.toIso8601String(),
        'isGate2Open': state.isGate2Open,
        'lastOpenedGate2': state.lastOpenedGate2.toIso8601String(),
      });
    } catch (error) {
      print('Failed to set gate state: $error');
    }
  }

  Stream<GateState> getGateState() {
    return _databaseReference.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      // Debugging: Print the data fetched from Firebase
      print('Data fetched from Firebase: $data');

      if (data == null) {
        return GateState(
          isGate1Open: false,
          isGate2Open: false,
          lastOpenedGate1: DateTime.now(),
          lastOpenedGate2: DateTime.now(),
        );
      }

      try {
        return GateState(
          isGate1Open: data['isGate1Open'] ?? false,
          lastOpenedGate1: DateTime.tryParse(data['lastOpenedGate1'] ?? '') ?? DateTime.now(),
          isGate2Open: data['isGate2Open'] ?? false,
          lastOpenedGate2: DateTime.tryParse(data['lastOpenedGate2'] ?? '') ?? DateTime.now(),
        );
      } catch (e) {
        print('Error parsing data: $e');
        return GateState(
          isGate1Open: false,
          isGate2Open: false,
          lastOpenedGate1: DateTime.now(),
          lastOpenedGate2: DateTime.now(),
        );
      }
    });
  }
}
