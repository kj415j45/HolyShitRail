import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_event.dart';
import 'package:holyshitrail/game/unit.dart';

final class LogEvent extends BattleEvent<String> {
  LogEvent(Unit source, String message)
      : super(BattleEventType.log, source, [], BattleEventPayload(message));
}

final class ErrorEvent extends BattleEvent<String> {
  ErrorEvent(Unit source, String message)
      : super(BattleEventType.error, source, [], BattleEventPayload(message));
}

final class WaitUserInteractionEvent extends BattleEvent {
  WaitUserInteractionEvent(Unit source)
      : super(BattleEventType.serverWait, source, []);
}

final class HitEvent extends BattleEvent {
  HitEvent(Unit source, List<Unit> target)
      : super(BattleEventType.unitAttackHit, source, target);
}

final class DamageEvent extends BattleEvent<DamageTable> {
  DamageEvent(
    Unit source,
    List<Unit> target,
    DamageTable damage,
  ) : super(
          BattleEventType.unitDamage,
          source,
          target,
          BattleEventPayload(damage),
        );
}

final class TakeDamageEvent extends BattleEvent<DefenderDamageDetail> {
  TakeDamageEvent(
    Unit source,
    Unit target,
    DefenderDamageDetail damage,
  ) : super(
          BattleEventType.unitTakeDamage,
          source,
          [target],
          BattleEventPayload(damage),
        );
}
