import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_game/features/auth/views/sign_in.dart';
import 'package:project_game/features/home/views/game.dart';
class Home extends StatelessWidget {
  final String uid;
  final String email;

  const Home({Key? key, required this.uid, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('invites')
                .where('sender', isEqualTo: uid) // Sadece belirli bir sender UID'si için filtreleme
                .where('status', isEqualTo: 'denied') // Sadece status'u 'denied' olanları filtrele
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshot.hasError) {
                return SizedBox();
              }

              // Verileri al ve işle
              final deniedInvites = snapshot.data!.docs; // Filtrelenmiş belgelerin listesi

              // İlk reddedilmiş davet belgesini al
              QueryDocumentSnapshot? firstDeniedInvite;
              if (deniedInvites.isNotEmpty) {
                firstDeniedInvite = deniedInvites.first;
              }

              // İlk reddedilmiş davet belgesinin varsa verilerine erişim
              String? firstDeniedSenderId;
              String? firstDeniedReceiverId;
              String? firstDeniedStatus;
              DateTime? firstDeniedTimestamp;

              if (firstDeniedInvite != null) {
                firstDeniedSenderId = firstDeniedInvite['sender'];
                firstDeniedReceiverId = firstDeniedInvite['receiver'];
                firstDeniedStatus = firstDeniedInvite['status'];
                firstDeniedTimestamp = (firstDeniedInvite['timestamp'] as Timestamp).toDate();

                // İlk reddedilmiş davet belgesi için sender ID'den email değerini al
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(firstDeniedReceiverId)
                    .get()
                    .then((userDoc) {
                  final senderEmail = userDoc.data()?['email'];

                  // İlk reddedilmiş davet belgesi için mesaj göster
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reddedilmiş davet: Alıcı Hesap - $senderEmail'),

                      ),
                    );

                    // Belgeyi Firestore'dan silme işlemi
                    firstDeniedInvite?.reference.delete().then((_) {
                      print('Belge başarıyla silindi.');
                    }).catchError((error) {
                      print('Belgeyi silerken hata oluştu: $error');
                    });
                  });
                }).catchError((error) {
                  print('Kullanıcı verilerini alırken hata oluştu: $error');
                });
              }

              // Ekrana hiçbir şey döndürme, sadece verileri al ve işle
              return SizedBox(); // Boş bir widget döndürerek ekrana herhangi bir şey çıkarmaz
            },
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('invites')
                .where('sender', isEqualTo: uid) // Sadece belirli bir sender UID'si için filtreleme
                .where('status', isEqualTo: 'accepted') // Sadece status'u 'accepted' olanları filtrele
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshot.hasError) {
                return SizedBox();
              }

              final acceptedInvites = snapshot.data!.docs; // Kabul edilmiş davet belgeleri

              // İlk kabul edilmiş davet belgesini al
              QueryDocumentSnapshot? firstAcceptedInvite;
              if (acceptedInvites.isNotEmpty) {
                firstAcceptedInvite = acceptedInvites.first;
                String? firstAcceptedSenderId;
                String? firstAcceptedReceiverId;
                String? firstAcceptedStatus;
                DateTime? firstAcceptedTimestamp;

                if (firstAcceptedInvite != null) {
                  final firstAcceptedSenderId = firstAcceptedInvite['sender'];
                  final firstAcceptedReceiverId = firstAcceptedInvite['receiver'];
                  final firstAcceptedStatus = firstAcceptedInvite['status'];
                  final firstAcceptedTimestamp = (firstAcceptedInvite['timestamp'] as Timestamp).toDate();

                  // İlk kabul edilmiş davet belgesi için sender ID'den email değerini al
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(firstAcceptedReceiverId)
                      .get()
                      .then((userDoc) async {
                    final senderEmail = userDoc.data()?['email'];
                    addGameDocument(firstAcceptedSenderId,firstAcceptedReceiverId);
                    String userId = uid;

                    // Firestore'da belgeyi güncelle
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'inGame': true,
                    });
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kabul Edilmiş davet (Yönlendiriliyorsunuz): Rakip Hesap - $senderEmail'),
                        ),
                      );
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => Game(
                            uid: uid,
                            )), // GamePage'e yönlendirme
                        );
                      });
                    });
                  }).catchError((error) {
                    print('Kullanıcı verilerini alırken hata oluştu: $error');
                  });
                  firstAcceptedInvite?.reference.delete().then((_) {print('Belge başarıyla silindi.');
                  }).catchError((error) {
                  print('Belgeyi silerken hata oluştu: $error');
                  });

                }
              } else {
                // Kabul edilmiş davet bulunamadığında yapılacak işlem
                // Bu blokta alıcı (receiver) alanı ile karşılaştırma yapabilirsiniz
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('invites')
                      .where('receiver', isEqualTo: uid)
                      .where('status', isEqualTo: 'accepted')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> receiverSnapshot) {
                    if (receiverSnapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }
                    if (receiverSnapshot.hasError) {
                      return SizedBox();
                    }

                    final acceptedByReceiverInvites = receiverSnapshot.data!.docs; // Alıcı tarafından kabul edilen davet belgeleri

                    // İlk alıcı tarafından kabul edilen davet belgesini al
                    QueryDocumentSnapshot? firstAcceptedByReceiverInvite;
                    if (acceptedByReceiverInvites.isNotEmpty) {
                      firstAcceptedByReceiverInvite = acceptedByReceiverInvites.first;
                      String? firstAcceptedSenderId;
                      String? firstAcceptedReceiverId;
                      String? firstAcceptedStatus;
                      DateTime? firstAcceptedTimestamp;
                      if (firstAcceptedByReceiverInvite != null) {
                        final firstAcceptedSenderId = firstAcceptedByReceiverInvite['sender'];
                        final firstAcceptedReceiverId = firstAcceptedByReceiverInvite['receiver'];
                        final firstAcceptedStatus = firstAcceptedByReceiverInvite['status'];
                        final firstAcceptedTimestamp = (firstAcceptedByReceiverInvite['timestamp'] as Timestamp).toDate();

                        // İlk kabul edilmiş davet belgesi için sender ID'den email değerini al
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(firstAcceptedSenderId)
                            .get()
                            .then((userDoc) async {
                          final senderEmail = userDoc.data()?['email'];
                          String userId = uid;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'inGame': true,
                          });
                          // İlk kabul edilmiş davet belgesi için mesaj göster
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kabul Edilmiş davet (Yönlendiriliyorsunuz): Rakip Hesap - $senderEmail'),
                              ),
                            );

                            // Snackbar gösterildikten sonra yönlendirme işlemi
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => Game(uid: uid,
                                 )), // GamePage'e yönlendirme
                              );
                            });
                          });
                        }).catchError((error) {
                          print('Kullanıcı verilerini alırken hata oluştu: $error');
                        });
                      }
                      //////////////////////////////////////////////////
                    }

                    return SizedBox(); // Boş bir widget döndürerek ekrana herhangi bir şey çıkarmaz
                  },
                );
              }

              return SizedBox(); // Boş bir widget döndürerek ekrana herhangi bir şey çıkarmaz
            },
          ),




        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('invites')
                  .where('receiver', isEqualTo: uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> inviteSnapshot) {
                if (inviteSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (inviteSnapshot.hasError) {
                  return Center(
                    child: Text('Davetleri alırken bir hata oluştu'),
                  );
                }
                final inviteDocs = inviteSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: inviteDocs.length,
                  itemBuilder: (context, index) {
                    final invite = inviteDocs[index];
                    final senderId = invite['sender'];

                    return FutureBuilder(
                      future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Davet Gönderen: ...'),
                            subtitle: Text('Davet Tarihi: ...'),
                          );
                        }
                        if (userSnapshot.hasError) {
                          return ListTile(
                            title: Text('Davet Gönderen: Bilinmiyor'),
                            subtitle: Text('Davet Tarihi: ...'),
                          );
                        }
                        final senderEmail = userSnapshot.data!['email'];
                        final timestamp = (invite['timestamp'] as Timestamp).toDate();
                        final formattedTimestamp = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';

                        return ListTile(
                          title: Text('Davet Gönderen: $senderEmail'),
                          subtitle: Text('Davet Tarihi: $formattedTimestamp\nDurum: ${invite['status']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('invites').doc(invite.id).update({
                                    'status': 'accepted',
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('invites').doc(invite.id).update({
                                    'status': 'denied',
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            'İstek Atabileceğin Oyuncular',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Bir hata oluştu'),
                  );
                }
                final onlineUsers = snapshot.data!.docs.where((doc) => doc['isOnline'] == true && doc['inGame'] == false && doc.id != uid).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: onlineUsers.length,
                  itemBuilder: (context, index) {
                    final user = onlineUsers[index];
                    return ListTile(
                      title: Text(user['email']),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          String senderId = uid;
                          String receiverId = user.id;

                          try {
                            await FirebaseFirestore.instance.collection('invites').add({
                              'sender': senderId,
                              'receiver': receiverId,
                              'status': 'pending',
                              'timestamp': DateTime.now(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Davet gönderildi')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Davet gönderirken hata oluştu')),
                            );
                          }
                        },
                        child: Text('Invite'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'isOnline': false,
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SignIn(),
                ),
              );
            },
            child: Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  Future<void> addGameDocument(String senderId, String receiverId) async {
    try {
      await FirebaseFirestore.instance.collection('games').add({
        'sender': senderId,
        'receiver': receiverId,
        'timestamp': DateTime.now(),
        'sender_word':"",
        'receiver_word':"",
        'receiver_win':false,
        'sender_win':false,
        'receiver_hak':true,
        'sender_hak':true,
      });
      print('Yeni oyun belgesi başarıyla eklendi.');
    } catch (e) {
      print('Oyun belgesi eklenirken hata oluştu: $e');
    }
  }

}


