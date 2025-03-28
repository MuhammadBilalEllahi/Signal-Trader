
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeService extends ChangeNotifier{
  ThemeMode _themeMode;
  final double _borderRadius = 8;

  ThemeService(this._themeMode);



  get getTheme => _themeMode;


  ThemeData getLightTheme(){
    return ThemeData(

      scaffoldBackgroundColor: Colors.white,

      appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: HexColor("#ADADAD"),
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HexColor("#3E3E3E")),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.white,
          )),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 5,
        enableFeedback: true,
        backgroundColor: HexColor("#ffffff"),
        selectedIconTheme: IconThemeData(color: HexColor("#f7cf56"), size: 25, fill: 0.1),
        selectedItemColor: HexColor("#000000"),
        selectedLabelStyle: TextStyle(color: HexColor("#000000"), fontSize: 12, fontWeight: FontWeight.w400,wordSpacing: 0,letterSpacing: 0,leadingDistribution: TextLeadingDistribution.even),
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        unselectedIconTheme:
        IconThemeData(color: HexColor("#ADADAD"), size: 25, fill: 0.1),
        unselectedItemColor: HexColor("#ADADAD"),
        unselectedLabelStyle: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400,wordSpacing: 0,letterSpacing: 0,leadingDistribution: TextLeadingDistribution.even),
      ),








      inputDecorationTheme: InputDecorationTheme(
        // constraints: const BoxConstraints(maxHeight: 50,),

        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        floatingLabelStyle: TextStyle(color: HexColor("#A1A8B0"),
            fontSize: 12,
            fontWeight: FontWeight.w200,
            height: 1.2),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor("#E5E7EB")),
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor("#f7cf56")),
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor("#F3F4F6")),
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor("#E5E7EB")),
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor("#E5E7EB")),
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
        fillColor: HexColor("#F9FAFB"),
        filled: true,

        hintStyle: TextStyle(color: HexColor("#A1A8B0"),
            fontSize: 14,
            fontWeight: FontWeight.w200),
        iconColor: HexColor("#A1A8B0"),
        prefixIconColor: HexColor("#A1A8B0"),
        suffixIconColor: HexColor("#A1A8B0"),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(50, 60),
              textStyle: const TextStyle(color: Colors.white,
                  fontSize: 22,
                  height: 1.2,
                  letterSpacing: 1.2),
              backgroundColor: HexColor("#000000"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_borderRadius)),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 10)
          )
      ),
    );
  }


}