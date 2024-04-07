import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/characters/2.1/acheron/character.dart';
import 'package:holyshitrail/game/unit.dart';

final class AcheronSkill<U extends AcheronBattleCharacter> extends Ability<U> {
  AcheronSkill({
    super.id = "C21001_skill",
    super.name = "Octobolt Flash",
    required super.owner,
    super.type = AbilityType.skill,
    super.targetType = const [AbilityTargetType.blast],
  });

  @override
  void cast(BattleContext context, Unit target) {}

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }
}

final class AcheronUltimate<U extends AcheronBattleCharacter>
    extends Ability<U> {
  AcheronUltimate({
    super.id = "C21001_ultimate",
    super.name = "Slashed Dream Cries in Red",
    required super.owner,
    super.type = AbilityType.ultimate,
    super.targetType = const [AbilityTargetType.aoe],
  });

  @override
  void cast(BattleContext context, Unit target) {}

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }
}
