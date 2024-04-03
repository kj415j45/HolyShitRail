import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

abstract base class Character<State extends CharacterCurrentState>
    implements Unit, JsonSerializable {
  final CharacterPath path;
  final CombatType combatType;

  @override
  final String id;
  @override
  final String name;
  @override
  final CharacterStaticStats staticStats;
  @override
  late final State currentState;
  @override
  final List<Ability> abilities = [];

  Character({
    required this.path,
    required this.combatType,
    required this.id,
    required this.name,
    required this.staticStats,
  });

  @override
  toJson() {
    return {
      'path': path.toJson(),
      'id': id,
      'name': name,
      'staticStats': staticStats.toJson(),
      'currentState': currentState.toJson(),
    };
  }

  AttackerDamageDetail calculateDamage({
    required double baseDamage,
    required List<DamageType> damageTypes,
    CombatType? combatType,
    bool? forceCrit,
  }) {
    combatType = combatType ?? this.combatType;
    return AttackerDamageDetail(
      base: baseDamage,
      critRate: currentState.crt.modifiedValue,
      critDamage: currentState.crtDmg.modifiedValue,
      damageTypes: damageTypes,
      combatType: combatType,
      combatTypeBuff: currentState.combatTypeBuff.getBuff(combatType),
      forceCrit: forceCrit,
    );
  }
}

abstract base class BattleCharacter<C extends Character> extends BattleUnit<C>
    implements Unit {
  final C character;
  int energy;

  @override
  get currentState => character.currentState;

  BattleCharacter(
    this.character, {
    int? hp,
    int? energy,
  })  : energy = energy ?? (character.staticStats.maxEnergy * 0.5).toInt(),
        super(character) {
    hp = hp ?? character.currentState.maxHp.modifiedValue;
  }

  void gainEnergy(int eg) {
    energy +=
        (eg * (1 + character.currentState.energyEffect.modifiedValue)).toInt();
    if (energy > character.staticStats.maxEnergy) {
      energy = character.staticStats.maxEnergy;
    }
  }

  void loseEnergy(int eg) {
    energy -= eg;
    if (energy < 0) {
      energy = 0;
    }
  }

  Ability getAbility(String id) {
    return character.abilities.firstWhere((a) => a.id == id);
  }

  @override
  toJson() {
    return {
      'character': character.toJson(),
      'hp': hp,
      'energy': energy,
    };
  }
}

enum CharacterPath implements EnumValue<int> {
  /// 毁灭
  destruction(0),

  /// 巡猎
  theHunt(1),

  /// 智识
  erudition(2),

  /// 同谐
  harmony(3),

  /// 虚无
  nihility(4),

  /// 存护
  preservation(5),

  /// 丰饶
  abundance(6),

  // general(7),
  ;

  @override
  final int value;
  const CharacterPath(this.value);

  @override
  toJson() => value;
}

abstract base class CharacterStaticStats extends UnitStaticStats
    implements JsonSerializable {
  /// 等级
  final int level;

  /// 生命值
  final int maxHp;

  /// 攻击力
  final double atk;

  /// 防御力
  final double def;

  /// 速度
  final double spd;

  /// 暴击率
  final double crt;

  /// 暴击伤害
  final double crtDmg;

  /// 嘲讽值
  final int taunt;

  /// 能量
  final int maxEnergy;

  const CharacterStaticStats({
    required this.level,
    required this.maxHp,
    required this.atk,
    required this.def,
    required this.spd,
    required this.crt,
    required this.crtDmg,
    required this.taunt,
    required this.maxEnergy,
  }) : super();

  @override
  toJson() {
    return {
      'level': level,
      'maxHp': maxHp,
      'atk': atk,
      'def': def,
      'spd': spd,
      'crt': crt,
      'crtDmg': crtDmg,
      'taunt': taunt,
      'maxEnergy': maxEnergy,
    };
  }
}

class CharacterCurrentState<S extends CharacterStaticStats>
    extends UnitCurrentState implements JsonSerializable {
  // 基础属性
  final LinearModifiableValue<double> atk;
  final LinearModifiableValue<double> def;
  final LinearModifiableValue<double> spd;

  // 进阶属性
  final LinearModifiableValue<double> crt;
  final LinearModifiableValue<double> crtDmg;

  /// 击破特攻
  final LinearModifiableValue<double> breakEffect;

  /// 治疗量加成
  final LinearModifiableValue<double> healEffect;

  /// 能量恢复效率
  final LinearModifiableValue<double> energyEffect;

  /// 效果命中
  final LinearModifiableValue<double> effectHitRate;

  /// 效果抵抗
  final LinearModifiableValue<double> effectResistance;

  // 伤害属性
  final combatTypeBuff = CombatTypeBuff();
  final combatTypeResistance = CombatTypeResistance();

  // 隐藏属性
  final LinearModifiableValue<int> taunt;

  CharacterCurrentState(S staticStat)
      : atk = LinearModifiableValue(staticStat.atk),
        def = LinearModifiableValue(staticStat.def),
        spd = LinearModifiableValue(staticStat.spd),
        crt = LinearModifiableValue(0),
        crtDmg = LinearModifiableValue(0),
        breakEffect = LinearModifiableValue(0),
        healEffect = LinearModifiableValue(0),
        energyEffect = LinearModifiableValue(0),
        effectHitRate = LinearModifiableValue(0),
        effectResistance = LinearModifiableValue(0),
        taunt = LinearModifiableValue(staticStat.taunt),
        super(maxHp: LinearModifiableValue(staticStat.maxHp));

  @override
  toJson() {
    return {
      'maxHp': [maxHp.originalValue, maxHp.modifiedValue],
      'atk': [atk.originalValue, atk.modifiedValue],
      'def': [def.originalValue, def.modifiedValue],
      'spd': [spd.originalValue, spd.modifiedValue],
      'crt': [crt.originalValue, crt.modifiedValue],
      'crtDmg': [crtDmg.originalValue, crtDmg.modifiedValue],
      'breakEffect': [breakEffect.originalValue, breakEffect.modifiedValue],
      'healEffect': [healEffect.originalValue, healEffect.modifiedValue],
      'energyEffect': [energyEffect.originalValue, energyEffect.modifiedValue],
      'effectHitRate': [
        effectHitRate.originalValue,
        effectHitRate.modifiedValue
      ],
      'effectResistance': [
        effectResistance.originalValue,
        effectResistance.modifiedValue
      ],
      'combatTypeBuff': combatTypeBuff.toJson(),
      'combatTypeResistance': combatTypeResistance.toJson(),
      'taunt': [taunt.originalValue, taunt.modifiedValue],
    };
  }
}
