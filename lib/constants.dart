import 'package:briscola/components/card.dart';

final List<Card> cardSet =
    List.generate(40, (index) => Card(index % 10, index ~/ 10));
