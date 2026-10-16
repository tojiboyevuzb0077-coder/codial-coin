class Validators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu maydon'} kiritilishi shart';
    }
    return null;
  }

  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu maydon'} kiritilishi shart';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Bu maydon'} yaroqli raqam bo‘lishi kerak';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    String? numErr = number(value, fieldName);
    if (numErr != null) return numErr;
    if (double.parse(value!) < 0) {
      return '${fieldName ?? 'Bu maydon'} musbat bo‘lishi kerak';
    }
    return null;
  }
}
