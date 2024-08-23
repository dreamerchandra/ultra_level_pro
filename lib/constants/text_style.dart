import 'package:flutter/material.dart';

class FontSize {
  static const double fontSizeXS = 12;
  static const double fontSizeS = 14;
  static const double fontSizeM = 16;
  static const double fontSizeL = 18;
  static const double fontSizeXL = 24;
  static const double fontSizeXXL = 28;
}

const header1 = TextStyle(
  fontSize: FontSize.fontSizeXXL,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w300,
);

const header2 = TextStyle(
  fontSize: FontSize.fontSizeXL,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w400,
);

const header3 = TextStyle(
  fontSize: FontSize.fontSizeXL,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w300,
);

const header4 = TextStyle(
  fontSize: FontSize.fontSizeL,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w600,
);

const header5 = TextStyle(
  fontSize: FontSize.fontSizeL,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w400,
);

const header6 = TextStyle(
  fontSize: FontSize.fontSizeM,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w800,
);

const header7 = TextStyle(
  fontSize: FontSize.fontSizeM,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w400,
);

const body1 = TextStyle(
  fontSize: FontSize.fontSizeS,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w400,
);

const body2 = TextStyle(
  fontSize: FontSize.fontSizeS,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.normal,
);

const caption1 = TextStyle(
  fontSize: FontSize.fontSizeXS,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w500,
);

const caption2 = TextStyle(
  fontSize: FontSize.fontSizeXS,
  fontStyle: FontStyle.italic,
  fontWeight: FontWeight.normal,
);

const pre = TextStyle(
  fontSize: FontSize.fontSizeXS,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.normal,
  fontFamily: AutofillHints.nameSuffix,
);
