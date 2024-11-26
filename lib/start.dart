import 'package:flutter/material.dart';
import 'main.dart';
import 'google_login.dart';
import 'kakao_login.dart';

class StartScreen extends StatelessWidget {

  final GLoginService GloginService = GLoginService();
  final KLoginService kLoginService = KLoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 90),
            Image.asset(
              'assets/img/logo.png',
              width: 270,
              height: 270,
            ),

            SizedBox(height: 100),

            ElevatedButton.icon(
              onPressed: () async {
                final user = await GloginService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()), //로그인 성공
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Google 로그인에 실패했습니다.'),
                    ),
                  );
                }
              },
              icon: Image.asset(
                'assets/img/google.png',
                width: 18,
                height: 18,
              ),
              label: Text(
                'Google 로그인',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(350, 50),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                final user = await kLoginService.signInWithKakao();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()), //로그인 성공
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kakao 로그인에 실패했습니다.'),
                    ),
                  );
                }
              },
              icon: Image.asset(
                'assets/img/kakao.png',
                width: 18,
                height: 18,
              ),
              label: Text(
                'Kakao 로그인',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(350, 50),
                backgroundColor: Color(0xFFFEE500),
                foregroundColor: Colors.black,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}