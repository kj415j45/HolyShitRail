import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/enemies/enemy.dart';

final class DummyEnemy extends Enemy {
  DummyEnemy({
    super.id = 'dummy',
    super.name = 'Dummy',
    super.staticStats = const DummyEnemyStaticStats(
      level: 80,
      maxHp: 1000000000,
      atk: 0,
      spd: 100,
      effectHitRate: 0,
      effectResistance: 0,
      weakness: [
        CombatType.physical,
        CombatType.fire,
        CombatType.ice,
        CombatType.lightning,
        CombatType.wind,
        CombatType.quantum,
        CombatType.imaginary,
      ],
      maxToughness: 60,
    ),
  });
}

final class DummyBattleEnemy extends BattleEnemy<DummyEnemy> {
  DummyBattleEnemy({DummyEnemy? enemy}) : super(enemy ?? DummyEnemy());
}

class DummyEnemyStaticStats extends EnemyStaticStats {
  const DummyEnemyStaticStats({
    required super.level,
    required super.maxHp,
    required super.atk,
    required super.spd,
    required super.effectHitRate,
    required super.effectResistance,
    required super.weakness,
    required super.maxToughness,
  });
}
