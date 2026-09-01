import 'package:flutter/foundation.dart';

class IncomingText {
  final String text;
  final int id;
  const IncomingText(this.text, this.id);
}

final incomingText = ValueNotifier<IncomingText?>(null);
final openScreen = ValueNotifier<int?>(null);
