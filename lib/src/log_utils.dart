import 'dart:math' as math;

class LogUtils {
  static double logBase(num x, num base) => math.log(x) / math.log(base);
  static double log10(num x) => math.log(x) / math.ln10;
}
