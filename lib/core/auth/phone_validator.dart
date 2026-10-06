class SudanPhoneValidator {
  SudanPhoneValidator._();

  static String? validate(String value) {
    final phone = value.trim().replaceAll(RegExp(r'[\\s-]'), '');

    final local = RegExp(r'^09[0-9]{8}$');
    final international = RegExp(r'^\\+2499[0-9]{8}$');

    if (!local.hasMatch(phone) && !international.hasMatch(phone)) {
      return 'يرجى إدخال رقم هاتف سوداني صحيح';
    }

    return null;
  }

  static String normalize(String value) {
    final phone = value.trim().replaceAll(RegExp(r'[\\s-]'), '');

    if (phone.startsWith('+249')) {
      return phone;
    }

    return '+249${phone.substring(1)}';
  }
}
