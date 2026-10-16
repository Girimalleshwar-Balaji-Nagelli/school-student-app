String createVirtualClassRoom({
  required String className,
  required String section,
  required String subject,
}) {
  String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  return 'school_virtual_${normalize(className)}_'
      '${normalize(section)}_${normalize(subject)}';
}