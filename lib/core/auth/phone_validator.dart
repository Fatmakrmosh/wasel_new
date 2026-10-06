class SudanPhoneValidator {
  SudanPhoneValidator._();

  static String _clean(String value) {
    return value.trim().replaceAll(RegExp(r'[\s-]'), '');
  }

  static String? validate(String value) {
    final phone = _clean(value);

    // Local Sudanese form: exactly 10 digits, including the leading 0.
    // Examples: 0110033224 and 0964243135.
    final local = RegExp(r'^0[19][0-9]{8}

    // International form: 00249 (5 digits) + 9 national digits.
    // The local leading 0 is removed after the country code.
    // Examples: 00249110033224 and 00249964243135.
    final international = RegExp(r'^00249[19][0-9]{8}

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[19][0-9]{8}

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // International form: 00249 (5 digits) + 9 national digits.
    // The local leading 0 is removed after the country code.
    // Examples: 00249110033224 and 00249964243135.
    final international = RegExp(r'^00249[0-9]{9}$');

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // International form: 00249 (5 digits) + 9 national digits.
    // The local leading 0 is removed after the country code.
    // Examples: 00249110033224 and 00249964243135.
    final international = RegExp(r'^00249[0-9]{9}$');

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // International form: 00249 (5 digits) + 9 national digits.
    // The local leading 0 is removed after the country code.
    // Examples: 00249110033224 and 00249964243135.
    final international = RegExp(r'^00249[0-9]{9}$');

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
});

    // International form: 00249 (5 digits) + 9 national digits.
    // The local leading 0 is removed after the country code.
    // Examples: 00249110033224 and 00249964243135.
    final international = RegExp(r'^00249[0-9]{9}$');

    // Equivalent form using +249.
    final plusInternational = RegExp(r'^\+249[0-9]{9}$');

    if (!local.hasMatch(phone) &&
        !international.hasMatch(phone) &&
        !plusInternational.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح، مثال: 00249964243135';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = _clean(value);

    if (phone.startsWith('00249') && phone.length == 14) {
      return '+249${phone.substring(5)}';
    }

    if (phone.startsWith('+249') && phone.length == 13) {
      return phone;
    }

    if (phone.startsWith('0') && phone.length == 10) {
      return '+249${phone.substring(1)}';
    }

    return phone;
  }
}