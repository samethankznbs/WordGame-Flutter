import 'package:flutter/material.dart';
import 'package:project_game/features/home/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class sonuc extends StatelessWidget {
  final int result;
  final String uid;

  const sonuc({Key? key, required this.result, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message;
    Color backgroundColor;
    Color textColor;
    FontWeight textWeight;
    double fontSize;

    // Sonuca göre mesajı ve stilini belirle
    if (result == 1) {
      message = 'Kazandın!';
      backgroundColor = Colors.purple; // Arka plan rengi
      textColor = Colors.white; // Metin rengi
      textWeight = FontWeight.bold; // Metin kalınlığı
      fontSize = 36.0; // Metin boyutu
    } else if (result == 2) {
      message = 'Kaybettin!';
      backgroundColor = Colors.purple; // Arka plan rengi
      textColor = Colors.white; // Metin rengi
      textWeight = FontWeight.bold; // Metin kalınlığı
      fontSize = 36.0; // Metin boyutu
    } else if (result == 3) {
      message = 'Berabere kaldın.';
      backgroundColor = Colors.purple; // Arka plan rengi
      textColor = Colors.white; // Metin rengi
      textWeight = FontWeight.bold; // Metin kalınlığı
      fontSize = 36.0; // Metin boyutu
    } else {
      message = 'Geçersiz sonuç.';
      backgroundColor = Colors.purple; // Arka plan rengi
      textColor = Colors.white; // Metin rengi
      textWeight = FontWeight.bold; // Metin kalınlığı
      fontSize = 36.0; // Metin boyutu
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sonuç Ekranı'),
      ),
      backgroundColor: backgroundColor, // Arka plan rengi
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(
                color: textColor, // Metin rengi
                fontWeight: textWeight, // Metin kalınlığı
                fontSize: fontSize, // Metin boyutu
                fontFamily: 'Montserrat', // Kullanılacak font
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'inGame': false,
                });
                // Navigator işlemi burada yapılıyor
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => Home(uid: uid, email: ' '),
                  ),
                );
              },
              child: Text('Çıkış Yap'),
            ),

          ],
        ),
      ),
    );
  }
}
