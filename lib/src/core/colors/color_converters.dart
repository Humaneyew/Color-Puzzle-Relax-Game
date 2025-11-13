import 'dart:math';
import 'dart:ui';

import 'lab_color.dart';

const double _epsilon = 0.008856451679035631;
const double _kappa = 903.2962962;

const double _xn = 95.047;
const double _yn = 100.0;
const double _zn = 108.883;

LabColor srgbToLab(Color color) {
  final double r = color.red / 255.0;
  final double g = color.green / 255.0;
  final double b = color.blue / 255.0;

  final double rLinear = _srgbToLinear(r);
  final double gLinear = _srgbToLinear(g);
  final double bLinear = _srgbToLinear(b);

  final double x = (0.4124564 * rLinear + 0.3575761 * gLinear + 0.1804375 * bLinear) * 100.0;
  final double y = (0.2126729 * rLinear + 0.7151522 * gLinear + 0.0721750 * bLinear) * 100.0;
  final double z = (0.0193339 * rLinear + 0.1191920 * gLinear + 0.9503041 * bLinear) * 100.0;

  final double fx = _pivotXyz(x / _xn);
  final double fy = _pivotXyz(y / _yn);
  final double fz = _pivotXyz(z / _zn);

  final double l = 116.0 * fy - 16.0;
  final double a = 500.0 * (fx - fy);
  final double bLab = 200.0 * (fy - fz);

  return LabColor(l, a, bLab);
}

Color labToSrgb(LabColor lab) {
  final double fy = (lab.l + 16.0) / 116.0;
  final double fx = lab.a / 500.0 + fy;
  final double fz = fy - lab.b / 200.0;

  final double x = _xn * _pivotLab(fx);
  final double y = _yn * _pivotLab(fy);
  final double z = _zn * _pivotLab(fz);

  final double xNorm = x / 100.0;
  final double yNorm = y / 100.0;
  final double zNorm = z / 100.0;

  double r = xNorm * 3.2404542 + yNorm * -1.5371385 + zNorm * -0.4985314;
  double g = xNorm * -0.9692660 + yNorm * 1.8760108 + zNorm * 0.0415560;
  double b = xNorm * 0.0556434 + yNorm * -0.2040259 + zNorm * 1.0572252;

  r = _linearToSrgb(r);
  g = _linearToSrgb(g);
  b = _linearToSrgb(b);

  return Color.fromARGB(
    255,
    _clampToChannel(r * 255.0),
    _clampToChannel(g * 255.0),
    _clampToChannel(b * 255.0),
  );
}

int _clampToChannel(double value) {
  return value.isNaN
      ? 0
      : max(0, min(255, (value + 0.5).floor()));
}

double _srgbToLinear(double value) {
  if (value <= 0.04045) {
    return value / 12.92;
  }
  return pow((value + 0.055) / 1.055, 2.4).toDouble();
}

double _linearToSrgb(double value) {
  if (value <= 0.0031308) {
    return 12.92 * value;
  }
  return 1.055 * pow(value, 1 / 2.4) - 0.055;
}

double _pivotXyz(double value) {
  if (value > _epsilon) {
    return pow(value, 1 / 3).toDouble();
  }
  return (_kappa * value + 16) / 116;
}

double _pivotLab(double value) {
  final double valueCubed = value * value * value;
  if (valueCubed > _epsilon) {
    return valueCubed;
  }
  return (value - 16.0 / 116.0) / (_kappa / 116.0);
}
