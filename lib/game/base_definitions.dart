import 'dart:math';

import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

/// A value that can be modified linearly by a list of modifiers.
/// modifiedValue = originalValue + sum(modifiers)
class LinearModifiableValue<O extends num> {
  final O? minValue;
  final O? maxValue;
  final O originalValue;
  final modifiers = List<LinearValueModifier<O>>.empty(growable: true);

  LinearModifiableValue(
    this.originalValue, {
    this.maxValue,
    this.minValue,
  });
  O get modifiedValue {
    final result = modifiers.fold(
      originalValue,
      (value, modifier) => value + modifier.modify(originalValue) as O,
    );
    if (maxValue != null && result > maxValue!) {
      return maxValue!;
    } else if (minValue != null && result < minValue!) {
      return minValue!;
    } else {
      return result;
    }
  }

  void operator +(LinearValueModifier<O> modifier) {
    modifiers.add(modifier);
  }

  void operator -(LinearValueModifier<O> modifier) {
    modifiers.remove(modifier);
  }
}

/// Each LinearValueModifier apply a linear modification to a value.
/// Return the diff to be added to the original value.
/// For example:
/// - A modifier that `+10%` to the value should return `value * 0.1`.
/// - A modifier that `-5` should return `-5`.
/// - A modifier that `+10% + 5` should return `value * 0.1 + 5`.
abstract interface class LinearValueModifier<V extends num> {
  V modify(V originValue) => originValue;

  factory LinearValueModifier.fromFunction(V Function(V) modifyFunction) {
    return _LinearValueModifier<V>(modifyFunction);
  }
}

class _LinearValueModifier<V extends num> implements LinearValueModifier<V> {
  final V Function(V) modifyFunction;
  _LinearValueModifier(this.modifyFunction);

  @override
  V modify(V originValue) => modifyFunction(originValue);
}

/// 伤害元素
enum CombatType implements EnumValue<int> {
  /// 物理
  physical(0),

  /// 火
  fire(1),

  /// 冰
  ice(2),

  /// 雷
  lightning(3),

  /// 风
  wind(4),

  /// 量子
  quantum(5),

  /// 虚数
  imaginary(6),
  ;

  @override
  final int value;
  const CombatType(this.value);

  @override
  toJson() => value;
}

class CombatTypeBuff implements JsonSerializable {
  final buffs = <CombatType, LinearModifiableValue<double>>{};

  CombatTypeBuff({
    double physical = 0,
    double fire = 0,
    double ice = 0,
    double lightning = 0,
    double wind = 0,
    double quantum = 0,
    double imaginary = 0,
  }) {
    buffs.addEntries([
      MapEntry(CombatType.physical, LinearModifiableValue(physical)),
      MapEntry(CombatType.fire, LinearModifiableValue(fire)),
      MapEntry(CombatType.ice, LinearModifiableValue(ice)),
      MapEntry(CombatType.lightning, LinearModifiableValue(lightning)),
      MapEntry(CombatType.wind, LinearModifiableValue(wind)),
      MapEntry(CombatType.quantum, LinearModifiableValue(quantum)),
      MapEntry(CombatType.imaginary, LinearModifiableValue(imaginary)),
    ]);
  }

  double getBuff(CombatType type) {
    return buffs[type]!.modifiedValue;
  }

  /// 未写明伤害类型的伤害提高
  void operator +(LinearValueModifier<double> modifier) {
    buffs.forEach((key, value) {
      value + modifier;
    });
  }

  void operator -(LinearValueModifier<double> modifier) {
    buffs.forEach((key, value) {
      value - modifier;
    });
  }

  @override
  toJson() {
    return buffs.map(
      (key, value) => MapEntry(key.toJson(), value.modifiedValue),
    );
  }
}

class CombatTypeResistance implements JsonSerializable {
  final resistances = <CombatType, LinearModifiableValue<double>>{};

  CombatTypeResistance({
    double physical = 0,
    double fire = 0,
    double ice = 0,
    double lightning = 0,
    double wind = 0,
    double quantum = 0,
    double imaginary = 0,
  }) {
    resistances.addEntries([
      MapEntry(CombatType.physical, LinearModifiableValue(physical)),
      MapEntry(CombatType.fire, LinearModifiableValue(fire)),
      MapEntry(CombatType.ice, LinearModifiableValue(ice)),
      MapEntry(CombatType.lightning, LinearModifiableValue(lightning)),
      MapEntry(CombatType.wind, LinearModifiableValue(wind)),
      MapEntry(CombatType.quantum, LinearModifiableValue(quantum)),
      MapEntry(CombatType.imaginary, LinearModifiableValue(imaginary)),
    ]);
  }

  double getResistance(CombatType type) {
    return resistances[type]!.modifiedValue;
  }

  @override
  toJson() {
    return resistances.map(
      (key, value) => MapEntry(key.toJson(), value.modifiedValue),
    );
  }
}

enum DamageType implements EnumValue<int> {
  /// 普通攻击
  normalAttack(0),

  /// 战技
  skill(1),

  /// 终结技
  ultimate(2),

  /// 持续伤害
  damageOverTime(3),

  /// 追加攻击伤害
  followUp(4),

  /// 暴击伤害
  critical(5),

  /// 附加伤害
  addUp(6),
  ;

  @override
  final int value;
  const DamageType(this.value);

  @override
  int toJson() => value;
}

/// 伤害详情
class AttackerDamageDetail implements JsonSerializable {
  /// 基数（基础值与倍率计算后）
  double base;

  /// 暴击率
  double critRate;

  /// 暴击伤害
  double critDamage;

  /// 伤害元素类型
  CombatType combatType;

  /// 伤害类型
  List<DamageType> damageTypes;

  /// 对应类型的伤害加成
  double combatTypeBuff;

  /// 伤害减弱
  double weaken;

  /// 是否暴击
  bool crit = false;

  /// 韧性伤害
  double toughness;

  /// 最终伤害
  double get damage =>
      base * // 基础区
      (1 + critRate * critDamage * (crit ? 1 : 0)) * // 暴击区
      (1 + combatTypeBuff) * // 增伤区
      (1 - weaken); // 造成伤害减少

  AttackerDamageDetail({
    required this.base,
    required this.critRate,
    required this.critDamage,
    this.weaken = 0,
    required this.combatType,
    required this.damageTypes,
    required this.combatTypeBuff,
    this.toughness = 0,
    bool? forceCrit,
  }) {
    if (forceCrit != null) {
      crit = forceCrit;
    } else {
      crit = Random().nextDouble() < critRate;
    }
  }

  @override
  toJson() {
    return {
      'base': base,
      'critRate': critRate,
      'critDamage': critDamage,
      'type': combatType.toJson(),
      'damageTypes': damageTypes.map((e) => e.toJson()).toList(),
      'combatTypeBuff': combatTypeBuff,
      'weaken': weaken,
      'crit': crit,
      'damage': damage,
    };
  }
}

class DamageTable implements JsonSerializable {
  final Map<BattleUnit, AttackerDamageDetail> damages;

  DamageTable(this.damages);

  factory DamageTable.single(BattleUnit target, AttackerDamageDetail detail) =>
      DamageTable({
        target: detail,
      });

  @override
  toJson() {
    return damages.entries
        .map(
          (e) => {
            'target': e.key.toJson(),
            'damage': e.value.toJson(),
          },
        )
        .toList();
  }
}
