import 'package:flutter/material.dart';
import '../models/gate_state.dart';
import '../services/gate_service.dart';
import '../services/notification_service.dart';

class GateProvider with ChangeNotifier {
  final GateService _gateService = GateService();
  final NotificationService _notificationService;

  GateState _gateState = GateState(
    isGate1Open: false,
    isGate2Open: false,
    lastOpenedGate1: DateTime.now(),
    lastOpenedGate2: DateTime.now(),
  );

  bool _disposed = false;

  GateState get gateState => _gateState;

  Stream<GateState> get gateStateStream => _gateService.getGateState();

  GateProvider(this._notificationService) {
    _loadInitialGateState();
  }

  void _loadInitialGateState() {
    _gateService.getGateState().listen((state) {
      if (!_disposed) {
        _gateState = state;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void openGate1({bool fromKeypad = false}) {
    _updateGateState(
      _gateState.copyWith(
        isGate1Open: true,
        lastOpenedGate1: DateTime.now(),
      ),
      "Gate 1 Opened",
      "Gate 1 was opened at ${DateTime.now()} via ${fromKeypad ? 'Keypad' : 'Mobile App'}",
    );
  }

  void closeGate1({bool fromKeypad = false}) {
    _updateGateState(
      _gateState.copyWith(isGate1Open: false),
      "Gate 1 Closed",
      "Gate 1 was closed at ${DateTime.now()} via ${fromKeypad ? 'Keypad' : 'Mobile App'}",
    );
  }

  void openGate2({bool fromKeypad = false}) {
    _updateGateState(
      _gateState.copyWith(
        isGate2Open: true,
        lastOpenedGate2: DateTime.now(),
      ),
      "Gate 2 Opened",
      "Gate 2 was opened at ${DateTime.now()} via ${fromKeypad ? 'Keypad' : 'Mobile App'}",
    );
  }

  void closeGate2({bool fromKeypad = false}) {
    _updateGateState(
      _gateState.copyWith(isGate2Open: false),
      "Gate 2 Closed",
      "Gate 2 was closed at ${DateTime.now()} via ${fromKeypad ? 'Keypad' : 'Mobile App'}",
    );
  }

  void _updateGateState(GateState newState, [String? title, String? body]) {
    if (!_disposed) {
      _gateState = newState;
      _gateService.updateGateState(_gateState);
      if (title != null && body != null) {
        _notificationService.addNotification(title, body);
      }
      notifyListeners();
    }
  }
}
