import 'package:intl/intl.dart';

int? toInt(dynamic value) {
  var val = value
      .toString()
      .replaceAll(new RegExp(r'[^\w\s]+'), '')
      .toString()
      .replaceAll(RegExp("[a-zA-Z:\s]"), "");

  if (val == "") {
    return 0;
  }
  if (val == null) {
    return 0;
  }

  return int.parse(val);
}

String toCurrency(dynamic value) {
  var noSimbolInUSFormat =
      NumberFormat.currency(locale: "ID", symbol: "Rp", decimalDigits: 0);

  return noSimbolInUSFormat.format(toInt(value));
}
