import 'dart:math' as math;

class ListWithOffset<T> {
  ListWithOffset({
    required this.original,
    required this.offset,
  }) : assert(offset < original.length);

  final List<T> original;
  final int offset;

  T operator [](int index) => original[offset + index];
  void operator []=(int index, T value) => original[offset + index] = value;

  int get length => original.length;

  ListWithOffset<T> toOffset(int newOffset) {
    return ListWithOffset(original: original, offset: offset + newOffset);
  }
}

extension ListWithOffsetX on List<double> {
  ListWithOffset<double> offset(int offset) {
    return ListWithOffset(original: this, offset: offset);
  }
}

class FFTTable {
  FFTTable({
    required this.n,
  })  : trigcache = List<double>.filled(3 * n, 0.0),
        splitcache = List<int>.filled(32, 0);
  int n;
  List<double> trigcache;
  List<int> splitcache;

  void init() {
    NUMrffti(n, trigcache, splitcache);
  }

  void forward(List<double> data) {
    if (n == 1) {
      return;
    }

    assert(n == data.length);

    drftf1(n, data, trigcache, trigcache.offset(n), splitcache);
  }
}

// wsave & ifac should be pointers (?)
// ignore: non_constant_identifier_names
void NUMrffti(int n, List<double> wsave, List<int> ifac) {
  if (n == 1) {
    return;
  }

  drfti1(n, wsave.offset(n), ifac);
}

// wsave & ifac should be pointers (?)
const List<int> ntryh = [4, 2, 3, 5];
const double tpi = 6.28318530717958647692528676655900577;

void drfti1(int n, ListWithOffset<double> wa, List<int> ifac) {
  int nf = 0;

  for (int j = 0; j < 4; j++) {
    int ntry = ntryh[j];
    while (n % ntry == 0) {
      nf++;
      ifac[nf + 1] = ntry;
      n ~/= ntry;
    }
  }

  if (n > 1) {
    nf++;
    ifac[nf + 1] = n;
  }

  ifac[0] = n;
  ifac[1] = nf;

  if (nf <= 1) {
    return;
  }

  double argh = tpi / n;
  int iss = 0;
  int nfm1 = nf - 1;
  int l1 = 1;

  for (int k1 = 0; k1 < nfm1; k1++) {
    int ip = ifac[k1 + 2];
    int ld = 0;
    int l2 = l1 * ip;
    int ido = n ~/ l2;
    int ipm = ip - 1;

    for (int j = 0; j < ipm; j++) {
      ld += l1;
      int i = iss;
      double argld = ld * argh;
      double fi = 0.0;

      for (int ii = 2; ii < ido; ii += 2) {
        fi += 1.0;
        double arg = fi * argld;
        wa[i++] = math.cos(arg);
        wa[i++] = math.sin(arg);
      }
      iss += ido;
    }
    l1 = l2;
  }
}

void drftf1(
  int n,
  List<double> c,
  List<double> ch,
  ListWithOffset<double> wa,
  List<int> ifac,
) {
  int nf = ifac[1];
  int na = 1;
  int l2 = n;
  int iw = n;

  for (int k1 = 0; k1 < nf; k1++) {
    int kh = nf - k1;
    int ip = ifac[kh + 1];
    int l1 = l2 ~/ ip;
    int ido = n ~/ l2;
    int idl1 = ido * l1;
    int ix2, ix3;
    iw -= (ip - 1) * ido;
    na = 1 - na;

    if (ip != 4) {
      if (ip != 2) {
        if (ido == 1) {
          na = 1 - na;
        }
        if (na != 0) {
          dradfg(
            ido,
            ip,
            l1,
            idl1,
            c,
            c,
            c,
            ch,
            ch,
            wa.toOffset(iw - 1),
          );
          na = 1;
        } else {
          dradfg(
            ido,
            ip,
            l1,
            idl1,
            ch,
            ch,
            ch,
            c,
            c,
            wa.toOffset(iw - 1),
          );
          na = 0;
        }
      } else {
        if (na != 0) {
          dradf2(ido, l1, c, ch, wa.toOffset(iw - 1));
        } else {
          dradf2(ido, l1, ch, c, wa.toOffset(iw - 1));
        }
      }
    } else {
      ix2 = iw + ido;
      ix3 = ix2 + ido;
      if (na != 0) {
        dradf4(
          ido,
          l1,
          ch,
          c,
          wa.toOffset(iw - 1),
          wa.toOffset(ix2 - 1),
          wa.toOffset(ix3 - 1),
        );
      } else {
        dradf4(
          ido,
          l1,
          c,
          ch,
          wa.toOffset(iw - 1),
          wa.toOffset(ix2 - 1),
          wa.toOffset(ix3 - 1),
        );
      }
    }
    l2 = l1;
  }

  if (na == 1) {
    return;
  }

  for (int i = 0; i < n; i++) {
    c[i] = ch[i];
  }
}

void dradfg(
  int ido,
  int ip,
  int l1,
  int idl1,
  List<double> cc,
  List<double> c1,
  List<double> c2,
  List<double> ch,
  List<double> ch2,
  ListWithOffset<double> wa,
) {
  double ar1 = 1.0;
  double ai1 = 0.0;
  int iss;
  int t1 = 0, t2 = 0, t3 = 0, t4 = 0, t5 = 0, t6 = 0, t7 = 0, t8 = 0, t9 = 0;

  double arg = tpi / ip;
  double dcp = math.cos(arg);
  double dsp = math.sin(arg);
  int ipph = (ip + 1) ~/ 2;
  int ipp2 = ip;
  int idp2 = ido;
  int nbd = (ido - 1) ~/ 2;
  int t0 = l1 * ido;
  int t10 = ip * ido;

  if (ido != 1) {
    for (int ik = 0; ik < idl1; ik++) {
      ch2[ik] = c2[ik];
    }

    t1 = 0;
    for (int j = 1; j < ip; j++) {
      t1 += t0;
      t2 = t1;
      for (int k = 0; k < l1; k++) {
        ch[t2] = c1[t2];
        t2 += ido;
      }
    }

    iss = -ido;
    t1 = 0;

    if (nbd > l1) {
      for (int j = 1; j < ip; j++) {
        t1 += t0;
        iss += ido;
        t2 = -ido + t1;
        for (int k = 0; k < l1; k++) {
          int idij = iss - 1;
          t2 += ido;
          t3 = t2;
          for (int i = 2; i < ido; i += 2) {
            idij += 2;
            t3 += 2;
            ch[t3 - 1] = wa[idij - 1] * c1[t3 - 1] + wa[idij] * c1[t3];
            ch[t3] = wa[idij - 1] * c1[t3] - wa[idij] * c1[t3 - 1];
          }
        }
      }
    } else {
      for (int j = 1; j < ip; j++) {
        iss += ido;
        int idij = iss - 1;
        t1 += t0;
        t2 = t1;
        for (int i = 2; i < ido; i += 2) {
          idij += 2;
          t2 += 2;
          t3 = t2;
          for (int k = 0; k < l1; k++) {
            ch[t3 - 1] = wa[idij - 1] * c1[t3 - 1] + wa[idij] * c1[t3];
            ch[t3] = wa[idij - 1] * c1[t3] - wa[idij] * c1[t3 - 1];
            t3 += ido;
          }
        }
      }
    }

    t1 = 0;
    t2 = ipp2 * t0;
    if (nbd < l1) {
      for (int j = 1; j < ipph; j++) {
        t1 += t0;
        t2 -= t0;
        t3 = t1;
        t4 = t2;
        for (int i = 2; i < ido; i += 2) {
          t3 += 2;
          t4 += 2;
          t5 = t3 - ido;
          t6 = t4 - ido;
          for (int k = 0; k < l1; k++) {
            t5 += ido;
            t6 += ido;
            c1[t5 - 1] = ch[t5 - 1] + ch[t6 - 1];
            c1[t6 - 1] = ch[t5] - ch[t6];
            c1[t5] = ch[t5] + ch[t6];
            c1[t6] = ch[t6 - 1] - ch[t5 - 1];
          }
        }
      }
    } else {
      for (int j = 1; j < ipph; j++) {
        t1 += t0;
        t2 -= t0;
        t3 = t1;
        t4 = t2;
        for (int k = 0; k < l1; k++) {
          t5 = t3;
          t6 = t4;
          for (int i = 2; i < ido; i += 2) {
            t5 += 2;
            t6 += 2;
            c1[t5 - 1] = ch[t5 - 1] + ch[t6 - 1];
            c1[t6 - 1] = ch[t5] - ch[t6];
            c1[t5] = ch[t5] + ch[t6];
            c1[t6] = ch[t6 - 1] - ch[t5 - 1];
            t6 += ido;
            t5 += ido;
          }
        }
      }
    }
  }

  for (int ik = 0; ik < idl1; ik++) {
    c2[ik] = ch2[ik];
  }

  t1 = 0;
  t2 = ipp2 * idl1;
  for (int j = 1; j < ipph; j++) {
    t1 += t0;
    t2 -= t0;
    t3 = t1 - ido;
    t4 = t2 - ido;
    for (int k = 0; k < l1; k++) {
      t3 += ido;
      t4 += ido;
      c1[t3] = ch[t3] + ch[t4];
      c1[t4] = ch[t4] - ch[t3];
    }
  }

  for (int j = 1; j < ipph; j++) {
    t1 += idl1;
    t2 = t1;
    for (int ik = 0; ik < idl1; ik++) {
      ch2[ik] += c2[t2++];
    }
  }

  if (ido < l1) {
    for (int k = 0; k < l1; k++) {
      t3 = k;
      t4 = k;
      for (int i = 0; i < ido; i++) {
        cc[t4++] = ch[t3];
        t3 += ido;
        t4 += t10;
      }
    }
  } else {
    for (int i = 0; i < ido; i++) {
      t1 = i;
      t2 = i;
      for (int k = 0; k < l1; k++) {
        cc[t2] = ch[t1];
        t1 += ido;
        t2 += t10;
      }
    }
  }

  t1 = 0;
  t2 = ido << 1;
  t3 = 0;
  t4 = ipp2 * t0;
  for (int j = 1; j < ipph; j++) {
    t1 += t2;
    t3 += t0;
    t4 -= t0;
    t5 = t1;
    t6 = t3;
    t7 = t4;
    for (int k = 0; k < l1; k++) {
      cc[t5 - 1] = ch[t6];
      cc[t5] = ch[t7];
      t5 += t10;
      t6 += ido;
      t7 += ido;
    }
  }

  if (ido == 1) {
    return;
  }

  if (nbd < l1) {
    for (int j = 1; j < ipph; j++) {
      t1 += t2;
      t3 += t2;
      t4 += t0;
      t5 -= t0;
      t6 = t1;
      t7 = t3;
      t8 = t4;
      t9 = t5;
      for (int k = 0; k < l1; k++) {
        for (int i = 2; i < ido; i += 2) {
          int ic = idp2 - i;
          cc[i + t7 - 1] = ch[i + t8 - 1] + ch[i + t9 - 1];
          cc[ic + t6 - 1] = ch[i + t8 - 1] - ch[i + t9 - 1];
          cc[i + t7] = ch[i + t8] + ch[i + t9];
          cc[ic + t6] = ch[i + t9] - ch[i + t8];
        }
        t6 += t10;
        t7 += t10;
        t8 += ido;
        t9 += ido;
      }
    }
  } else {
    for (int j = 1; j < ipph; j++) {
      t1 += t2;
      t3 += t2;
      t4 += t0;
      t5 -= t0;
      for (int i = 2; i < ido; i += 2) {
        t6 = idp2 + t1 - i;
        t7 = i + t3;
        t8 = i + t4;
        t9 = i + t5;
        for (int k = 0; k < l1; k++) {
          cc[t7 - 1] = ch[t8 - 1] + ch[t9 - 1];
          cc[t6 - 1] = ch[t8 - 1] - ch[t9 - 1];
          cc[t7] = ch[t8] + ch[t9];
          cc[t6] = ch[t9] - ch[t8];
          t6 += t10;
          t7 += t10;
          t8 += ido;
          t9 += ido;
        }
      }
    }
  }
}

void dradf2(
  int ido,
  int l1,
  List<double> cc,
  List<double> ch,
  ListWithOffset<double> wa1,
) {
  int t1 = 0;
  int t2;
  int t0 = (t2 = l1 * ido);
  int t3 = ido << 1;

  for (int k = 0; k < l1; k++) {
    ch[t1 << 1] = cc[t1] + cc[t2];
    ch[(t1 << 1) + t3 - 1] = cc[t1] - cc[t2];
    t1 += ido;
    t2 += ido;
  }

  if (ido < 2) {
    return;
  }

  if (ido == 2) {
    t1 = 0;
    t2 = t0;

    for (int k = 0; k < l1; k++) {
      t3 = t2;
      int t4 = (t1 << 1) + (ido << 1);
      int t5 = t1;
      int t6 = t1 + t1;

      for (int i = 2; i < ido; i += 2) {
        t3 += 2;
        t4 -= 2;
        t5 += 2;
        t6 += 2;
        double tr2 = wa1[i - 2] * cc[t3 - 1] + wa1[i - 1] * cc[t3];
        double ti2 = wa1[i - 2] * cc[t3] - wa1[i - 1] * cc[t3 - 1];
        ch[t6] = cc[t5] + ti2;
        ch[t4] = ti2 - cc[t5];
        ch[t6 - 1] = cc[t5 - 1] + tr2;
        ch[t4 - 1] = cc[t5 - 1] - tr2;
      }

      t1 += ido;
      t2 += ido;
    }

    if (ido % 2 == 1) {
      t3 = (t2 = (t1 = ido) - 1);
      t2 += t0;

      for (int k = 0; k < l1; k++) {
        ch[t1] = -cc[t2];
        ch[t1 - 1] = cc[t3];
        t1 += ido << 1;
        t2 += ido;
        t3 += ido;
      }
    }
  }
}

void dradf4(
  int ido,
  int l1,
  List<double> cc,
  List<double> ch,
  ListWithOffset<double> wa1,
  ListWithOffset<double> wa2,
  ListWithOffset<double> wa3,
) {
  const hsqt2 = 0.70710678118654752440084436210485;
  int t5, t6;
  int t0 = l1 * ido;
  int t1 = t0;
  int t4 = t1 << 1;
  int t2 = t1 + (t1 << 1);
  int t3 = 0;

  for (int k = 0; k < l1; k++) {
    final double tr1 = cc[t1] + cc[t2];
    final double tr2 = cc[t3] + cc[t4];
    ch[t5 = t3 << 2] = tr1 + tr2;
    ch[(ido << 2) + t5 - 1] = tr2 - tr1;
    ch[(t5 += (ido << 1)) - 1] = cc[t3] - cc[t4];
    ch[t5] = cc[t2] - cc[t1];

    t1 += ido;
    t2 += ido;
    t3 += ido;
    t4 += ido;
  }

  if (ido < 2) return;
  if (ido == 2) return;

  t1 = 0;
  for (int k = 0; k < l1; k++) {
    t2 = t1;
    t4 = t1 << 2;
    t5 = (t6 = ido << 1) + t4;
    for (int i = 2; i < ido; i += 2) {
      t3 = (t2 += 2);
      t4 += 2;
      t5 -= 2;

      t3 += t0;
      final double cr2 = wa1[i - 2] * cc[t3 - 1] + wa1[i - 1] * cc[t3];
      final double ci2 = wa1[i - 2] * cc[t3] - wa1[i - 1] * cc[t3 - 1];
      t3 += t0;
      final double cr3 = wa2[i - 2] * cc[t3 - 1] + wa2[i - 1] * cc[t3];
      final double ci3 = wa2[i - 2] * cc[t3] - wa2[i - 1] * cc[t3 - 1];
      t3 += t0;
      final double cr4 = wa3[i - 2] * cc[t3 - 1] + wa3[i - 1] * cc[t3];
      final double ci4 = wa3[i - 2] * cc[t3] - wa3[i - 1] * cc[t3 - 1];

      final double tr1 = cr2 + cr4;
      final double tr4 = cr4 - cr2;
      final double ti1 = ci2 + ci4;
      final double ti4 = ci2 - ci4;
      final double ti2 = cc[t2] + ci3;
      final double ti3 = cc[t2] - ci3;
      final double tr2 = cc[t2 - 1] + cr3;
      final double tr3 = cc[t2 - 1] - cr3;

      ch[t4 - 1] = tr1 + tr2;
      ch[t4] = ti1 + ti2;

      ch[t5 - 1] = tr3 - ti4;
      ch[t5] = tr4 - ti3;

      ch[t4 + t6 - 1] = ti4 + tr3;
      ch[t4 + t6] = tr4 + ti3;

      ch[t5 + t6 - 1] = tr2 - tr1;
      ch[t5 + t6] = ti1 - ti2;
    }
    t1 += ido;
  }

  if (ido % 2 == 1) return;

  t2 = (t1 = t0 + ido - 1) + (t0 << 1);
  t3 = ido << 2;
  t4 = ido;
  t5 = ido << 1;
  t6 = ido;

  for (int k = 0; k < l1; k++) {
    final double ti1 = -hsqt2 * (cc[t1] + cc[t2]);
    final double tr1 = hsqt2 * (cc[t1] - cc[t2]);
    ch[t4 - 1] = tr1 + cc[t6 - 1];
    ch[t4 + t5 - 1] = cc[t6 - 1] - tr1;
    ch[t4] = ti1 - cc[t1 + t0];
    ch[t4 + t5] = ti1 + cc[t1 + t0];
    t1 += ido;
    t2 += ido;
    t4 += t3;
    t6 += ido;
  }
}
