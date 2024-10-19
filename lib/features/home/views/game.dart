import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_game/features/home/views/games.dart'; // Firestore paketini ekledik

class Game extends StatefulWidget {
  final String uid;

  const Game({Key? key, required this.uid}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  late String word;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Game!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter a word',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    word = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (word.isNotEmpty) {
                  // Firestore sorgusu için referans oluşturuyoruz
                  var querySnapshot = await FirebaseFirestore.instance
                      .collection('games')
                      .where('sender', isEqualTo: widget.uid)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    final acceptedByReceiverInvites = querySnapshot.docs.first;
                    await acceptedByReceiverInvites.reference.update({
                      'sender_word': word,

                    });
                    final receiverWord = acceptedByReceiverInvites['receiver_word'];

                    if(receiverWord.toString().length!=0)
                      {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Games(
                              uid: widget.uid,
                              gameid:acceptedByReceiverInvites.id,
                              who:true,
                              counter:receiverWord.toString().trim().length
                            ),
                          ),
                              (route) => false,
                        );
                      }


                  } else {
                    querySnapshot = await FirebaseFirestore.instance
                        .collection('games')
                        .where('receiver', isEqualTo: widget.uid)
                        .get();
                    if (querySnapshot.docs.isNotEmpty) {
                      final acceptedByReceiverInvites = querySnapshot.docs.first;
                      await acceptedByReceiverInvites.reference.update({
                        'receiver_word': word,

                      });
                      final senderWord = acceptedByReceiverInvites['sender_word'];


                      if(senderWord.toString().length!=0)
                        {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Games(
                                uid: widget.uid,
                                gameid:acceptedByReceiverInvites.id,
                                who:false,
                                counter:senderWord.toString().trim().length,
                              ),
                            ),
                                (route) => false,
                          );
                        }


                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Entered word not found in Firestore!'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a word!'),
                    ),
                  );
                }
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
