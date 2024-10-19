import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

 Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    
      // Firebase Authentication kullanarak kullanıcı girişi yap
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
   }
  

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication kullanarak kullanıcı oluştur
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Oluşturulan kullanıcının UID'sini al
      String userId = userCredential.user!.uid;

      // Firestore'a kullanıcı bilgilerini ekle veya güncelle
      DocumentReference userRef = firestore.collection('users').doc(auth.currentUser!.uid);
      await userRef.set({
        'email': email,
        'password': password,
        'isOnline': false,
        'uid': userId, // Kullanıcının UID'sini users koleksiyonuna ekle
        'inGame':false,
      });

      print('User signed up and added to Firestore successfully');
    } catch (e) {
      print('Error signing up and adding user to Firestore: $e');
      // Hata durumunda uygun işlemler yapılabilir
      throw e; // Hata tekrar fırlatılabilir veya uygun şekilde işlenebilir
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    print('User signed out');
  }
}
