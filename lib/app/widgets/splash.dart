import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:siawi_app/utils/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            "assets/logo/logo-splash.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                        ),
                        Container(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                'SISTEM INFORMASI AKADEMIK',
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Bobbers',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            pause: const Duration(milliseconds: 2000),
                            isRepeatingAnimation: false,
                          ),
                        ),
                        Container(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                'WISATA INDONESIA',
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Bobbers',
                                  fontWeight: FontWeight.bold,
                                ),
                                speed: const Duration(milliseconds: 110),
                              ),
                            ],
                            isRepeatingAnimation: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                  padding: EdgeInsets.only(bottom: 30),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
