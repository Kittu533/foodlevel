import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final DateFormat _historyDateFormat = DateFormat('dd MMM yyyy, HH:mm');

  static String percent(double value) => '${(value * 100).round()}%';

  static String historyDate(DateTime value) => _historyDateFormat.format(value);
}
