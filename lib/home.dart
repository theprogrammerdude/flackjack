import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flackjack/start.dart';
import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int playerSum = 0;
  int dealerSum = 0;
  int playerAceCount = 0;
  int dealerAceCount = 0;

  String hidden = '';
  bool canHit = true;
  bool show = false;

  var cards = [
    'A',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'K',
    'Q'
  ];
  var types = ['C', 'D', 'H', 'S'];
  var deck = <String>[];
  var d = <String>[];
  var p = <String>[];

  isNumeric(string) => num.tryParse(string) != null;

  List<String> buildDeck() {
    for (var i = 0; i < types.length; i++) {
      for (var j = 0; j < cards.length; j++) {
        deck.add('${cards[j]}-${types[i]}');
      }
    }

    return deck;
  }

  shuffle() {
    for (var i = 0; i < deck.length; i++) {
      var j = Random().nextInt(deck.length);

      var temp = deck[j];
      deck[i] = deck[j];
      deck[j] = temp;
    }
  }

  int getValue(String card) {
    var data = card.split('-');
    var value = data[0];

    if (!isNumeric(value)) {
      if (value == 'A') {
        return 11;
      }

      return 10;
    }

    return int.parse(value);
  }

  int checkAce(String card) {
    if (card[0] == 'A') {
      return 1;
    }

    return 0;
  }

  dealerCards() {
    var card = deck.removeLast();

    dealerSum += getValue(card);
    dealerAceCount += checkAce(card);

    d.add(card);
  }

  playerCards() {
    for (var i = 0; i < 2; i++) {
      var card = deck.removeLast();

      playerSum += getValue(card);
      playerAceCount += checkAce(card);

      p.add(card);
    }
  }

  int reduceAce(int sum, int aceCount) {
    while (sum > 21 && aceCount > 0) {
      sum -= 10;
      aceCount -= 1;
    }

    return sum;
  }

  hit() {
    AudioPlayer().play(AssetSource('flipcard.mp3'));

    if (!canHit) {
      return;
    }

    var card = deck.removeLast();

    playerSum += getValue(card);
    playerAceCount += checkAce(card);

    setState(() {
      p.add(card);
    });

    if (reduceAce(playerSum, playerAceCount) > 21) {
      setState(() {
        canHit = false;
      });
    }
  }

  stay() {
    AudioPlayer().play(AssetSource('flipcard.mp3'));

    setState(() {
      dealerSum = reduceAce(dealerSum, dealerAceCount);
      playerSum = reduceAce(playerSum, playerAceCount);
      canHit = false;
      show = true;
    });

    if (playerSum > 21) {
      toast('YOU LOSE');
    } else if (dealerSum > 21) {
      toast('YOU WIN');
    } else if (playerSum == dealerSum) {
      toast('TIE');
    } else if (playerSum > dealerSum) {
      toast('YOU WIN');
    } else if (playerSum < dealerSum) {
      toast('YOU LOSE');
    }
  }

  toast(String msg) {
    VxToast.show(
      context,
      msg: msg,
      position: VxToastPosition.center,
    );
  }

  @override
  void initState() {
    startGame();
    super.initState();
  }

  startGame() {
    deck = buildDeck();
    shuffle();

    hidden = deck.removeLast();
    dealerSum += getValue(hidden);
    dealerAceCount += checkAce(hidden);

    dealerCards();
    playerCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            PanaraInfoDialog.showAnimatedGrow(
              context,
              message: 'Are you sure you want to quit game?',
              buttonText: 'Quit Game',
              title: 'Quit Game',
              textColor: Colors.black,
              onTapDismiss: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Start()),
                  (route) => false,
                );
              },
              panaraDialogType: PanaraDialogType.error,
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              PanaraInfoDialog.showAnimatedGrow(
                context,
                message: 'Are you sure you want to restart game?',
                buttonText: 'Restart Game',
                title: 'Restart Game',
                textColor: Colors.black,
                onTapDismiss: () {
                  Navigator.pop(context);

                  setState(() {
                    deck = [];
                    p = [];
                    d = [];
                    canHit = true;
                    dealerSum = 0;
                    playerSum = 0;
                    dealerAceCount = 0;
                    playerAceCount = 0;

                    startGame();
                  });
                },
                panaraDialogType: PanaraDialogType.normal,
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.green[800],
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => stay(),
            label: 'STAY'.text.bold.size(16).make(),
          ).pOnly(right: 20),
          FloatingActionButton.extended(
            onPressed: canHit ? () => hit() : null,
            label: 'HIT'.text.bold.size(16).make(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  'Dealer'
                      .text
                      .bold
                      .size(28)
                      .make()
                      .pOnly(bottom: 10, right: 10),
                  canHit
                      ? const SizedBox(width: 0)
                      : dealerSum.text.bold.size(28).make().pOnly(bottom: 10),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Image.asset(
                    canHit ? 'assets/back.png' : 'assets/$hidden.png',
                    height: 150,
                  ).pOnly(right: 8),
                  ...d.map((e) {
                    return Image.asset(
                      'assets/$e.png',
                      height: 150,
                    ).pOnly(right: 8);
                  }).toList(),
                ],
              ),
              const SizedBox(
                height: 75,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  'Player'
                      .text
                      .bold
                      .size(28)
                      .make()
                      .pOnly(bottom: 10, right: 10),
                  canHit
                      ? const SizedBox(width: 0)
                      : playerSum.text.bold.size(28).make().pOnly(bottom: 10),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: p.map((e) {
                  return Image.asset(
                    'assets/$e.png',
                    height: 150,
                  ).pOnly(right: 8, bottom: 8);
                }).toList(),
              ),
              const SizedBox(
                height: 75,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
