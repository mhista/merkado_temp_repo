class ValidationUtils {
  static String? validateNin(String? value) {
    if (value == null || value.isEmpty) return 'NIN is required';
    if (value.length != 11) return 'NIN must be 11 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'NIN must contain only numbers';
    return null;
  }

  static String? validateBvn(String? value) {
    if (value == null || value.isEmpty) return 'BVN is required';
    if (value.length != 11) return 'BVN must be 11 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'BVN must contain only numbers';
    return null;
  }

  static String? validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Invalid phone number';
    return null;
  }
}
