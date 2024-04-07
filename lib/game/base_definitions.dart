import 'dart:math';

import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

/// A value that can be modified linearly by a list of modifiers.
/// modifiedValue = originalValue + sum(modifiers)
class LinearModifiableValue<O extends num> implements JsonSerializable<List> {
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
    double multiplier = 1;
    double constant = 0;

    for (final modifier in modifiers) {
      multiplier += modifier.multiplier;
      constant += modifier.constant;
    }

    final result = originalValue * multiplier + constant;

    if (maxValue != null && result > maxValue!) {
      return maxValue!;
    } else if (minValue != null && result < minValue!) {
      return minValue!;
    } else {
      return result as O;
    }
  }

  /// Return modified value without those modifiers that are marked as fromConvertedValue.
  O operator ~() {
    double multiplier = 1;
    double constant = 0;

    for (final modifier in modifiers) {
      if (modifier.fromConvertedValue) {
        continue;
      }
      multiplier += modifier.multiplier;
      constant += modifier.constant;
    }

    final result = originalValue * multiplier + constant;

    if (maxValue != null && result > maxValue!) {
      return maxValue!;
    } else if (minValue != null && result < minValue!) {
      return minValue!;
    } else {
      return result as O;
    }
  }

  void operator +(LinearValueModifier<O> modifier) {
    modifiers.add(modifier);
  }

  void operator -(LinearValueModifier<O> modifier) {
    modifiers.remove(modifier);
  }

  @override
  List toJson() => [originalValue, modifiedValue];
}

/// Each LinearValueModifier apply a linear modification to a value.
class LinearValueModifier<V extends num> implements JsonSerializable<String> {
  final double multiplier;
  final double constant;

  final bool fromConvertedValue;

  LinearValueModifier({
    this.multiplier = 1,
    this.constant = 0,
    this.fromConvertedValue = false,
  });

  /// Create from a string expression.
  /// Example:
  /// - "25%" => LinearValueModifier(0.25, 0)
  /// - "+42" => LinearValueModifier(0, 42)
  /// - "25% +42" => LinearValueModifier(0.25, 42)
  /// - "-10%" => LinearValueModifier(-0.1, 0)
  /// - "! 25%" => LinearValueModifier(0.25, 0, fromConvertedValue: true)
  factory LinearValueModifier.from(String expression) {
    final parts = expression.split(' ');
    double multiplier = 0;
    double constant = 0;
    bool fromConvertedValue = false;
    for (final part in parts) {
      if (part == '!') {
        fromConvertedValue = true;
        continue;
      }
      if (part.endsWith('%')) {
        multiplier = double.parse(part.substring(0, part.length - 1)) / 100;
      } else {
        constant = double.parse(part);
      }
    }
    return LinearValueModifier(
      multiplier: multiplier,
      constant: constant,
      fromConvertedValue: fromConvertedValue,
    );
  }

  @override
  String toJson() {
    return '${fromConvertedValue ? '! ' : ''}${multiplier * 100}%${constant >= 0 ? ' +' : ' -'}$constant';
  }
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

  factory CombatType.fromJson(int value) =>
      values.firstWhere((e) => e.value == value);
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
  // critical(5),

  /// 附加伤害
  addUp(6),
  ;

  @override
  final int value;
  const DamageType(this.value);

  @override
  int toJson() => value;

  factory DamageType.fromJson(int value) =>
      values.firstWhere((e) => e.value == value);
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

  /// 强制暴击
  bool? forceCrit;

  bool crit = false;

  /// 韧性伤害
  double toughness;

  /// 等级
  int level;

  /// 伤害锁定
  bool locked = false;

  double? _damage;

  /// 未锁定时返回实时计算的伤害（暴击情况重新计算）
  /// 锁定后返回锁定时的伤害
  double get damage {
    if (locked) {
      return _damage!;
    }
    if (forceCrit != null) {
      crit = forceCrit!;
    } else {
      crit = Random().nextDouble() < critRate;
    }
    _damage = base * // 基础区
        (1 + critRate * critDamage * (crit ? 1 : 0)) * // 暴击区
        (1 + combatTypeBuff) * // 增伤区
        (1 - weaken); // 造成伤害减少
    return _damage!;
  }

  /// 伤害（锁定暴击）
  double get lockDamage {
    try {
      return damage;
    } finally {
      locked = true;
    }
  }

  AttackerDamageDetail({
    required this.level,
    required this.base,
    required this.critRate,
    required this.critDamage,
    this.weaken = 0,
    required this.combatType,
    required this.damageTypes,
    required this.combatTypeBuff,
    this.toughness = 0,
    this.forceCrit,
  });

  @override
  toJson() {
    return JsonSerializable.auto({
      'base': base,
      'critRate': critRate,
      'critDamage': critDamage,
      'type': combatType,
      'damageTypes': damageTypes,
      'combatTypeBuff': combatTypeBuff,
      'weaken': weaken,
      if (locked) 'crit': crit,
      if (locked) 'damage': _damage,
    });
  }
}

class DefenderDamageDetail implements JsonSerializable {
  /// 输出端伤害
  AttackerDamageDetail base;

  /// 防御力
  double def;

  /// 抗性（加算）
  double resist;

  /// 易伤（加算）
  double vulnerability;

  /// 伤害减免（乘算）
  double mitigation;

  /// 韧性已击破
  bool broken;

  DefenderDamageDetail({
    required this.base,
    required this.def,
    this.resist = 0,
    this.vulnerability = 0,
    this.mitigation = 1,
    this.broken = true,
  });

  /// 最终伤害
  double get damage =>
      base.lockDamage * // 基础区
      (1 - (def / (def + 200 + 10 * base.level))) * // 防御区
      (1 - min(max(-1, resist), 0.9)) * // 抗性区
      (1 + vulnerability) * // 易伤区
      mitigation * // 减免区
      (broken ? 1 : 0.9); // 韧性区

  @override
  toJson() {
    return JsonSerializable.auto({
      'base': base,
      'def': def,
      'resist': resist,
      'vulnerability': vulnerability,
      'mitigation': mitigation,
      'broken': broken,
      'damage': damage,
    });
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
