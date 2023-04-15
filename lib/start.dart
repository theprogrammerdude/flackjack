import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flackjack/home.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: 'Press back button again to close app'.text.make(),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset('assets/logo.png'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Home(),
                      ),
                    );
                  },
                  child: 'Start Game'.text.size(18).make(),
                ).wPCT(context: context, widthPCT: 75).h(50),
                const Spacer(),
                'Made by TheProgrammerDude'.text.center.make()
              ],
            ).p12(),
          ),
        ),
      ),
    );
  }
}
