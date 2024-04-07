import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/utils/enum_value.dart';
import 'package:holyshitrail/utils/functions.dart';

abstract class Unit implements JsonSerializable {
  final dynamic id;
  final String name;
  final UnitStaticStats staticStats;
  final UnitCurrentState currentState;
  final List<Ability> abilities;

  const Unit({
    required this.id,
    required this.name,
    required this.staticStats,
    required this.currentState,
    this.abilities = const [],
  });
}

abstract class BattleUnit<U extends Unit> extends Unit
    implements JsonSerializable {
  final U prototype;
  late double hp;
  bool selectable;

  BattleUnit(
    this.prototype, {
    this.selectable = true,
  }) : super(
          id: newInstanceId(),
          name: prototype.name,
          staticStats: prototype.staticStats,
          currentState: prototype.currentState,
          abilities: prototype.abilities,
        ) {
    hp = prototype.currentState.maxHp.modifiedValue;
  }

  DefenderDamageDetail takeDamage(AttackerDamageDetail damage);
}

abstract class UnitStaticStats implements JsonSerializable {
  const UnitStaticStats();
}

abstract class UnitCurrentState implements JsonSerializable {
  LinearModifiableValue<double> maxHp;
  UnitCurrentState({
    required this.maxHp,
  });
}
