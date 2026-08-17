import 'package:intl/intl.dart';

/// Formats an amount in paise as a plain number string, e.g. 950 -> "9.50".
String formatRupees(int paise, {int decimals = 2}) =>
    (paise / 100).toStringAsFixed(decimals);

/// Formats an amount in paise as a localized INR currency string, e.g. 950 -> "₹9.50".
String formatMoney(int paise, {int decimals = 2}) {
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: decimals,
  ).format(paise / 100);
}
