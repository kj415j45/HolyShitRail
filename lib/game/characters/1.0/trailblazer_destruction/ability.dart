import 'package:holyshitrail/game/ability.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/battle_events.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/character.dart';
import 'package:holyshitrail/game/enemies/enemy.dart';
import 'package:holyshitrail/game/unit.dart';

final class TrailblazerDNormalAttack<U extends TrailblazerDBattleCharacter>
    extends Ability<U> {
  final double damageRate;
  TrailblazerDNormalAttack(
    this.damageRate, {
    super.id = '8002_skill_1',
    super.name = 'Normal Attack',
    required super.owner,
    super.type = AbilityType.normalAttack,
    super.targetType = const [
      AbilityTargetType.enemy,
      AbilityTargetType.single,
    ],
  });

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }

  @override
  void cast(BattleContext context, Unit target) {
    final enemy = target as BattleEnemy;
    final damage = owner.character.currentState.atk.modifiedValue * damageRate;
    final damageDetail = AttackerDamageDetail(
      base: damage,
      critRate: owner.character.currentState.crt.modifiedValue,
      critDamage: owner.character.currentState.crtDmg.modifiedValue,
      damageTypes: [DamageType.normalAttack],
      combatType: CombatType.physical,
      combatTypeBuff: owner.character.currentState.combatTypeBuff.getBuff(
        CombatType.physical,
      ),
    );
    context.dispatch(
      DamageEvent(
        owner,
        [enemy],
        DamageTable.single(
          enemy,
          damageDetail,
        ),
      ),
    );
  }
}

final class TrailblazerDSkill<U extends TrailblazerDBattleCharacter>
    extends Ability<U> {
  final double mainRate;
  final double adjacentRate;
  TrailblazerDSkill(
    this.mainRate,
    this.adjacentRate, {
    super.id = '8002_skill_2',
    super.name = 'Skill',
    required super.owner,
    super.type = AbilityType.skill,
    super.targetType = const [
      AbilityTargetType.enemy,
      AbilityTargetType.blast,
    ],
  });

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }

  @override
  void cast(BattleContext context, Unit target) {
    final mainTarget = target as BattleEnemy;
    final adjacentTargets = context.getBlastTargets(mainTarget);
    final mainTargetDamage =
        owner.character.currentState.atk.modifiedValue * mainRate;
    final adjacentDamage =
        owner.character.currentState.atk.modifiedValue * adjacentRate;
    final damageTable = DamageTable({
      mainTarget: owner.character.calculateDamage(
        baseDamage: mainTargetDamage,
        damageTypes: [DamageType.skill],
      ),
      for (final target in adjacentTargets)
        target: owner.character.calculateDamage(
          baseDamage: adjacentDamage,
          damageTypes: [DamageType.skill],
        ),
    });
    context.dispatch(HitEvent(owner, [mainTarget, ...adjacentTargets]));
    context.dispatch(
      DamageEvent(
        owner,
        [mainTarget, ...adjacentTargets],
        damageTable,
      ),
    );
  }
}

enum TrailblazerDUlitimateType {
  none,
  skill,
  normalAttack,
}

final class TrailblazerDUltimate<U extends TrailblazerDBattleCharacter>
    extends Ability<U> {
  final double damageRate;
  TrailblazerDUltimate(
    this.damageRate, {
    super.id = '8002_ultimate',
    super.name = 'Ultimate',
    required super.owner,
    super.type = AbilityType.ultimate,
    super.targetType = const [
      AbilityTargetType.enemy,
    ],
  });

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }

  @override
  void cast(BattleContext context, Unit target) {
    owner.character.currentState.ultimateToCast!.cast(context, target);
    owner.character.currentState.ultimateToCast = null;
  }
}

final class TrailblazerDUltimateSingle<U extends TrailblazerDBattleCharacter>
    extends Ability<U> {
  TrailblazerDUltimateSingle({
    super.id = '8002_ultimate_single',
    super.name = 'Ultimate Single',
    required super.owner,
    super.type = AbilityType.normalAttack,
    super.targetType = const [
      AbilityTargetType.enemy,
      AbilityTargetType.single,
    ],
  });

  @override
  bool canActive(BattleContext context) {
    if (owner.character.currentState.activeUltimate) {
      return super.canActive(context);
    } else {
      return false;
    }
  }

  @override
  List<Unit> getPossibleTargets(BattleContext context) {
    return context.enemies;
  }

  @override
  void cast(BattleContext context, Unit target) {
    //TODO
  }
}
