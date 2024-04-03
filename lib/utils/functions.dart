import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newInstanceId() {
  return _uuid.v1();
}
