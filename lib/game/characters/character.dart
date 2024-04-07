import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/character.dart';
import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/global_configs.dart';
import 'package:holyshitrail/utils/enum_value.dart';

abstract base class Avatar<State extends CharacterCurrentState>
    implements Unit, JsonSerializable {
  final CharacterPath path;
  final CombatType combatType;

  @override
  final CharacterId id;
  @override
  final String name;
  @override
  final CharacterStaticStats staticStats;
  @override
  late final State currentState;
  @override
  final List<Ability> abilities = [];

  Avatar({
    required this.path,
    required this.combatType,
    required this.id,
    required this.name,
    required this.staticStats,
  });

  static fromJson(
    Map<String, dynamic> json, {
    int level = 80,
  }) {
    final id = CharacterId.fromJson(json['id']);
    final name = currentLocale.getCharacterName(id);
    final path = CharacterPath.fromJson(json['path']);
    final combatType = CombatType.fromJson(json['combatType']);

    final stats =
        CharacterStaticStats.fromJson((json['stats'] as List).firstWhere(
      (e) => e['level'] == level,
    ));

    switch (id) {
      case CharacterId.trailblazerDestruction:
        return TrailblazerDCharacter(
          id: id,
          name: name,
          path: path,
          combatType: combatType,
          staticStats: stats,
        );
      default:
    }
  }

  @override
  toJson() {
    return JsonSerializable.auto({
      'id': id,
      'name': name,
      'path': path,
      'stats': staticStats,
      'state': currentState,
    });
  }

  AttackerDamageDetail calculateDamage({
    required double baseDamage,
    required List<DamageType> damageTypes,
    CombatType? combatType,
    bool? forceCrit,
  }) {
    combatType = combatType ?? this.combatType;
    return AttackerDamageDetail(
      level: staticStats.level,
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

abstract base class BattleCharacter<C extends Avatar> extends BattleUnit<C>
    implements Unit {
  final C character;
  double energy;

  @override
  get currentState => character.currentState;

  BattleCharacter(
    this.character, {
    double? hp,
    double? energy,
  })  : energy = energy ?? (character.staticStats.maxEnergy * 0.5),
        super(character) {
    hp = hp ?? character.currentState.maxHp.modifiedValue;
  }

  void onJoinBattle(BattleContext ctx);

  void gainEnergy(double eg) {
    energy += eg * character.currentState.energyEffect.modifiedValue;
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
  DefenderDamageDetail takeDamage(AttackerDamageDetail damage) {
    // TODO: implement takeDamage
    throw UnimplementedError();
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

  factory CharacterPath.fromJson(int value) =>
      values.firstWhere((e) => e.value == value);
}

class CharacterStaticStats extends UnitStaticStats implements JsonSerializable {
  /// 等级
  final int level;

  /// 生命值
  final double maxHp;

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
  final double taunt;

  /// 能量
  final double maxEnergy;

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

  factory CharacterStaticStats.fromJson(Map<String, dynamic> json) {
    return CharacterStaticStats(
      level: json['level'],
      maxHp: json['maxHp'],
      atk: json['atk'],
      def: json['def'],
      spd: (json['spd'] as num).toDouble(),
      crt: json['crt'],
      crtDmg: json['crtDmg'],
      taunt: json['taunt'],
      maxEnergy: json['maxEnergy'],
    );
  }

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
  final LinearModifiableValue<double> healBuff;

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
  final LinearModifiableValue<double> taunt;

  int eidolonLevel = 0;

  CharacterCurrentState(S staticStat)
      : atk = LinearModifiableValue(staticStat.atk),
        def = LinearModifiableValue(staticStat.def),
        spd = LinearModifiableValue(staticStat.spd),
        crt = LinearModifiableValue(
          staticStat.crt,
          minValue: 0.0,
          maxValue: 1.0,
        ),
        crtDmg = LinearModifiableValue(staticStat.crtDmg, minValue: 0.0),
        breakEffect = LinearModifiableValue(0),
        healBuff = LinearModifiableValue(0),
        energyEffect = LinearModifiableValue(1.0),
        effectHitRate = LinearModifiableValue(0),
        effectResistance = LinearModifiableValue(0),
        taunt = LinearModifiableValue(staticStat.taunt),
        super(maxHp: LinearModifiableValue(staticStat.maxHp));

  @override
  toJson() {
    return JsonSerializable.auto({
      'maxHp': maxHp,
      'atk': atk,
      'def': def,
      'spd': spd,
      'crt': crt,
      'crtDmg': crtDmg,
      'breakEffect': breakEffect,
      'healEffect': healBuff,
      'energyEffect': energyEffect,
      'effectHitRate': effectHitRate,
      'effectResistance': effectResistance,
      'combatTypeBuff': combatTypeBuff,
      'combatTypeResistance': combatTypeResistance,
      'taunt': taunt,
    });
  }
}

enum CharacterId implements EnumValue<String> {
  unknown("C00000"),
  trailblazerDestruction("C10001"),

  acheron("C21001"),
  ;

  @override
  final String value;
  const CharacterId(this.value);

  @override
  String toJson() => value;

  factory CharacterId.fromJson(String value) =>
      values.firstWhere((e) => e.value == value);
}
