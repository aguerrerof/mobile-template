import 'package:intl/intl.dart';

String formatearFecha(String dateStr) {
  DateTime date = DateTime.parse(dateStr);
  return DateFormat('EEEE, d MMM', 'es_ES').format(date);
}

String formatDateOrder(String dateStr, int? days) {
  DateTime date = DateTime.parse(dateStr);
  if (days != null) {
    DateTime newDate = date.add(Duration(days: days));
    return DateFormat('d MMMM, yyyy', 'es_ES').format(newDate);
  }
  return DateFormat('d MMMM, yyyy', 'es_ES').format(date);
}

bool isExpiryDateValid(String input) {
  final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
  if (!regex.hasMatch(input)) return false;

  final match = regex.firstMatch(input)!;
  final month = int.parse(match.group(1)!);
  final year = int.parse('20${match.group(2)!}');

  final now = DateTime.now();
  final expiryDate = DateTime(year, month + 1, 0);
  return expiryDate.isAfter(now);
}

bool isValidCreditCard(String number) {
  number = number.replaceAll(' ', '');
  number = number.replaceAll(RegExp(r'\s+|-'), '');
  if (!RegExp(r'^\d{13,19}$').hasMatch(number)) return false;

  int sum = 0;
  bool alternate = false;

  for (int i = number.length - 1; i >= 0; i--) {
    int n = int.parse(number[i]);

    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }

    sum += n;
    alternate = !alternate;
  }

  return sum % 10 == 0;
}

String getCardImage(String issuer) {
  switch (issuer) {
    case 'VISA':
      return 'assets/images/visa.png';
    case 'DINERS':
      return 'assets/images/diners.png';
    case 'DISCOVER':
      return 'assets/images/discover.png';
    case 'MASTERCARD':
      return 'assets/images/mastercard.png';
    case 'AMEX':
      return 'assets/images/amex.png';
    default:
      return 'assets/images/credit.png';
  }
}

enum CardType { visa, mastercard, amex, diners, discover, jcb, other }

CardType getCardType(String input) {
  if (input.startsWith(RegExp(r'^4'))) {
    return CardType.visa;
  } else if (input.startsWith(
    RegExp(r'^(5[1-5]|222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)'),
  )) {
    return CardType.mastercard;
  } else if (input.startsWith(RegExp(r'^(34|37)'))) {
    return CardType.amex;
  } else if (input.startsWith(RegExp(r'^(30[0-5]|36|38)'))) {
    return CardType.diners;
  } else if (input.startsWith(
    RegExp(
      r'^(6011|65|64[4-9]|622(12[6-9]|1[3-9]\d|[2-8]\d\d|9[0-1]\d|92[0-5]))',
    ),
  )) {
    return CardType.discover;
  } else if (input.startsWith(RegExp(r'^(35[2-8][0-9])'))) {
    return CardType.jcb;
  } else {
    return CardType.other;
  }
}

String formatCardNumberText(String newText) {
  final buffer = StringBuffer();
  for (int i = 0; i < newText.length; i++) {
    if (i != 0 && i % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(newText[i]);
  }
  return buffer.toString();
}
