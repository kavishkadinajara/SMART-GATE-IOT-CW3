class GateState {
  final bool isGate1Open;
  final bool isGate2Open;
  final DateTime lastOpenedGate1;
  final DateTime lastOpenedGate2;

  GateState({
    required this.isGate1Open,
    required this.isGate2Open,
    required this.lastOpenedGate1,
    required this.lastOpenedGate2,
  });

  GateState copyWith({
    bool? isGate1Open,
    bool? isGate2Open,
    DateTime? lastOpenedGate1,
    DateTime? lastOpenedGate2,
  }) {
    return GateState(
      isGate1Open: isGate1Open ?? this.isGate1Open,
      isGate2Open: isGate2Open ?? this.isGate2Open,
      lastOpenedGate1: lastOpenedGate1 ?? this.lastOpenedGate1,
      lastOpenedGate2: lastOpenedGate2 ?? this.lastOpenedGate2,
    );
  }
}
