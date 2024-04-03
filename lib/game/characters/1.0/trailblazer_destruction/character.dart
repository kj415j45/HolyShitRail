import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/ability.dart';
import 'package:holyshitrail/game/characters/character.dart';

final class TrailblazerDCharacter
    extends Character<TrailblazerDCharacterCurrentState> {
  TrailblazerDCharacter()
      : super(
          path: CharacterPath.destruction,
          combatType: CombatType.physical,
          id: '8002',
          name: 'Trailblazer',
          staticStats: const TrailblazerDCharacterStaticStats(),
        ) {
    currentState = TrailblazerDCharacterCurrentState(
        staticStats as TrailblazerDCharacterStaticStats);
  }
}

final class TrailblazerDBattleCharacter
    extends BattleCharacter<TrailblazerDCharacter> {
  TrailblazerDBattleCharacter({TrailblazerDCharacter? character})
      : super(
          character ?? TrailblazerDCharacter(),
        ) {
    abilities.addAll([
      TrailblazerDNormalAttack(1.0, owner: this),
      TrailblazerDSkill(1.2, 1.2, owner: this)
    ]);
  }
}

final class TrailblazerDCharacterStaticStats extends CharacterStaticStats {
  const TrailblazerDCharacterStaticStats()
      : super(
          level: 80,
          maxHp: 1203,
          atk: 620.93,
          def: 460.85,
          spd: 100,
          maxEnergy: 120,
          crt: 0.05,
          crtDmg: 0.5,
          taunt: 125,
        );
}

class TrailblazerDCharacterCurrentState extends CharacterCurrentState {
  bool activeUltimate = false;
  Ability? ultimateToCast;
  TrailblazerDCharacterCurrentState(
    TrailblazerDCharacterStaticStats super.stat,
  );
}
