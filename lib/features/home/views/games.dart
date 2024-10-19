import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_game/features/home/views/sonuc.dart';

class Games extends StatefulWidget {
  final String uid;
  final String gameid;
  final bool who; // false ise kullanıcı receiver, true ise kullanıcı sender
  final counter;

  const Games({Key? key, required this.uid, required this.gameid, required this.who, required this.counter}) : super(key: key);

  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  late TextEditingController _wordController; // Kelime girişi için controller
  late CollectionReference _gamesCollection; // Firestore koleksiyon referansı
  late int _remainingAttempts; // Kullanıcının kalan tahmin hakkı

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(); // TextEditingController'ı başlat
    _gamesCollection = FirebaseFirestore.instance.collection('games'); // Firestore koleksiyonunu başlat
    _remainingAttempts = widget.counter; // Başlangıçta kullanıcıya 5 tahmin hakkı ver
  }

  @override
  void dispose() {
    _wordController.dispose(); // Bellek sızıntısını önlemek için controller'ı temizle
    super.dispose();
  }

  void _makeGuess() async {
    String guessedWord = _wordController.text.trim();
    if (guessedWord.isNotEmpty) {
      final gameDoc = _gamesCollection.doc(widget.gameid);
      if (_remainingAttempts > 0) {


        setState(() {
          _remainingAttempts--; // Kullanıcının tahmin hakkını azalt
        });

        gameDoc.get().then((gameSnapshot) {
          if (gameSnapshot.exists) {
            var data = gameSnapshot.data() as Map<String, dynamic>?;

            if (data != null) {
              if (widget.who) {
                var receiverWord = data["receiver_word"];
                if (receiverWord == guessedWord) {
                  gameDoc.set({
                    'sender_win': true,
                  }, SetOptions(merge: true))
                      .then((_) {
                    print('Belge başarıyla güncellendi.');
                  })
                      .catchError((error) {
                    print('Belge güncellenirken hata oluştu: $error');
                  });
                } else {
                  print('YANLIŞŞŞŞŞŞŞŞ');
                }
              } else {
                var senderWord = data["sender_word"];
                if (senderWord == guessedWord) {
                  gameDoc.set({
                    'receiver_win': true,
                  }, SetOptions(merge: true))
                      .then((_) {
                    print('Belge başarıyla güncellendi.');
                  })
                      .catchError((error) {
                    print('Belge güncellenirken hata oluştu: $error');
                  });
                } else {
                  print('YANLIŞŞŞŞŞŞŞŞ');
                }
              }
            }
          } else {
            print('Belge bulunamadı.');
          }
        }).catchError((error) {
          print('Belge alınırken hata oluştu: $error');
        });
      } if (widget.who==true && _remainingAttempts==0) {
        gameDoc.set({
          'sender_hak': false,
        }, SetOptions(merge: true))
            .then((_) {
          print('Belge başarıyla güncellendi.');
        })
            .catchError((error) {
          print('Belge güncellenirken hata oluştu: $error');
        });

      }
      if (widget.who==false && _remainingAttempts==0){
        gameDoc.set({
          'receiver_hak': false,
        }, SetOptions(merge: true))
            .then((_) {
          print('Belge başarıyla güncellendi.');
        })
            .catchError((error) {
          print('Belge güncellenirken hata oluştu: $error');
        });
      }
    } else {
      print('Lütfen tahmin için bir kelime girin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to the Game'),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('games')
                .doc(widget.gameid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshot.hasError) {
                return SizedBox();
              }
              var gameData = snapshot.data!;
              bool hak_Sender=gameData['sender_hak'];
              bool hak_receiver=gameData['receiver_hak'];
              bool receiver_win=gameData['receiver_win'];
              bool sender_win=gameData['sender_win'];


              if(hak_Sender==false && hak_receiver==true && receiver_win==false && sender_win==false)
                {

                }

              if(hak_Sender==true && hak_receiver==false && receiver_win==false && sender_win==false)
              {

              }
              if(hak_Sender==false && hak_receiver==false && receiver_win==false && sender_win==false)
              {
                DocumentReference documentReference =
                FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                // Belgeyi sil
                documentReference.delete().then((value) {
                  print('Belge başarıyla silindi.');
                }).catchError((error) {
                  print('Belge silinirken hata oluştu: $error');
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => sonuc(result: 3,uid: widget.uid,
                  )),
                );
              }
              if(hak_Sender==false && hak_receiver==false && receiver_win==true && sender_win==false)
              {
                if(widget.who)
                  {
                    DocumentReference documentReference =
                    FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                    // Belgeyi sil
                    documentReference.delete().then((value) {
                      print('Belge başarıyla silindi.');
                    }).catchError((error) {
                      print('Belge silinirken hata oluştu: $error');
                    });
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                      )),
                    );
                  }
                else
                  {
                    DocumentReference documentReference =
                    FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                    // Belgeyi sil
                    documentReference.delete().then((value) {
                      print('Belge başarıyla silindi.');
                    }).catchError((error) {
                      print('Belge silinirken hata oluştu: $error');
                    });
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                      )),
                    );
                  }
              }
              if(hak_Sender==false && hak_receiver==false && receiver_win==false && sender_win==true)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }

              }
              if(hak_Sender==false && hak_receiver==true && receiver_win==true && sender_win==false)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
              }
              if(hak_Sender==true && hak_receiver==false && receiver_win==true && sender_win==false)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
              }
              if(hak_Sender==false && hak_receiver==true && receiver_win==false && sender_win==true)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
              }
              if(hak_Sender==true && hak_receiver==false && receiver_win==false && sender_win==true)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
              }
              if(hak_Sender==true && hak_receiver==true && receiver_win==false && sender_win==true)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
              }
              if(hak_Sender==true && hak_receiver==true && receiver_win==true && sender_win==false)
              {
                if(widget.who)
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 2,uid: widget.uid,
                    )),
                  );
                }
                else
                {
                  DocumentReference documentReference =
                  FirebaseFirestore.instance.collection('games').doc(widget.gameid);

                  // Belgeyi sil
                  documentReference.delete().then((value) {
                    print('Belge başarıyla silindi.');
                  }).catchError((error) {
                    print('Belge silinirken hata oluştu: $error');
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => sonuc(result: 1,uid: widget.uid,
                    )),
                  );
                }
              }



              // Ekrana hiçbir şey döndürme, sadece verileri al ve işle
              return SizedBox(); // Boş bir widget döndürerek ekrana herhangi bir şey çıkarmaz
            },
          ),

            // Widget içeriği burada olacak
            Builder(
              builder: (BuildContext context) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Remaining Attempts: ${_remainingAttempts.toString()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Diğer action'lar eklenebilir
          ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to the Game!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                hintText: 'Enter a word to guess',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _remainingAttempts > 0 ? _makeGuess : null,
              child: Text('Guess'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue,
    );
  }
}
