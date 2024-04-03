import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

abstract base class Enemy<State extends EnemyCurrentState>
    implements Unit, JsonSerializable {
  @override
  final String id;
  @override
  final String name;
  @override
  final EnemyStaticStats staticStats;
  @override
  final State currentState;
  @override
  final List<Ability> abilities = [];

  Enemy({
    required this.id,
    required this.name,
    required this.staticStats,
    State? currentState,
  }) : currentState = currentState ?? EnemyCurrentState(staticStats) as State;

  @override
  Map toJson() {
    return {
      'id': id,
      'name': name,
      'staticStats': staticStats.toJson(),
      'currentState': currentState.toJson(),
    };
  }
}

abstract base class BattleEnemy<E extends Enemy> extends BattleUnit<E>
    implements JsonSerializable {
  final E enemy;
  double toughness;

  bool broke = false;

  BattleEnemy(this.enemy)
      : toughness = enemy.staticStats.maxToughness,
        super(enemy) {
    hp = enemy.currentState.maxHp.modifiedValue;
  }

  void takeToughnessDamage(double damageToToughness) {
    toughness -= damageToToughness;
    if (toughness <= 0) {
      toughness = 0;
      broke = true;
    }
  }

  void recoverFromBreak() {
    broke = false;
    toughness = enemy.staticStats.maxToughness;
  }

  @override
  toJson() {
    return {
      'id': id,
      'enemy': enemy.toJson(),
      'hp': hp,
      'toughness': toughness,
      'broke': broke,
    };
  }
}

class EnemyStaticStats extends UnitStaticStats implements JsonSerializable {
  final int level;
  final int maxHp;
  final double atk;
  final double def;
  final double spd;
  final double effectHitRate;
  final double effectResistance;

  /// 弱点
  final List<CombatType> weakness;

  /// 韧性
  final double maxToughness;

  const EnemyStaticStats({
    required this.level,
    required this.maxHp,
    required this.atk,
    double? def,
    required this.spd,
    required this.effectHitRate,
    required this.effectResistance,
    required this.weakness,
    required this.maxToughness,
  }) : def = def ?? (level * 10 + 200);

  @override
  Map toJson() {
    return {
      'level': level,
      'maxHp': maxHp,
      'atk': atk,
      'def': def,
      'spd': spd,
      'effectHitRate': effectHitRate,
      'effectResistance': effectResistance,
      'weakness': weakness.map((e) => e.toJson()).toList(),
      'maxToughness': maxToughness,
    };
  }
}

class EnemyCurrentState<S extends EnemyStaticStats> extends UnitCurrentState
    implements JsonSerializable {
  final LinearModifiableValue<double> atk;
  final LinearModifiableValue<double> def;
  final LinearModifiableValue<double> spd;
  final LinearModifiableValue<double> effectHitRate;
  final LinearModifiableValue<double> effectResistance;

  final combatTypeResistance = CombatTypeResistance();

  EnemyCurrentState(EnemyStaticStats staticStat)
      : atk = LinearModifiableValue(staticStat.atk),
        def = LinearModifiableValue(staticStat.def, minValue: 0),
        spd = LinearModifiableValue(staticStat.spd),
        effectHitRate = LinearModifiableValue(staticStat.effectHitRate),
        effectResistance = LinearModifiableValue(staticStat.effectResistance),
        super(maxHp: LinearModifiableValue(staticStat.maxHp));

  @override
  Map toJson() {
    return {
      'maxHp': [maxHp.originalValue, maxHp.modifiedValue],
      'atk': [atk.originalValue, atk.modifiedValue],
      'def': [def.originalValue, def.modifiedValue],
      'spd': [spd.originalValue, spd.modifiedValue],
      'effectHitRate': [
        effectHitRate.originalValue,
        effectHitRate.modifiedValue
      ],
      'effectResistance': [
        effectResistance.originalValue,
        effectResistance.modifiedValue
      ],
    };
  }
}
