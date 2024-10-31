class Machine {
  final String brand;
  final String machineId;
  final int yearOfManufacture;
  final double currentHourMeter;
  final String typeOfMachine;

  Machine({
    required this.brand,
    required this.machineId,
    required this.yearOfManufacture,
    required this.currentHourMeter,
  });

  // Optional: Add a factory constructor for creating from a map (e.g., from JSON)
  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      brand: map['brand'] as String,
      machineId: map['machineId'] as String,
      yearOfManufacture: map['yearOfManufacture'] as int,
      currentHourMeter: map['currentHourMeter'] as double,
    );
  }

  // Optional: Add a method to convert to a map (e.g., for serialization)
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'machineId': machineId,
      'yearOfManufacture': yearOfManufacture,
      'currentHourMeter': currentHourMeter,
    };
  }
}
