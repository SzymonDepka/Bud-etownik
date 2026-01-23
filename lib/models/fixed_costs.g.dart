// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_costs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FixedCostAdapter extends TypeAdapter<FixedCost> {
  @override
  final int typeId = 3;

  @override
  FixedCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedCost(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      period: fields[4] as FixedCostPeriod,
      startDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FixedCost obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.period)
      ..writeByte(5)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixedCostPeriodAdapter extends TypeAdapter<FixedCostPeriod> {
  @override
  final int typeId = 2;

  @override
  FixedCostPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FixedCostPeriod.monthly;
      case 1:
        return FixedCostPeriod.yearly;
      default:
        return FixedCostPeriod.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, FixedCostPeriod obj) {
    switch (obj) {
      case FixedCostPeriod.monthly:
        writer.writeByte(0);
        break;
      case FixedCostPeriod.yearly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedCostPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
