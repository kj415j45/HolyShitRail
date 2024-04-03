import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/utils/enum_value.dart';
import 'package:holyshitrail/utils/functions.dart';

abstract class Unit implements JsonSerializable {
  final String id;
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
  late int hp;
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
}

abstract class UnitStaticStats implements JsonSerializable {
  const UnitStaticStats();
}

abstract class UnitCurrentState implements JsonSerializable {
  LinearModifiableValue<int> maxHp;
  UnitCurrentState({
    required this.maxHp,
  });
}
