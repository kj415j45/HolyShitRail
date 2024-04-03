import 'package:holyshitrail/game/unit.dart';

final class BattleBuff {
  final BuffStatus buff;
  final Unit owner;

  BattleBuff(this.buff, this.owner);
}

base class BuffStatus {
  final String id;
  final String name;

  bool display;

  /// 计时器
  int timer;

  /// 计时器最大值
  final int maxTimer;

  BuffStatus({
    required this.id,
    required this.name,
    this.maxTimer = 1,
    this.display = true,
  }) : timer = maxTimer;

  bool isExpired() {
    return timer <= 0;
  }
}

base class Buff extends BuffStatus {
  Buff({required super.id, required super.name});
}

base class Debuff extends BuffStatus {
  Debuff({required super.id, required super.name});
}

base class OtherBuff extends BuffStatus {
  OtherBuff({required super.id, required super.name});
}
