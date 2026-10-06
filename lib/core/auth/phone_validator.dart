class SudanPhoneValidator {
  SudanPhoneValidator._();

  static String _clean(String value) {
    return value.trim().replaceAll(RegExp(r'[\\s-]'), '');
  }

  static String? validate(String value) {
    final phone = _clean(value);

    // WASEL accepts Sudanese numbers in local form or with 00249/+249.
    // Local: 01XXXXXXXX or 09XXXXXXXX (10 digits).
    final local = RegExp(r'^0[19][0-9]{8}$');

    // Full prefix with the local leading zero retained: 00249 + 10 digits.
    final internationalWithPrefix = RegExp(r'^002490[19][0-9]{8}$');

    // Full prefix with the local zero already removed: 00249 + 9 digits.
    final internationalNational = RegExp(r'^00249[19][0-9]{8}$');

    // Equivalent +249 form.
    final plusWithNational = RegExp(r'^\\+249[19][0-9]{8}$');

    if (!local.hasMatch(phone) &&
        !internationalWithPrefix.hasMatch(phone) &&
        !internationalNational.hasMatch(phone) &&
        !plusWithNational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249110033224';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249')) {
      final national = phone.substring(5);

      if (national.length == 10 && national.startsWith('0')) {
        return '+249' + national.substring(1);
      }

      return '+249' + national;
    }

    if (phone.startsWith('+249')) {
      final national = phone.substring(4);

      if (national.length == 10 && national.startsWith('0')) {
        return '+249' + national.substring(1);
      }

      return '+249' + national;
    }

    if (phone.startsWith('0')) {
      return '+249' + phone.substring(1);
    }

    return phone;
  }
}