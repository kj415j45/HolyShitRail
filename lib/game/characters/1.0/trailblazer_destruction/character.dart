import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/ability.dart';
import 'package:holyshitrail/game/characters/character.dart';

final class TrailblazerDCharacter
    extends Avatar<TrailblazerDCharacterCurrentState> {
  TrailblazerDCharacter({
    super.path = CharacterPath.destruction,
    super.combatType = CombatType.physical,
    super.id = CharacterId.trailblazerDestruction,
    super.name = 'Trailblazer',
    required super.staticStats,
  }) {
    currentState = TrailblazerDCharacterCurrentState(staticStats);
  }
}

final class TrailblazerDBattleCharacter
    extends BattleCharacter<TrailblazerDCharacter> {
  TrailblazerDBattleCharacter(super.character) {
    abilities.addAll([
      TrailblazerDNormalAttack(1.0, owner: this),
      TrailblazerDSkill(1.2, 1.2, owner: this)
    ]);
  }

  @override
  void onJoinBattle(BattleContext ctx) {}
}

class TrailblazerDCharacterCurrentState extends CharacterCurrentState {
  bool activeUltimate = false;
  Ability? ultimateToCast;
  TrailblazerDCharacterCurrentState(
    super.stat,
  );
}
