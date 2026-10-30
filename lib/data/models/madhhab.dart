enum Madhhab { general, hanafi, maliki, shafii, hanbali }

extension MadhhabLabel on Madhhab {
  String get key => 'madhhab_${name}';
}