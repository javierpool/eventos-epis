const institutionalDomains = <String>{
  'upt.pe',
  'virtual.upt.pe',
};

bool isInstitutionalEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return false;
  final domain = email.substring(at + 1).toLowerCase();
  return institutionalDomains.contains(domain);
}
