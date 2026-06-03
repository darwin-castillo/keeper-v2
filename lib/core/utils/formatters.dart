import 'package:intl/intl.dart';

/// Shared formatting helpers for the Keeper UI.
abstract final class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('EEE d MMM, yyyy', 'es');
  static final DateFormat _time = DateFormat('h:mm a', 'es');

  static String currency(double value) => _currency.format(value);

  static String date(DateTime value) => _date.format(value);

  static String time(DateTime value) => _time.format(value).toUpperCase();
}
