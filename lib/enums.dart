enum VehicleType {
  unknown(label: "Keine Angabe", value: 0),
  bike(label: "Normales Fahrrad", value: 1),
  city(label: "Citybike", value: 2),
  dutch(label: "Hollandrad", value: 3),
  touring(label: "Tourenrad", value: 4),
  trekking(label: "Trekkingrad", value: 5),
  folding(label: "Klapprad", value: 6),
  mtb(label: "Mountainbike", value: 7),
  road(label: "Rennrad", value: 8),
  fixie(label: "Fixie / Singlespeed", value: 9),
  gravel(label: "Gravelbike", value: 10),
  ebike(label: "E-Bike", value: 11),
  cargo(label: "Lastenrad", value: 12),
  ecargo(label: "E-Lastenrad", value: 13),
  recumbent(label: "Liegerad", value: 14),
  velomobile(label: "Velomobil", value: 15),
  other(label: "Anderes", value: 9999);

  const VehicleType({
    required this.label,
    required this.value
  });

  final String label;
  final int value;
}

enum RideType {
  unknown(label:"Keine Angabe", value:0),
  commute(label:"Arbeitsweg", value:1),
  common(label:"Regelmäßiger Weg", value:2),
  recreational(label:"Freizeitfahrt", value:3),
  sport(label:"Sport / Trainingsfahrt", value:4),
  other(label:"Anderes", value:9999);

  const RideType({
    required this.label,
    required this.value
  });

  final String label;
  final int value;
}

enum MountType {
  unknown(label: "Keine Angabe", value: 0),
  jacket(label: "Jackentasche", value: 1),
  pants(label: "Hosentasche", value: 2),
  vehicle(label: "Am Rad", value: 3),
  other(label: "Anderes", value: 9999);

  const MountType({
    required this.label,
    required this.value
  });

  final String label;
  final int value;
}

VehicleType vehicleTypeByValue(int value) {
  for (VehicleType t in VehicleType.values) {
    if (t.value == value) {
      return t;
    }
  }
  return VehicleType.unknown;
}

RideType rideTypeByValue(int value) {
  for (RideType t in RideType.values) {
    if (t.value == value) {
      return t;
    }
  }
  return RideType.unknown;
}

MountType mountTypeByValue(int value) {
  for (MountType t in MountType.values) {
    if (t.value == value) {
      return t;
    }
  }
  return MountType.unknown;
}


