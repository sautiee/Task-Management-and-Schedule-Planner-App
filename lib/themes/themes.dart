import 'package:flutter/material.dart';
import 'package:taskmanagement/constants/colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: colorBG,
    onSurface: colorBlack,
    onSurfaceVariant: const Color.fromARGB(255, 101, 101, 101),
    surfaceTint: const Color.fromARGB(255, 198, 198, 198),
    onPrimary: Colors.white,
    primary: colorBlue,
    inversePrimary: const Color.fromARGB(255, 97, 189, 255),
    secondary: Colors.white,
    onSecondary: const Color(0xFF252525),
    onSecondaryFixedVariant: const Color.fromARGB(255, 247, 247, 247),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF252525),
    onSurface: Colors.white,
    onSurfaceVariant: const Color.fromARGB(255, 189, 189, 189),
    surfaceTint: const Color.fromARGB(255, 101, 101, 101),
    onPrimary: Colors.white,
    primary: const Color.fromARGB(255, 97, 189, 255),
    inversePrimary: const Color.fromARGB(255, 97, 189, 255),
    secondary: const Color.fromARGB(255, 67, 67, 67),
    onSecondary: Colors.white,
    onSecondaryFixedVariant: const Color.fromARGB(255, 92, 92, 92),
  ),
);

ThemeData purpleMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 252, 247, 255),
    onSurface: colorBlack,
    onSurfaceVariant: const Color.fromARGB(255, 101, 101, 101),
    surfaceTint: const Color.fromARGB(255, 198, 198, 198),
    onPrimary: Colors.white,
    primary: const Color.fromARGB(255, 158, 135, 193),
    inversePrimary: const Color.fromARGB(255, 170, 151, 202),
    secondary: Colors.white,
    onSecondary: const Color(0xFF252525),
    onSecondaryFixedVariant: const Color.fromARGB(255, 247, 247, 247),
  ),
);

ThemeData greenMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 247, 255, 238),
    onSurface: colorBlack,
    onSurfaceVariant: const Color.fromARGB(255, 101, 101, 101),
    surfaceTint: const Color.fromARGB(255, 198, 198, 198),
    onPrimary: Colors.white,
    primary: const Color.fromARGB(255, 156, 193, 110),
    inversePrimary: const Color.fromARGB(255, 186, 214, 152),
    secondary: Colors.white,
    onSecondary: const Color(0xFF252525),
    onSecondaryFixedVariant: const Color.fromARGB(255, 247, 247, 247),
  ),
);


ThemeData redMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 252, 243, 243),
    onSurface: colorBlack,
    onSurfaceVariant: const Color.fromARGB(255, 101, 101, 101),
    surfaceTint: const Color.fromARGB(255, 198, 198, 198),
    onPrimary: Colors.white,
    primary: const Color(0xFFDE4A55),
    inversePrimary: const Color.fromARGB(255, 242, 107, 116),
    secondary: Colors.white,
    onSecondary: const Color(0xFF252525),
    onSecondaryFixedVariant: const Color.fromARGB(255, 247, 247, 247),
  ),
);

ThemeData pinkMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 255, 249, 249),
    onSurface: colorBlack,
    onSurfaceVariant: const Color.fromARGB(255, 101, 101, 101),
    surfaceTint: const Color.fromARGB(255, 198, 198, 198),
    onPrimary: Colors.white,
    primary: const Color.fromARGB(255, 240, 148, 153),
    inversePrimary: const Color(0xFFFFA3A6),
    secondary: Colors.white,
    onSecondary: const Color(0xFF252525),
    onSecondaryFixedVariant: const Color.fromARGB(255, 247, 247, 247),
  ),
);
//#f9e4e4