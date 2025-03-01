import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTheme {
  // Define primary colors
  static final Color primaryYellow = HexColor("#F0B90B"); // Binance yellow
  static final Color darkGrey = HexColor("#1E1E1E"); // Dark background
  static final Color lightGrey = HexColor("#2A2A2A"); // Slightly lighter shade for neumorphism
  static final Color cardShadow = Colors.black.withValues(alpha:  0.3);
  static final Color highlightShadow = Colors.white.withValues(alpha:  0.1);

  static final ThemeData lightTheme = ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white12,
      selectedItemColor: primaryYellow,
      unselectedItemColor: lightGrey
    ),
    primaryColorLight: const Color.fromARGB(255, 5, 5, 5),
    listTileTheme: ListTileThemeData(
      iconColor: primaryYellow,
      tileColor: const Color.fromARGB(255, 42, 42, 42),
      leadingAndTrailingTextStyle: TextStyle(color: Colors.white),
    ),
    brightness: Brightness.light,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: HexColor("#af9f85"),
    colorScheme: ColorScheme.light(
      primary: primaryYellow,
      secondary: Colors.grey[800]!,
      onSurface: Colors.black,
    ),
    cardColor: const Color.fromARGB(255, 222, 222, 222),
    iconTheme: IconThemeData(color: const Color.fromARGB(255, 134, 68, 68)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: const Color.fromARGB(255, 255, 116, 116),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: cardShadow,
        elevation: 5,
      ),
    ),
  );



















// ! DARK 
  static final ThemeData darkTheme = ThemeData(
    // textButtonTheme: TextButtonThemeData(
    //   style: ButtonStyle(
    //     backgroundColor: WidgetStatePropertyAll(Colors.grey),
    //     iconColor: WidgetStatePropertyAll(Colors.white),
    //     textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white))
    //   )
    // ),
    primaryColorLight: Colors.white,
    listTileTheme: ListTileThemeData(
      iconColor: primaryYellow,
      tileColor: const Color.fromARGB(255, 57, 57, 57),
      leadingAndTrailingTextStyle: TextStyle(color: Colors.white),
    ),
    brightness: Brightness.dark,
    primaryColor: primaryYellow,
    scaffoldBackgroundColor: darkGrey,
    colorScheme: ColorScheme.dark(
      primary: primaryYellow,
      secondary: lightGrey,
      onSurface: Colors.white,
    ),
    cardColor: lightGrey,
    iconTheme: IconThemeData(color: primaryYellow),
    appBarTheme: AppBarTheme(
      backgroundColor: darkGrey,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkGrey,
      selectedItemColor: primaryYellow,
      unselectedItemColor: Colors.grey[600],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: const Color.fromARGB(255, 244, 47, 47),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: cardShadow,
        elevation: 10,
      ),
    ),
    cardTheme: CardTheme(
      color: lightGrey,
      shadowColor: cardShadow,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryYellow.withValues(alpha: 0.3);
            }
            return lightGrey;
          },
        ),
      ),
    ),
  );
}
